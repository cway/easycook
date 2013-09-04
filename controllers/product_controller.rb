#encoding:utf-8
#author cway 2013-06-23

class ProductController < ApplicationController
	#创建商品
	def self.create( product_info )
	  verify_params( product_info, "attribute_set_id" )
      verify_params( product_info, "type_id" )
      verify_params( product_info, "sku" )
      verify_params( product_info, "categories" )
      verify_params( product_info, "name" )

	  begin
	  	product_id        =  Product.create_product( product_info )
	  	product           =  Product.get_product( product_id )
	  rescue ActiveRecord::RecordNotUnique => err
	  	raise ApiException.new( Constant::HTTP_REQUEST_ERROR, "该商品sku已存在" ) 
	  end
	  product
	end

	#更新商品
	def self.update( product_id, product_info )
		verify_params( product_info, "id" )
		verify_params( product_info, "sku" )
		verify_params( product_info, "categories" )
		verify_params( product_info, "attribute_set_id" )
		verify_params( product_info, "name" )

	  if product_id.to_i != product_info["id"].to_i
        raise ApiException.new( Constant::HTTP_REQUEST_ERROR, "修改商品信息不匹配" )
	  end
	  begin
	  	Product.update_product( product_info )
	  	product           =  Product.get_product( product_id )
	  rescue ActiveRecord::RecordNotFound => err
	  	raise ApiException.new( Constant::HTTP_REQUEST_ERROR, "该商品不存在" ) 
	  end 
	end

	#获取单个商品
	def self.get( product_id )
	  begin
	  	product           =  CACHE.read ( 'product_' + product_id )
	  	unless 
	  	  product         =  Product.get_product( product_id )
	    end
	  rescue ActiveRecord::RecordNotFound => err
	  	raise ApiException.new( Constant::HTTP_REQUEST_ERROR, "该商品不存在" ) 
	  end
	  product
	end

    #获取多个商品
	def self.get_mutils( product_ids )
	  products               = Hash.new
	  product_ids.each do |product_id|
	  	products[product_id] = self.get( product_id )
	  end
	  products
	end

	#商品下架
	def self.delete( product_id )
	  Product.delete_product( product_id )
	  self.get( product_id )
	end
end