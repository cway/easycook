#encoding: utf-8
#author andy 2013-08-22

class CustomerAddress < ActiveRecord::Base
  #acts_as_cached
  attr_accessible :address_id, :customer_id, :addressee, :telephone, :homephone, :province, :province_id , :city_id, :city, :district_id, :district, :street, :postcode
  self.table_name                   = "customer_address"
  
end
