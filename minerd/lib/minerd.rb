module Minerd ; end

require_relative 'minerd/client'
require_relative 'minerd/server'
require_relative 'minerd/state'
require_relative 'minerd/handler'

Thread.abort_on_exception = true
