#encoding:utf-8
#author cway 2013-06-23

class ProductController < ApplicationController
	def self.create( product_info )
	  verify_params product_info, "attribute_set_id"
      verify_params product_info, "type_id"
      verify_params product_info, "product_type_id"
      verify_params product_info, "sku"
      verify_params product_info, "categories"
	  product          =  Product.create_product product_info

	end
end