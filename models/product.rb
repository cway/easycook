#encoding: utf-8
#author andy 2013-08-28

class Product < ActiveRecord::Base
  #acts_as_cached
  self.table_name = "product_entity"

  #读取商品
  def self.get_product( product_id )
    product                              =  Hash.new
    product_entity                       =  self.find( product_id )
    attribute_set_id                     =  product_entity.attribute_set_id
    attributes_list                      =  EavEntityAttribute.get_attributes( { attribute_set_id: attribute_set_id} )
    attributes_list.each do |attribute|
     product[attribute.attribute_code]   =  get_product_attribute_value( product_id, attribute )
    end
    product['id']                        =  product_entity.entity_id
    product['sku']                       =  product_entity.sku 
    product['categories']                =  get_product_categories( product['id'] )
    configurable_attributes              =  get_product_configurable_attributes( product['id'] )
    unless configurable_attributes.empty?
      product['configurable_attributes']     =  configurable_attributes
      product['configurable_children_ids']   =  get_product_configurable_children( product['id'] )
    end
    product
  end

  #创建商品
  def self.create_product( product_info ) 
    product_entity                       =  Hash.new 
    product_entity['entity_type_id']     =  Constant::PRODUCT_TYPE_ID
    product_entity['attribute_set_id']   =  product_info["attribute_set_id"]
    product_entity['type_id']            =  product_info["type_id"]
    product_entity['sku']                =  product_info["sku"]    
    product                              =  self.new( product_entity )

    self.transaction do
      product.save

      add_attribures( product.entity_id, product_info )
     
      categories                        = product_info["categories"]
      unless categories.empty?
        add_categories( product.entity_id, categories )
      end

      if product_info.has_key? "configurable_attributes"
         add_configurable_attributes( product.entity_id, product_info["configurable_attributes"] )
         if product_info.has_key? "configurable_children_ids"
           add_relation_products( product.entity_id, product_info["configurable_children_ids"] )
         end
      end
    end
    product.entity_id
  end

  def self.update_product( product_info )
    product                                        = self.find(product_info["id"])
    attribute_list                                 = get_attributes(Constant::PRODUCT_TYPE_ID, product_info["attribute_set_id"])


    attribute_values                               = Hash.new 
     
    attribute_list.each do |attribute|
      if product_info.has_key? attribute.attribute_code and product_info[attribute.attribute_code] != ""
        attribute_values[attribute.attribute_code] =  product_info[attribute.attribute_code]
      end 
    end 
   
    self.transaction do
      update_product_attributes( product, attribute_values )
      CategoryProduct.where( :product_id => product.entity_id ).delete_all
      categories                                   = product_info["categories"]

      unless categories.empty?
        add_categories( product.entity_id, categories )
      end

      ProductRelation.where( :parent_id => product.entity_id ).delete_all
      if product_info.has_key? "configurable_children_ids"
        product_relations                         = Array.new
        product_info["configurable_children_ids"].each do |configurable_child_id|
          product_relation_params                 = Hash.new
          product_relation_params["parent_id"]    = product.entity_id
          product_relation_params["child_id"]     = configurable_child_id
          product_relations.push( product_relation_params )
        end
        ProductRelation.create( product_relations )
      end

      product.sku                                 = product_info['sku']
      product.updated_at                          = Time.now
      product.save
    end
  end

  #更新商品属性
  def self.update_product_attributes( product, attribute_values )
    
    attributes                    = get_update_attributes( attribute_values )  
 
    attributes.each do |attribute|
      if attribute["value"].class == String and attribute["value"].empty?
        next
      end

      update_product_attribute( product, attribute )
    end  
  end

  #更新属性
  def self.update_product_attribute( product, attribute )
      
    modelEntity                 = get_value_model( attribute.backend_type )
    if modelEntity
      entity_option             = { entity_type_id: Constant::PRODUCT_TYPE_ID, attribute_id: attribute.attribute_id, entity_id: product.entity_id}
       
      #modelEntity.create_with( value: attribute.value ).find_or_create_by( entity_option )
      entity_value              = modelEntity.where( entity_option ).first
      if entity_value
        entity_value.update_attributes( {:value => attribute.value } )
      else
        entity_value            = modelEntity.new( entity_option )
        entity_value.value      = attribute.value
        entity_value.save
      end
    end
  end

  #添加商品属性
  def self.add_attribures( product_id, product_info )
    attribute_list                                         =  get_attributes(Constant::PRODUCT_TYPE_ID, product_info["attribute_set_id"]) 
    attribute_types_and_value                              =  Hash.new
    attribute_list.each do |attribute|
      unless attribute_types_and_value.has_key? attribute.backend_type
        attribute_types_and_value[attribute.backend_type]  = Array.new 
      end

      if product_info.has_key? attribute.attribute_code
        if product_info[attribute.attribute_code].class == String and product_info[attribute.attribute_code].empty?
          next
        end
        insert_value                                       =  Hash.new
        insert_value['attribute_id']                       =  attribute.attribute_id
        insert_value['entity_id']                          =  product_id
        insert_value['value']                              =  product_info[attribute.attribute_code]
        attribute_types_and_value[attribute.backend_type].push( insert_value )
      end  
    end
    attribute_types_and_value.each do | type, type_values |
      insert_entity_values( type_values, type )
    end
  end

  #插入商品属性值
  def self.insert_entity_values( type_values, type )
    if type_values.empty?
      return 
    end

    values                                                 = Array.new
    type_values.each do | value_entity |
    entity_value                                           = {
                                                                :entity_type_id => Constant::PRODUCT_TYPE_ID,
                                                                :attribute_id   => value_entity['attribute_id'],
                                                                :entity_id      => value_entity['entity_id'],
                                                                :value          => value_entity['value']
                                                              }
      if entity_value[:value].class == Array
        entity_value[:value]                               = entity_value[:value].to_json
      end
      values.push( entity_value )
    end
    
    modelEntity                                            = get_value_model( type )
    if modelEntity
      modelEntity.create( values )
    end 
  end

  #插入可配置属性列表
  def self.add_configurable_attributes(  product_id, configurable_attributes )
    configurable_attributes                   = Array.new
    sort                                      = 0
    configurable_attributes.each do | configurable_attribute_id |
      configurable_attribute                  = Hash.new
      configurable_attribute["product_id"]    = product_id
      configurable_attribute["attribute_id"]  = configurable_attribute_id
      configurable_attribute["sort"]          = sort
      sort                                   += 1
      configurable_attributes.push( configurable_attribute )
    end
    ProductConfigurableAttribute.create( configurable_attributes )
  end

  #添加商品类目
  def self.add_categories( product_id, categories )
    if categories.empty?
      return
    end
    
    values                        = Array.new
    categories.each do | category_id |
      categort_product            = {
                                      :category_id      => category_id,
                                      :product_id       => product_id
                                    }
      values <<  categort_product
    end
    
    CategoryProduct.create( values )
  end

  #添加配置管联商品
  def self.add_relation_products parent_product_id, configurable_children_ids
    configurable_children_ids.each do |simple_product_id|
      product_relation_params                 = Hash.new
      product_relation_params["parent_id"]    = parent_product_id
      product_relation_params["child_id"]     = simple_product_id
      ProductRelation.create( product_relation_params )
    end
  end

  #获取商品属性值模型
  def self.get_value_model( backend_type )
    modelEntity                 = nil
    case backend_type
      when "varchar"
        modelEntity             = ProductEntityVarchar
      when "decimal"            
        modelEntity             = ProductEntityDecimal
      when "int"
        modelEntity             = ProductEntityInt
      when "media_gallery"
        modelEntity             = ProductEntityMediaGallery
      when "text"
        modelEntity             = ProductEntityText
      when "timestamp"
        modelEntity             = ProductEntityTimestamp
    end
    modelEntity
  end

  #获取商品属性列表带group
  def self.get_attributes( product_type_id, attribute_set_id)
    EavAttribute.find_by_sql( "select eav_attribute.attribute_code, eav_attribute.attribute_id, eav_attribute.backend_type, eav_attribute.frontend_label, eav_attribute.frontend_input, eav_attribute.is_required, eav_attribute_group.attribute_group_id, eav_attribute_group.attribute_group_name from eav_entity_attribute left join eav_attribute_group on eav_attribute_group.attribute_group_id = eav_entity_attribute.attribute_group_id left join eav_attribute on eav_attribute.attribute_id = eav_entity_attribute.attribute_id  where eav_entity_attribute.entity_type_id = #{product_type_id} and eav_entity_attribute.attribute_set_id = #{attribute_set_id}" )
  end

  #获取商品属性值
  def self.get_product_attribute_value( product_id, attribute )
    modelEntity                 = get_value_model( attribute.backend_type )
    attribute_value             = modelEntity.where( { entity_id: product_id, attribute_id: attribute.attribute_id} ).first
    

    ret_value                   = attribute_value ? attribute_value.value : attribute.backend_type == "media_gallery" ? "[]" : ""
    if attribute.backend_type == "media_gallery"
      ret_value =  JSON.parse( ret_value )
    end
    ret_value
  end

  #获取商品类目
  def self.get_product_categories( product_id )
    category_ids                = CategoryProduct.where( {product_id: product_id} )

    categories                  = Array.new
    category_ids.each do |category_id|
      begin
        categories_name         = Category.get_categories_name( category_id )
        categories             << categories_name[category_id]
      rescue Exception => e
      end
    end
    categories 
  end

  #获取商品可配置属性
  def self.get_product_configurable_attributes( product_id )
    configurable_attributes     = Array.new
    configurable_attribute_ids  = ProductConfigurableAttribute.select("attribute_id").where( { product_id: product_id} )

    configurable_attribute_ids.each do |configurable_attribute|
      begin
        attribute               = EavAttribute.find( configurable_attribute["attribute_id"] )
        configurable_attributes << attribute.attribute_code
      rescue Exception => e 
      end
    end
    configurable_attributes
  end

  #获取商品可配置属性
  def self.get_product_configurable_children( product_id )
    configurable_children       = Array.new
    configurable_children_ids   = ProductRelation.select("child_id").where({ parent_id: product_id })
    configurable_children_ids.each do |configurable_child|
      configurable_children    << configurable_child.child_id
    end 
    configurable_children
  end

  #下架商品
  def self.delete_product( product_id )
    product                     = Product.find(params[:id])
    product.update_attribute("is_active", 0);
  end

  private
  #获取需更新的属性
  def self.get_update_attributes( attribute_values )
    attributes                          = Array.new
    attribute_values.each do |attribute_code, attribute_value|
       attribute_info                   = EavAttribute.where( {attribute_code: attribute_code, entity_type_id: Constant::PRODUCT_TYPE_ID} ).first
       if attribute_info
         attribute_info                 = attribute_info
         
         if attribute_value.class == Array
            attribute_info.value        = attribute_value.to_json
         else
            attribute_info.value        = attribute_value
         end

         attributes.push( attribute_info )
       end 
    end
    attributes
  end
end