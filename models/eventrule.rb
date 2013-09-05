#encoding: utf-8
#author cway 2013-07-26

class Eventrule < ActiveRecord::Base
  self.table_name = "eventrule"  

  def self.get_events( conditions )
  	self.where( conditions )
  end

end