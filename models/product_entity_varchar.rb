#encoding: utf-8
#author cway 2013-07-23

class ProductEntityVarchar < ActiveRecord::Base
  #attr_accessible :entity_type_id, :attribute_id, :entity_id, :value
  self.table_name  =  "product_entity_varchar"

  def self.get_attribute_value( product_id, attribute_id )
    attribute     = self.where({ entity_id: product_id, attribute_id: attribute_id }).first
    ret_value     = nil
    unless attribute
      ret_value   = attribute.value
    end
    ret_value
  end
end
