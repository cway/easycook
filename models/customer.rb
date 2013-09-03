#encoding: utf-8
#author cway 2013-8-2

class Customer < ActiveRecord::Base
  #acts_as_cached
  attr_accessible :entity_id, :entity_type_id, :attribute_set_id, :group_id, :email, :created_at, :updated_at, :is_active
  self.table_name                   = "customer_entity"  

  def self.find_by_attribute_and_value ( attribute,value )
    attribute_info                = EavAttribute.find_by_attribute_code( attribute )
    value_entity                  = CustomerEntityVarchar.find_by_attribute_id_and_value( attribute_info["attribute_id"], value )
    customer                      = nil
    if value_entity
      customer                    = Customer.find ( value_entity.entity_id )
    end
    return customer ? customer : false 
  end
  
  def self.create_platfom_customer( customer_info )
    begin
      # self.transcation do

        now                                 = Time.now
        customer_params                     = Hash.new
        customer_params["entity_type_id"]   = ConstantValue::CUSTOMER_TYPE_ID
        customer_params["attribute_set_id"] = ConstantValue::CUSTOMER_TYPE_ID
        customer_params["group_id"]         = ConstantValue::NORMAL_CUSTOMER_GROUD_ID
        customer_params["created_at"]       = now
        customer_params["updated_at"]       = now
        customer_params["is_active"]        = ConstantValue::ENTITY_IS_ACTIVE
        customer                            = Customer.new( customer_params )
        customer.save
        customer_attributes                   = Hash.new

        platform_name = customer_info["platform_name"]
        customer_attributes[platform_name + "_id"]         = customer_info["id"]
        customer_attributes[platform_name + "_name"]       = customer_info["name"]
        customer_attributes[platform_name + "_token"]      = customer_info["token"] if customer_info["token"]
        customer_attributes["name"]                        = customer_info["name"]
        attribute_values                                   = Hash.new

        customer_attributes.each do |attribute_key, attrbute_value|
          attribute_info                      = EavAttribute.find_by_attribute_code_and_entity_type_id( attribute_key,ConstantValue::CUSTOMER_TYPE_ID )
          unless attribute_info
            next
          end
          attribute                           = Hash.new
          attribute["attribute_id"]           = attribute_info["attribute_id"]
          attribute["entity_id"]              = customer.entity_id
          attribute["entity_type_id"]         = customer.entity_type_id
          attribute["value"]                  = attrbute_value
          unless attribute_values.has_key? attribute_info["backend_type"]
            attribute_values[attribute_info["backend_type"]]  =  Array.new
          end
        
          attribute_values[attribute_info["backend_type"]].class
          attribute_values[attribute_info["backend_type"]].push( attribute )
        end
        self.add_customer_attributes( attribute_values )

        wechat_id                           = customer_info["wechat_id"]

        if wechat_id
          customer.add_attribute( "wechat_id", wechat_id )
        end

        return customer
      # end
    rescue => err
      puts err
      return false 
    end
    return true
  end

  def add_attribute( attribute_code, value )
    attribute_info                      = EavAttribute.find_by_attribute_code_and_entity_type_id( attribute_code,self.entity_type_id )
    attribute = CustomerEntityVarchar.find_by_entity_type_id_and_attribute_id_and_entity_id( self.entity_type_id,attribute_info["attribute_id"],self.entity_id )
    if attribute
      attribute.update(value: value)
    else
      attribute                           = Hash.new  
      attribute["attribute_id"]           = attribute_info["attribute_id"]
      attribute["entity_id"]              = self.entity_id
      attribute["entity_type_id"]         = self.entity_type_id
      attribute["value"]                  = value
      cev = CustomerEntityVarchar.new(attribute)
      cev.save
    end
  end

  def get_attribute_value( attribute_code )
    attribute_info                      = EavAttribute.find_by_attribute_code_and_entity_type_id( attribute_code,self.entity_type_id )
    attribute = CustomerEntityVarchar.find_by_entity_type_id_and_attribute_id_and_entity_id( self.entity_type_id,attribute_info["attribute_id"],self.entity_id )
    if attribute
      return attribute["value"]
    end
  end

  def self.add_customer_attributes( attribute_values  )
    puts attribute_values
    attribute_values.each do |backend_type, backend_values|
      values                                = Array.new
      puts backend_values
      backend_values.each do |attribute_value|
        values << "(#{attribute_value['entity_id']}, #{attribute_value['attribute_id']}, #{attribute_value['entity_type_id']}, \"#{attribute_value['value']}\")"
      end
      ActiveRecord::Base.connection().insert("INSERT INTO `customer_entity_#{backend_type}` (`entity_id`, `attribute_id`, `entity_type_id`, `value`)  VALUES #{values.join(',')}")
    end
  end
end
