#encoding: utf-8
#author andy 2013-8-8

class SalesOrder < ActiveRecord::Base
  default_scope order: 'entity_id desc'
  self.table_name = "sales_order"

  def load_items_delay
  	items = SalesOrderItem.select(:item_id).select(:name).select(:product_id).where( "order_id = #{self["entity_id"]}" )
  	self["items"] = items
  	return self
  end

  def load_items
  	items = SalesOrderItem.where( "order_id = #{self["entity_id"]}" )
  	self["items"] = items
  	return self
  end
end