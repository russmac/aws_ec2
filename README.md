# aws_ec2
Aws ec2 class to do stuff using the Ruby SDK.

It takes AMI's using epoch and a backup key and can purge them on different retention periods.

It can start and stop instances.

## Note this requires default credentials:
http://docs.aws.amazon.com/AWSSdkDocsRuby/latest//DeveloperGuide/prog-basics-creds.html#creds-default

 Credentials passed to the AWS.config method with the :access_key_id and :secret_access_key_id options.

 Environment Variables – AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables.
 The SDK for Ruby uses the ENVProvider class to load these credentials.

 The credentials file's default profile – For more information about the credentials file, see Setting up AWS Credentials.
 The SDK for Ruby uses the SharedCredentialFileProvider to load profiles.

 Instance profile credentials – these credentials can be assigned to Amazon EC2 instances, and are delivered through the Amazon EC2      metadata service.
 The SDK for Ruby uses EC2Provider to load these credentials.

## Example usage
```
require './lib/ec2.rb'

# The name must match the instance "Name" tag value exactly
dev_www=Ec2.new('dev-www')

# The key name, So when you deregister you can purge on different retentions
dev_www.create_ami('critical_backup')

# Key name and days of retention
dev_www.deregister_ami('critical_backup','30')

dev_www.start_instance
 
#Do things ...

dev_www.stop_instance
```
