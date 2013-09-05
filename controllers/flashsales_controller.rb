#encoding:utf-8
#author cway 2013-06-23

class FlashsalesController < ApplicationController

  def self.get_by_date( date )
  	datetime                    = Time.parse(date).getlocal().strftime("%Y-%m-%d %H:%M:%S")
    conditions                  = "from_date <= \"#{datetime}\" and end_date >= \"#{datetime}\" and parent_rule_id = #{Constant::FLASHSALES_PARENT_ID}"
  	events                      = Eventrule.get_events( conditions )
  	ret_flashsales              = Array.new
  	events.each do |tmp_flashsales|
      flashsales                       = Hash.new
      flashsales['id']                 = tmp_flashsales.rule_id
      flashsales['from_date']          = tmp_flashsales.from_date
      flashsales['end_date']           = tmp_flashsales.end_date
      flashsales['customer_group_ids'] = tmp_flashsales.customer_group_ids
      flashsales['is_active']          = tmp_flashsales.is_active
      flashsales['products']           = EventProduct.get_event_products( flashsales['id'] )
      ret_flashsales                  << flashsales
  	end
  	ret_flashsales
  end

end