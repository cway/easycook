#encoding: utf-8
#author cway 2013-06-23
require 'digest/sha1'

timestamp="123"
signature="234"
nonce="345"
echostr="hello world for webchat"

webchat_sha1     = ["123456", timestamp.to_s, nonce.to_s].sort!.join
tmp_signature    = Digest::SHA1.hexdigest( webchat_sha1 )
puts tmp_signature
