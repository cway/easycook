#encoding: utf-8
#author cway 2013-07-26

class EventProduct < ActiveRecord::Base
  self.table_name                       = "event_product"  

  def self.get_event_products( rule_id )
  	products                            = Array.new
  	event_products                      = self.where( { rule_id: rule_id } )
  	event_products.each do |event_product|
  	  product                           = ProductController.get( event_product.product_id )
  	  product['id']                     = event_product.product_id
  	  product['from_date']              = event_product.from_date
  	  product['end_date']               = event_product.end_date
  	  product['action_operator']        = event_product.action_operator
  	  product['action_amount']          = event_product.action_amount
  	  product['rule_price']             = event_product.rule_price
  	  product['normal_price']           = event_product.normal_price
  	  product['qty']                    = event_product.qty
  	  product['flashsales_children']    = EventProductChildren.get_event_product_children( product['product_id'] )
  	   
  	  products                    <<    product
  	end
  	products
  end

end