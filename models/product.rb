#encoding: utf-8
#author cway 2013-6-25

class Product < ActiveRecord::Base
  #acts_as_cached
  # attr_accessor :conf_attrs,:childen
  self.table_name = "product_entity"

  def self.get_names_images_in_entity_ids ( ids )
    names   = self.get_names_in_entity_ids ( ids )
    images  = self.get_images_in_entity_ids ( ids )
    return { :name => names, :image => images}
  end

  def self.get_product_by_id ( id,fields=nil )
    attrs   = self.get_attributes( fields )
    unless attrs
      return
    end
    begin
      product = self.find(id)  
    rescue ActiveRecord::RecordNotFound
      return nil
    end
    attrs.each do |attribute|
      value = self.get_product_attribute_value( id, attribute )
      if attribute.attribute_code == "image"
        begin
          value = JSON.parse( value )
        rescue => error
          value = nil
        end
      end
      product[attribute.attribute_code] = value
    end

    conf_attrs = self.get_configurable_attribute ( id )
    product["conf_attrs"] = conf_attrs

    childen = self.get_childen ( id )
    product["childen"] = childen
    return product
  end

 private
  def self.get_names_in_entity_ids ( ids )
  	name                          = self.find_by_sql("select * from eav_attribute where `attribute_code` = 'name' and `entity_type_id` = #{ConstantValue::PRODUCT_TYPE_ID} limit 1")
    name_values                   = self.all_attribute_values( name[0] )
  end

  def self.get_images_in_entity_ids ( ids )
  	image                         = self.find_by_sql("select * from eav_attribute where `attribute_code` = 'image' and `entity_type_id` = #{ConstantValue::PRODUCT_TYPE_ID} limit 1")
    image_values                  = self.all_attribute_values( image[0] )
  end

  def self.get_product_attribute_value( product_id, attribute ) 
    value = ""
    case attribute.backend_type
      when "varchar"
        attribute_entity          = ProductEntityVarchar.first( :conditions => { :entity_id => product_id , :attribute_id => attribute.attribute_id}, :select => "value" ) 
      when "int"
        attribute_entity          = ProductEntityInt.first( :conditions => { :entity_id => product_id , :attribute_id => attribute.attribute_id}, :select => "value" )
      when "decimal"
        attribute_entity          = ProductEntityDecimal.first( :conditions => { :entity_id => product_id , :attribute_id => attribute.attribute_id}, :select => "value" )
      when "text"
        attribute_entity          = ProductEntityText.first( :conditions => { :entity_id => product_id , :attribute_id => attribute.attribute_id}, :select => "value" )
      when "media_gallery"
        attribute_entity          = ProductEntityMediaGallery.first( :conditions => { :entity_id => product_id , :attribute_id => attribute.attribute_id}, :select => "value" )
    end
 
    if attribute_entity
      value                       = attribute_entity['value']
    end
    return value
  end

  def self.all_attribute_values( attribute )
    values                        = Array.new
    ret_value_list                = Hash.new
    case attribute.backend_type
      when "varchar"
        values                    = ProductEntityVarchar.find_all_by_attribute_id( attribute.attribute_id ) 
      when "int"
        values                    = ProductEntityInt.find_all_by_attribute_id( attribute.attribute_id )
      when "decimal"
        values                    = ProductEntityDecimal.find_all_by_attribute_id( attribute.attribute_id )
      when "media_gallery"
        values                    = ProductEntityMediaGallery.find_all_by_attribute_id( attribute.attribute_id )
    end

    values.each do |value_info|
      ret_value_list[ value_info.entity_id ] = value_info.value
    end

    return ret_value_list
  end

  def  self.get_attributes ( fields )
    if fields
      field_strings = nil
      fields.each do |field|
        field_strings = "'"+field+"'" unless field_strings
        field_strings += ",'"+field+"'" if field_strings
      end
      attrs = self.find_by_sql("select * from eav_attribute where `entity_type_id` = #{ConstantValue::PRODUCT_TYPE_ID} and attribute_code in (#{field_strings})")
    else
      attrs = self.find_by_sql("select * from eav_attribute where `entity_type_id` = #{ConstantValue::PRODUCT_TYPE_ID}")
    end
    unless attrs
      return
    end
    return attrs
  end

  def self.get_configurable_attribute ( id )
    attrs = self.find_by_sql("select eav_attribute.* from product_configurable_attribute 
      left join eav_attribute on product_configurable_attribute.`attribute_id` = `eav_attribute`.`attribute_id` 
      where product_configurable_attribute.product_id = #{id}")
    unless attrs
      return
    end
    return attrs
  end


  def self.get_childen ( id )
    childen = self.find_by_sql("select `product_entity`.* from `product_relation` left join `product_entity` on 
      `product_relation`.`child_id` = `product_entity`.`entity_id` 
      where `product_relation`.`parent_id` = #{id}")
    unless childen
      return
    end
    return childen
  end
end
