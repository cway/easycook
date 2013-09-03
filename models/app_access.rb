#encoding: utf-8
#author cway 2013-8-5

class AppAccess < ActiveRecord::Base
  #acts_as_cached
  attr_accessible :id, :app_key, :app_secret, :note
  self.table_name = "app_access"
end
