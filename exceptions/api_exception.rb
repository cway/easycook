class ApiException < StandardError
  attr_reader :msg
  attr_reader :code
  def initialize( code,msg )
    @code = code
    @msg  = msg
  end
end
