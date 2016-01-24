require './lib/ec2.rb'

# Example
dev_www=Ec2.new('dev-www')
dev_www.create_image('critical_backup')
dev_www.deregister_images('critical_backup','30')

