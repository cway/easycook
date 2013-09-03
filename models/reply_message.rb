#encoding: utf-8
#author cway 2013-6-24

class ReplyMessage < ActiveRecord::Base
  #acts_as_cached
  attr_accessible :msg_id, :uid, :msg_type, :content, :reply_type, :create_time, :note
  
  validates :msg_id,       :presence => true
  validates :uid,          :presence => true
  validates :create_time,  :presence => true 
end
