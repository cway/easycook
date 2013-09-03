#encoding:utf-8
#author cway 2013-06-23

class ProductController < ApplicationController
	def self.create( product_info )
	  verify_params product_info, "attribute_set_id"
      verify_params product_info, "type_id"
      verify_params product_info, "sku"
      verify_params product_info, "categories"
      verify_params product_info, "name"

	  begin
	  	product          =  Product.create_product product_info
	  rescue ActiveRecord::RecordNotUnique => err
	  	raise ApiException.new( Constant::HTTP_REQUEST_ERROR, "该商品sku已存在" ) 
	  end
	end
end