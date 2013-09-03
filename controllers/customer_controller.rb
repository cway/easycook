#encoding: utf-8
#author cway 2013-08-02
require 'hmac-sha1'

class CustomerController

  def self.get_customer( customer_id )
    begin
      customer         = Customer.find( customer_id )
    rescue ActiveRecord::RecordNotFound
      raise ApiException.new( Constant::HTTP_NOT_FOUND, "未找到用户" )
    end
    unless customer[:is_active]
      raise ApiException.new( Constant::HTTP_FORBIDDEN, '用户被禁用' )
    end
    return customer
  end

  def self.get_auth_token(app_key,open_id)
    now_time         = Time.now.to_i
    token            = Digest::SHA1.hexdigest( open_id )
    auth_token       = Base64.strict_encode64( token + ":" + now_time.to_s )
    unless CACHE.read( token )
      unless CACHE.write( token , app_key, {:expires_in => 300} )
        failed( Constant::HTTP_SERVER_ERROR, "something wrong cache service" )
      end
    end
    success( Constant::HTTP_REQUEST_SUCCESS,auth_token )
  end

  def self.bind_platform( customer_info ) 

    platform               = customer_info["platform_name"]
    customer_id            = customer_info["id"]
    customer_name          = customer_info["name"]

    unless platform && customer_id && customer_name
      raise ApiException.new( Constant::HTTP_REQUEST_ERROR, "参数缺失（platform_name,id,name）" )
    end

    wechat_customer        = nil
    wechat_id              = customer_info["wechat_id"]
    if wechat_id
      wechat_customer      = Customer.find_by_attribute_and_value( "wechat_id",wechat_id )
    end
     
    platform_customer      = Customer.find_by_attribute_and_value( platform + "_id",customer_id )
     
    if wechat_customer and platform_customer and wechat_customer.entity_id != platform_customer.entity_id
      raise ApiException.new( Constant::HTTP_CONFLICT, '用户已经绑定' )
    end

    if wechat_customer and !platform_customer
      wechat_customer.add_attribute( platform+"_id",customer_id )
      wechat_customer.add_attribute( platform+"_name",customer_name )
      wechat_customer.add_attribute( platform+"_token",customer_info["token"] ) if customer_info["token"]
      wechat_customer.add_attribute( "name",customer_name )
      customer              = wechat_customer
    end

    if !wechat_customer and platform_customer
      if wechat_id
        wechat_customer.add_attribute( "wechat_id",wechat_id )
      end
      customer              = platform_customer
    end

    if wechat_customer and platform_customer and wechat_customer.entity_id == platform_customer.entity_id
      customer              = wechat_customer
    end

    unless customer
      customer              = Customer.create_platfom_customer( customer_info )       
    end

    if customer
      unless customer["is_active"]
        raise ApiException.new( Constant::HTTP_FORBIDDEN, '用户被禁用' )
      end
      return customer
    else
       raise ApiException.new( Constant::HTTP_SERVER_ERROR, '绑定用户失败' )
    end
  end
end
