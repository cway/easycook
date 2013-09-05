#encoding: utf-8
#author cway 2013-07-29
require 'erb'
require 'base64'

#商品相关
post '/product' do
  begin
    product_info               =  JSON.parse( request.body.string )
    #check_signature( params )
    product                    =  ProductController.create( product_info )
    success( Constant::HTTP_CREATE_SUCCESS, product )
  rescue ApiException => error
    failed( error.code, error.msg )
  end
end

put '/product/:id' do
  begin
    product_info               =  JSON.parse( request.body.string )
    #check_signature( params )
    product                    =  ProductController.update( params[:id], product_info )
    success( Constant::HTTP_REQUEST_SUCCESS, product )
  rescue ApiException => error
    failed( error.code, error.msg )
  end
end

get '/product/:id' do
  begin
    product_id                 =  params[:id]
    #check_signature( params )
    product                    =  ProductController.get( product_id )
    success( Constant::HTTP_REQUEST_SUCCESS, product )
  rescue ApiException => error
    failed( error.code, error.msg )
  end
end

delete '/product/:id' do
  begin
    product_id                 =  params[:id]
    #check_signature( params )
    product                    =  ProductController.delete( product_id )
    success( Constant::HTTP_REQUEST_SUCCESS, product )
  rescue ApiException => error
    failed( error.code, error.msg )
  end
end

get '/products' do
  begin
    product_ids                =  params[:ids].split(",")
    #check_signature( params )
    product                    =  ProductController.get_mutils( product_ids )
    success( Constant::HTTP_REQUEST_SUCCESS, product )
  rescue ApiException => error
    failed( error.code, error.msg )
  end
end

#闪购相关
get '/flashsales_list/:date' do
  begin
    flashsales                 = FlashsalesController.get_by_date( params[:date] )
    success( Constant::HTTP_REQUEST_SUCCESS, flashsales )
  rescue ApiException => error
    failed( error.code, error.msg )
  end
end

get '/flashsales/:id' do
  begin
    flashsales                 = FlashsalesController.get( params[:id] )
    success( Constant::HTTP_REQUEST_SUCCESS, flashsales )
  rescue ApiException => error
    failed( error.code, error.msg )
  end
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
