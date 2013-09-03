#encoding: utf-8
#author cway 2013-6-26

class BindToken < ActiveRecord::Base
  #acts_as_cached
  attr_accessible :token, :uid, :create_time

  validates :token,       :presence => true
  validates :uid,         :presence => true
  validates :create_time, :presence => true
end
