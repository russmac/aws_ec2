require './lib/ec2.rb'

# Example
dev_www=Ec2.new('appxx')
dev_www.create_ami('critical_backup')
dev_www.deregister_ami('critical_backup','30')

