#encoding: utf-8
#author cway 2013-07-29
require 'erb'
require 'base64'

post '/bind' do
  begin
    params                     =  JSON.parse( request.body.string )
    check_signature( params )
    customer                   =  CustomerController.bind_platform( params )
    success( Constant::HTTP_CREATE_SUCCESS,customer )
  rescue ApiException => error
    failed( error.code, error.msg )
  end
end

get '/customers/:id' do
  begin
    check_signature( params )
    result                     =  CustomerController.get_customer( params[:id] )
    success( Constant::HTTP_REQUEST_SUCCESS,result )
  rescue ApiException => error
    failed( error.code, error.msg )
  end
end

get '/customers/:id/addresses' do
  begin
    check_signature( params )
    result                     =  CustomerAddressController.get_addresses_by_customer_id( params[:id] )
    success( Constant::HTTP_REQUEST_SUCCESS,result )
  rescue ApiException => error
    failed( error.code, error.msg )
  end
end

post '/addresses' do
  begin
    params                     =  JSON.parse( request.body.string )
    check_signature( params )
    result                     =  CustomerAddressController.create( params )
    success( Constant::HTTP_CREATE_SUCCESS,result )
  rescue ApiException => error
    failed( error.code, error.msg )
  end
end

get '/flashsales/today' do
  query = ""
  params.each_with_index do |(key, value), index|  
    if query == ""
      query = "?" + key.to_s + "=" + value.to_s
    else
      query += "&" + key.to_s + "=" + value.to_s
    end
  end
  redirect to('/flashsales/' + Time.now.strftime("%Y-%m-%d").to_s + query)
end

get '/flashsales/tomorrow' do
  query = ""
  params.each_with_index do |(key, value), index|  
    if query == ""
      query = "?" + key.to_s + "=" + value.to_s
    else
      query += "&" + key.to_s + "=" + value.to_s
    end
  end
  redirect to('/flashsales/' + (Time.now + 60 * 60 * 24 ).strftime("%Y-%m-%d").to_s)
end

get '/flashsales/:date' do
  begin
    result                     = FlashsalesController.get_flashsales( params )
    success( Constant::HTTP_REQUEST_SUCCESS,result )
  rescue ApiException => error
    failed( error.code, error.msg )
  end
end

get '/event_products/:id' do
  begin
    result                     = FlashsalesController.get_event_products_by_event_product_id ( params[:id] ) 
    success( Constant::HTTP_REQUEST_SUCCESS,result )
  rescue ApiException => error
    failed( error.code, error.msg )
  end
end

post '/sales_orders' do
  begin
    params                     =  JSON.parse( request.body.string )
    check_signature ( params )
    result                     = SalesOrderController.create ( params ) 
    success( Constant::HTTP_CREATE_SUCCESS,result )
  rescue ApiException => error
    failed( error.code, error.msg )
  end
end

get '/customers/:id/sales_orders' do
  begin
    check_signature ( params )
    result                     = SalesOrderController.get_orders_by_customer_id( params[:id],params )
    success( Constant::HTTP_REQUEST_SUCCESS,result )
  rescue ApiException => error
    failed( error.code, error.msg )
  end
end

get '/sales_orders/:id' do
  begin
    check_signature ( params )
    result                     = SalesOrderController.show ( params[:id] )
    success( Constant::HTTP_REQUEST_SUCCESS,result )
  rescue ApiException => error
    failed( error.code, error.msg )
  end
end

get '/provinces' do
  result                     = AddressProvince.all
  success( Constant::HTTP_REQUEST_SUCCESS,result )
end

get '/provinces/:id/cities' do
  result                     = AddressCity.where( "pro_id = #{params[:id]}" )
  success( Constant::HTTP_REQUEST_SUCCESS,result )
end

get '/cities' do
  result                     = AddressCity.all
  success( Constant::HTTP_REQUEST_SUCCESS,result )
end

get '/cities/:id/districts' do
  result                     = AddressDistrict.where( "city_id = #{params[:id]}" )
  success( Constant::HTTP_REQUEST_SUCCESS,result )
end

get '/districts' do
  result                     = AddressDistrict.all
  success( Constant::HTTP_REQUEST_SUCCESS,result )
end

get '/*' do
  err = Hash.new
  err["err"] = 403
  err["msg"] = "Forbidden"
  halt 403, err.to_json
end

get '/test' do
  content_type :html
  <<EOF
  <form action="./wechat" method="post">
    <input name="nonce" type="text" />
    <input type="submit" value="submit" />
  </form>
EOF

end

# not_found do
#   err = Hash.new
#   err["err"] = 404
#   err["msg"] = "sorry, it lost!"
#   halt 404, err.to_json
# end

error do
  err = Hash.new
  err["err"] = 500
  err["msg"] = "server error!"
  halt 500, err.to_json
end
