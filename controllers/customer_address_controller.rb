#encoding: utf-8
#author andy 2013-08-22

class CustomerAddressController

  def self.create( params )
    customer_id = params["customer_id"]
    addressee   = params["addressee"]
    telephone   = params["telephone"]
    homephone   = params["homephone"]
    province_id = params["province_id"]
    city_id     = params["city_id"]
    district_id = params["district_id"]
    street      = params["street"]
    postcode    = params["postcode"]
    is_default  = params["is_default"]

    unless customer_id and addressee and telephone and homephone and province_id and city_id and district_id and street and postcode
      raise ApiException.new( Constant::HTTP_REQUEST_ERROR, 
             "缺失参数(customer_id(String),addressee(String),telephone(String),homephone(String),province_id(int),city_id(int),district_id(int),street(String),postcode(String))") 	
    end

    begin
      province = AddressProvince.find( province_id )
      city     = AddressCity.find( city_id )
      district = AddressDistrict.find( district_id )
    rescue ActiveRecord::RecordNotFound
      raise ApiException.new( Constant::HTTP_NOT_FOUND, "未找到id对应的地区" )
    end

    customer = CustomerController.get_customer( customer_id )
    ca = Hash.new
    ca["customer_id"] = customer_id
    ca["addressee"]   = addressee
    ca["telephone"]   = telephone
    ca["homephone"]   = homephone
    ca["province"]    = province["name"]
    ca["city"]        = city["name"]
    ca["district"]    = district["name"]

    ca["province_id"] = province_id
    ca["city_id"]     = city_id
    ca["district_id"] = district_id

    ca["street"]      = street
    ca["postcode"]    = postcode
    customer_address = CustomerAddress.new( ca )

    count = CustomerAddress.count(:conditions => "customer_id = #{customer_id}")

    if customer_address.save  
      if is_default || count == 0
        customer.add_attribute( "default_address",customer_address["address_id"] )
      end
      return customer_address
    else
      raise ApiException.new( Constant::HTTP_SERVER_ERROR, "创建地址失败" )
    end
  end

  def self.get_addresses_by_customer_id( customer_id )
    CustomerController.get_customer( customer_id )
    addresses = CustomerAddress.where( "customer_id = #{customer_id}" )
    return addresses
  end

end
