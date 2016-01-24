require './lib/ec2.rb'

# Example

dev_www=Ec2.new('dev-www')

dev_www.start_instance
 
#Do things

dev_www.stop_instance
