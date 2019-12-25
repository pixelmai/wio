require 'rubygems'
require 'ramaze'

# require all configurations, controllers and models
acquire __DIR__/:config/'*'
acquire __DIR__/:model/'*'
acquire __DIR__/:helper/'*'
acquire __DIR__/:controller/'*'

puts __DIR__/:helper/'*'

DataMapper.setup(:default, 'mysql://wio:wio@localhost/wio_test')
DataMapper.auto_migrate!
