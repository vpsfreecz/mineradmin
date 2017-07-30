class Minerdctl::Response
  def initialize(resp)
    @resp = resp

    if @resp[:response].is_a?(::Hash)
      @resp[:response].each do |k, v|
        define_singleton_method(k) { v }
      end
    end
  end

  def status
    @resp[:status] ? true : false
  end

  def ok?
    status
  end

  def response
    @resp[:response]
  end

  def message
    @resp[:message]
  end
end
