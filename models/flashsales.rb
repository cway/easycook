#encoding: utf-8
#author cway 2013-6-25

class Flashsales < ActiveRecord::Base
  #acts_as_cached
  default_scope order: 'event_product_id desc'
  attr_accessible :event_product_id, :rule_id, :from_date, :end_date, :rule_price, :normal_price, :qty
  self.table_name = "event_product"

  def self.get_event_products_by_event_product_id ( event_product_id )
    event_product       =   Flashsales.find_by_event_product_id( event_product_id )
    unless event_product
      return 
    end
    return event_product
  end

  def self.get_flashsales_by_date( date )
    eventrule       =   Eventrule.find_by_parent_rule_id_and_from_date( ConstantValue::FLASHSALES_RULE_ID, date )
    unless eventrule
      return 
    end
    
    if eventrule.is_active == ConstantValue::ENTITY_IS_NOT_ACTIVE
      return
    end 
 
    eventrule_id    =   eventrule.rule_id
    flashsales      =   self.find_all_by_rule_id( eventrule_id )
    eventrule["event_products"] = flashsales
    return eventrule
  end

end
