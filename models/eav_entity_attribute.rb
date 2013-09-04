#encoding: utf-8
#author cway 2013-09-04

class EavEntityAttribute < ActiveRecord::Base 
  self.table_name                    = "eav_entity_attribute"

  #获取属性集
  def self.get_attributes( conditions )
  	attributes                       = Hash.new
  	attribute_entity_ids             = self.select("attribute_id").where( conditions )          
  	attribute_entity_ids.each do |attribute_entity_info|
  	  begin
  	  	attribute                    = EavAttribute.find( attribute_entity_info.attribute_id )
  	  	attributes                  << attribute
  	  rescue Exception => e 
  	  end  
  	end
  	attributes
  end

end