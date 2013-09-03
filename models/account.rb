#encoding: utf-8
#author cway 2013-6-29

class Account < ActiveRecord::Base
  #acts_as_cached
  attr_accessible :id, :name, :password, :wechat_id, :balance
  
  validates :name,       :presence => true
end
