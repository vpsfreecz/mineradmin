module Minerd ; end

require_relative 'minerd/client'
require_relative 'minerd/server'
require_relative 'minerd/state'
require_relative 'minerd/handler'
require_relative 'minerd/interactive'

Thread.abort_on_exception = true
