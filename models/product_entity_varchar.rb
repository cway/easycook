#encoding: utf-8
#author cway 2013-6-25

class ProductEntityVarchar < ActiveRecord::Base
  #acts_as_cached
  attr_accessible :entity_type_id, :attribute_id, :entity_id, :value
  self.table_name = "product_entity_varchar"
  
end
