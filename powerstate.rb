require './lib/ec2.rb'

# Example

dev_www=Ec2.new('dev-www')

dev_www.start
 
#Do things

dev_www.stop
