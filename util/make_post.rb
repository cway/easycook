#encoding: utf-8
#author cway 2013-06-23

require 'net/http'
require 'uri'
 
req_headers= {
  'Content-Type' => 'text/xml; charset=utf-8',
}
 
#req_body = <<EOF
#<xml>
# <ToUserName><![CDATA[toUser]]></ToUserName>
# <FromUserName><![CDATA[fromUser]]></FromUserName> 
# <CreateTime>1348831860</CreateTime>
# <MsgType><![CDATA[text]]></MsgType>
# <Content><![CDATA[看10000002]]></Content>
# <MsgId>123456789</MsgId>
#</xml>
#EOF

req_body = <<EOF
<xml>
  <ToUserName><![CDATA[citylife]]></ToUserName>
  <FromUserName><![CDATA[custom]]></FromUserName>
  <CreateTime>1348831860</CreateTime>
  <MsgType><![CDATA[event]]></MsgType>
  <Event><![CDATA[subscribe]]></Event>
  <EventKey><![CDATA[]]></EventKey>
</xml>
EOF
 
http = Net::HTTP.new('192.168.0.39' , 8001)
http.set_debug_output $stdout
res = http.request_post("/wechat" , req_body , req_headers)
puts res.body
