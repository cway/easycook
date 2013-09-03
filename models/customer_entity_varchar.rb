#encoding: utf-8
#author cway 2013-8-5

class CustomerEntityVarchar < ActiveRecord::Base
  #acts_as_cached
  self.table_name = "customer_entity_varchar"
end