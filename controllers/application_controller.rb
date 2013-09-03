#encoding:utf-8
#author cway 2013-06-23

class ApplicationController < Sinatra::Base

  # def self.success( code, data )
  #   ret_data            =   Hash.new
  #   ret_data["status"]  =   1
  #   ret_data["data"]    =   data
  #   ret_data.to_json
  #   [code, {"Content-Type" => "text/json"}, [ret_data.to_json]]
  # end

  # def self.failed( code, err_msg )
  #   ret_data            =   Hash.new
  #   ret_data["status"]  =   0
  #   ret_data["err_msg"] =   err_msg
  #   [code, {"Content-Type" => "text/json"}, [ret_data.to_json]]
  # end

  def verify_params( params, key )
    unless params.has_key? key
      raise ApiException.new( Constant::HTTP_REQUEST_ERROR, , "未定义属性 #{required_key}" ) 
    end 
  end
  
end
