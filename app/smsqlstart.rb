require 'rubygems'
require 'ramaze'


# require all configurations, controllers and models
acquire __DIR__/:config/'*'
acquire __DIR__/:model/'*'
acquire __DIR__/:helper/'*'
acquire __DIR__/:controller/'*'

Wio::SMSQLServer.start(1, 0)
