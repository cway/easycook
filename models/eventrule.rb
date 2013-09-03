#encoding: utf-8
#author cway 2013-6-25

class Eventrule < ActiveRecord::Base
  #acts_as_cached
  # attr_accessor :end_seconds,:event_products
  attr_accessible :rule_id, :parent_rule_id, :name, :description, :from_date, :to_date, :customer_group, :is_active
  self.table_name = "eventrule"



  def self.get_by_date( date )
    eventrule       =   Eventrule.find_by_parent_rule_id_and_from_date( ConstantValue::FLASHSALES_RULE_ID, date )
    unless eventrule
      return 
    end
    
    if eventrule.is_active == ConstantValue::ENTITY_IS_NOT_ACTIVE
      return
    end 
    eventrule["end_seconds"] = eventrule["end_date"].to_i - Time.now.to_i
    return eventrule
  end

  def load_event_products( since_or_max,id,limit )
    if self.is_active == ConstantValue::ENTITY_IS_NOT_ACTIVE
      return
    end 
    if since_or_max == "since"
      flashsales = Flashsales.unscoped.where("rule_id = ? and event_product_id > ?",self.rule_id,id.to_i).limit(limit)
    elsif since_or_max == "max"
      flashsales = Flashsales.where("rule_id = ? and event_product_id < ?",self.rule_id,id.to_i).limit(limit)
    else
      flashsales = Flashsales.where("rule_id = ?",self.rule_id).limit(limit)
    end
    self["event_products"] = flashsales
  end
end
