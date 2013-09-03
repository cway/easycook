#encoding: utf-8
#author andy 2013-08-08

class SalesOrderController

  def self.show ( order_id )
    begin
      sales_order         = SalesOrder.find ( order_id )
      sales_order.load_items
    rescue ActiveRecord::RecordNotFound
      raise ApiException.new( Constant::HTTP_NOT_FOUND, "未找到订单" )
    end
    return sales_order
  end

  def self.get_orders_by_customer_id ( customer_id,params = nil )
    CustomerController.get_customer( customer_id )

    limit         = Constant::PARAM_VALUE_LIMIT
    if params[:limit]
      limit         = params[:limit].to_i
    end
      limit = Constant::PARAM_VALUE_LIMIT_MAX if limit > Constant::PARAM_VALUE_LIMIT_MAX
    if params[:since]
      since           = params[:since]
      sales_orders = SalesOrder.unscoped.select(:base_price).select(:entity_id).select(:status).select(:created_at).where( "customer_id = ? and entity_id > ?",customer_id,since ).limit(limit)
    end
    if params[:max]
      max         = params[:max]
      sales_orders = SalesOrder.select(:base_price).select(:entity_id).select(:status).select(:created_at).where( "customer_id = ? and entity_id < ?",customer_id,max ).limit(limit)
    end
    unless params[:since] or params[:max]
      sales_orders = SalesOrder.select(:base_price).select(:entity_id).select(:status).select(:created_at).where( "customer_id = ?",customer_id ).limit(limit)
    end

    sales_orders.each do |order|
      order.load_items_delay
      order["items"].each do |item|
        p = Product.get_product_by_id(item["product_id"],["image"])
        item["thumb"] = p["image"]
      end
    end
    return sales_orders
  end

  def self.create ( params )
    customer_id           = params["customer_id"]
    product_ids           = params["event_product_ids"]
    remote_ip             = params["remote_ip"]
    customer_address_id   = params["customer_address_id"]
    
    if params["coupon_code"]
    	#TODO 验证s优惠码
    end
    unless customer_id and product_ids and remote_ip and product_ids.class.to_s == Array.to_s and !product_ids.empty?
      raise ApiException.new( 
        Constant::HTTP_REQUEST_ERROR, 
        "缺失参数或者格式不正确(customer_id(String),product_ids(Array),remote_ip(String))" 
        )
    end
    customer  = CustomerController.get_customer( customer_id )
    products  = Array.new
    price     = 0
    weight    = 0
    product_ids.each do |epid|
      event_product = FlashsalesController.get_event_products_by_event_product_id( epid )
      if event_product
        product = event_product["product"]
        products << event_product if product
        price    += event_product["rule_price"].to_i if event_product["end_seconds"] >= 0
        price    += event_product["normal_price"].to_i if event_product["end_seconds"] < 0
        weight   += product["weight"].to_i
      end
    end
    if products.empty?
      raise ApiException.new( 
        Constant::HTTP_REQUEST_ERROR, 
        "所选的商品都不存在" 
        )
    end

    unless customer_address_id
      customer_address_id = customer.get_attribute_value( "default_address" )
    end

    customer_address = nil
    if customer_address_id
      customer_address = CustomerAddress.find_by_address_id_and_customer_id( customer_address_id,customer_id )
    end

    unless customer_address
      raise ApiException.new( 
        Constant::HTTP_REQUEST_ERROR, 
        "没有设置送货地址" 
        )
    end

    sales_order = Hash.new
    sales_order["customer_id"]         = params["customer_id"]
    sales_order["customer_group_id"]   = ConstantValue::NORMAL_CUSTOMER_GROUD_ID
    sales_order["remote_ip"]           = remote_ip
    sales_order["status"]              = ConstantValue::PENDING_SALES_ORDER_STATUS
    sales_order["base_price"]          = price
    sales_order["grand_total"]         = price
    sales_order["weight"]              = weight
    sales_order["customer_name"]       = customer.get_attribute_value( "name" )

    @sales_order = SalesOrder.new( sales_order )
    if @sales_order.save

      sales_order_address = Hash.new
      sales_order_address["customer_address_id"] = customer_address_id
      sales_order_address["customer_id"]         = customer_id
      sales_order_address["order_id"]            = @sales_order["entity_id"]
      sales_order_address["addressee"]           = customer_address["addressee"]
      sales_order_address["province"]            = customer_address["province"]
      sales_order_address["city"]                = customer_address["city"]
      sales_order_address["district"]            = customer_address["district"]
      sales_order_address["street"]              = customer_address["street"]
      sales_order_address["telephone"]           = customer_address["telephone"]
      sales_order_address["postcode"]            = customer_address["postcode"]
      @sales_order_address                       = SalesOrderAddress.new( sales_order_address )
      @sales_order_address.save

      @sales_order["shipping_address_id"] = @sales_order_address["entity_id"]
      @sales_order.save

      products.each do |event_product|
        product = event_product["product"]
        sales_order_item               = Hash.new
        sales_order_item["order_id"]   = @sales_order["entity_id"]   
        sales_order_item["product_id"] = product["entity_id"]
        sales_order_item["weight"]     = product["weight"]
        sales_order_item["is_virtual"] = product["type_id"] == ConstantValue::VIRTUAL_PRODUCT_TYPE_ID
        sales_order_item["sku"]        = product["sku"]
        sales_order_item["name"]       = product["name"]
        sales_order_item["description"]= product["description"]
        sales_order_item["applied_rule_ids"] = event_product["rule_id"]
        sales_order_item["qty_orderd"] = 1
        sales_order_item["base_price"] = event_product["rule_price"].to_i if event_product["end_seconds"] >= 0
        sales_order_item["base_price"] = event_product["normal_price"].to_i if event_product["end_seconds"] < 0
        sales_order_item["total_price"]= sales_order_item["base_price"]
        @sales_order_item = SalesOrderItem.new( sales_order_item )
        @sales_order_item.save
      end
      return @sales_order
    else
      raise ApiException.new( Constant::HTTP_SERVER_ERROR, "下单失败" )
    end
  end
end
