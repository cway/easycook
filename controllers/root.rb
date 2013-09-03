#encoding: utf-8
#author cway 2013-07-29
require 'erb'
require 'base64'

post '/product' do
  begin
    params                     =  JSON.parse( request.body.string )
    #check_signature( params )
    product                    =  ProductController.create( params )
    success( Constant::HTTP_CREATE_SUCCESS,customer )
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
