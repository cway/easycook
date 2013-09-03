#encoding: utf-8
#author cway 2013-08-02

class FlashsalesController

  def self.get_flashsales ( params )
    flashsales          = nil
    date                = params[:date]
    flashsales          = Eventrule.get_by_date( date )

    unless flashsales
      raise ApiException.new( Constant::HTTP_NOT_FOUND,"未找到资源" )
    end
    result              = flashsales
 
    unless params[:data_size].to_i == Constant::DATA_SIZE_LIGHT
      if flashsales
        limit         = Constant::PARAM_VALUE_LIMIT
        if params[:limit]
          limit         = params[:limit].to_i
        end
        limit = Constant::PARAM_VALUE_LIMIT_MAX if limit > Constant::PARAM_VALUE_LIMIT_MAX
        if params[:max]
          max           = params[:max]
          flashsales.load_event_products( Constant::PARAM_NAME_MAX, max, limit )
        elsif params[:since]
          since         = params[:since]
          flashsales.load_event_products( Constant::PARAM_NAME_SINCE, since, limit )
        else
          flashsales.load_event_products( nil, nil, limit )
        end
        result          = self.change_to_products( flashsales )
      end 
    end

    return result
  end

  def self.get_event_products_by_event_product_id ( event_product_id )
    event_product                  = Flashsales.get_event_products_by_event_product_id ( event_product_id )
    if event_product
      result                       = self.set_product( event_product )
      event_product["end_seconds"] = event_product["end_date"].to_i - Time.now.to_i
    end
    return result
  end

  private

  def self.set_product ( event_product )
    product                        = Product.get_product_by_id ( event_product["product_id"] )
    if product
      event_product["product"]     = product
    end
    return event_product
  end

  def self.change_to_products ( eventrule )
    event_products                        = eventrule["event_products"]
    names_images                          = Product.get_names_images_in_entity_ids( nil )
    flashsales_array                      = Array.new
    if !event_products or event_products.empty?
      eventrule["event_products"]           = flashsales_array
      return eventrule
    end
    event_products.each do |flashsales|
      flashsales_hash                     = Hash.new
      flashsales_hash["rule_id"]          = flashsales["rule_id"]
      flashsales_hash["event_product_id"] = flashsales["event_product_id"]
      flashsales_hash["product_id"]       = flashsales["product_id"]
      if names_images[:image][flashsales["product_id"]]
        begin
          images = JSON.parse( names_images[:image][flashsales["product_id"]] )
          if images.length > 0
            new_images                     = Array.new
            new_images[0]                  = images.first
            flashsales_hash["images"]      = new_images
          end
        rescue Exception => e       
        end
      end
      flashsales_hash["name"]             = names_images[:name][flashsales["product_id"]]
      flashsales_hash["rule_price"]       = flashsales["rule_price"]
      flashsales_hash["normal_price"]     = flashsales["normal_price"]
      flashsales_array << flashsales_hash
    end
    eventrule["event_products"]           = flashsales_array
    return eventrule
  end

end
