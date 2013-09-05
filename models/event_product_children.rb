#encoding: utf-8
#author cway 2013-08-18

class EventProductChildren < ActiveRecord::Base
  #attr_accessible :parent_event_product_id, :product_id, :rule_price, :normal_price, :qty
  self.table_name                  =  "event_product_children"


  def self.get_event_product_children( parent_event_product_id )
  	products                       = Array.new
    event_products                 = self.where( {parent_event_product_id: parent_event_product_id} )
    event_products.each do | event_product |
      product                      = ProductController.get( event_product.product_id )
      product['id']                = event_product.product_id
      product['rule_price']        = event_product.rule_price
      product['normal_price']      = event_product.normal_price
      product['qty']               = event_product.qty
      products                    << product
    end
    products 
  end 

  def self.update_event_product_children ( event_product_id, event_product_children )
    self.where( :parent_event_product_id => event_product_id ).delete_all
    product_children                                  = Array.new
    event_product_children.each do |child_id, child_product|
      child_product_param                             = Hash.new
      child_product_param['parent_event_product_id']  = event_product_id
      child_product_param['product_id']               = child_product['entity_id']
      child_product_param['rule_price']               = child_product['rule_price']
      child_product_param['normal_price']             = child_product['price']
      child_product_param['qty']                      = child_product['qty']
      product_children << child_product_param
    end
    unless product_children.empty?
      self.create( product_children )
    end
  end
end