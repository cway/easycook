#encoding: utf-8
#author cway 2013-06-23

helpers do
  def bar(name)
    "#{name}bar"
  end
  
  def judge_input( input_str, type )
    judge_str = { 
                  'confirm'   =>  ['Y', 'y', 'yes', 'YES', 'Yes'],
                  'today'     =>  ['today', 'Today'],
                  'tomorrow'  =>  ['tomorrow','Tomorrow']
                }
    return judge_str[type].include?(input_str.to_s)
  end

  def csrf_token
    Rack::Csrf.csrf_token(env)
  end

  def csrf_tag
    Rack::Csrf.csrf_tag(env)
  end

  def success( code, data )
    ret_data            =   Hash.new
    ret_data["status"]  =   1
    ret_data["data"]    =   data
    status code
    headers \
      "Content-Type"   => "text/json"
    body ret_data.to_json
       #[code, {"Content-Type" => "text/json"}, [ret_data.to_json]]
  end

  def failed( code, err_msg )
    
    puts err_msg

    ret_data            =   Hash.new
    ret_data["status"]  =   0
    ret_data["err_msg"] =   err_msg
    status code
    headers \
      "Content-Type"   => "text/json"
    body ret_data.to_json
  end

  def check_signature( params )
    # open_id = params[ "open_id" ]
    app_key = params[ "app_key" ]
    time = params[ "time" ]
    unless app_key && time
      raise ApiException.new( Constant::HTTP_REQUEST_ERROR, "签名错误,参数缺失（app_key,time）" )
    end
    app_access    = AppAccess.find_by_app_key( app_key )
    unless app_access  
      raise ApiException.new( Constant::HTTP_REQUEST_ERROR, "APP来源非法" )
    end
    # stringtosign  = params["open_id"] + params["app_key"] + params["time"].to_s
    stringtosign  = params["app_key"] + params["time"].to_s
    hmac          = HMAC::SHA1.new( app_access.app_secret ) 
    hmac.update( stringtosign )
    signature     = Base64.strict_encode64( hmac.digest )

    unless params["signature"].eql?(signature)
      raise ApiException.new( Constant::HTTP_REQUEST_ERROR, "签名错误" )
    end
  end 

  def verify_params( params, key )
    unless params.has_key? key
      raise ApiException.new( Constant::HTTP_REQUEST_ERROR, "未定义属性 #{required_key}" ) 
    end 
  end
  
end
