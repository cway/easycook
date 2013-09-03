#encoding: utf-8
#author andy 2013-08-20

class SalesOrderItem < ActiveRecord::Base
  # attr_accessor :thumb
  attr_accessible :item_id, :order_id, :created_at, :updated_at, :product_id, :weight, :is_virtual, :sku, :name, :description, :applied_rule_ids, :qty_orderd, :qty_shipped, :base_cost, :base_price, :total_price
  self.table_name = "sales_order_items"
end
