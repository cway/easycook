#encoding: utf-8
#author cway 2013-6-25

class EavAttribute < ActiveRecord::Base
  #acts_as_cached
  attr_accessible :entity_type_id, :attribute_code, :backend_type, :frontend_input, :frontend_label, :is_required, :default_value, :is_unique
  self.table_name = "eav_attribute"
end
