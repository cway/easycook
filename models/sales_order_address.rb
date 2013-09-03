#encoding: utf-8
#author andy 2013-08-09

class SalesOrderAddress < ActiveRecord::Base
  self.table_name = "sales_order_address"


  def self.get_by_id ( id )
    sales_order_address = SalesOrderAddress.find_by_entity_id( id )
    return sales_order_address
  end
end