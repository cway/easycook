#encoding: utf-8
#author cway 2013-6-23

class ReceiveMessage < ActiveRecord::Base
  #acts_as_cached
  attr_accessible :msg_id, :uid, :msg_type, :content, :receive_time, :create_time
  
  validates :msg_id,       :presence => true
  validates :uid,          :presence => true
  validates :receive_time, :presence => true 
  validates :create_time,  :presence => true 
end
