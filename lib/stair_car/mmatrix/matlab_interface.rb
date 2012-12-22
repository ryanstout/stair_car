require File.dirname(__FILE__) + '/../../matlab/matlabcontrol-4.0.0'
class MatlabInterface
  def initialize
    factory = Java::Matlabcontrol::MatlabProxyFactory.new
    @proxy = factory.proxy
    @processor = Java::matlabcontrol.extensions.MatlabTypeConverter.new(@proxy)
  end

end