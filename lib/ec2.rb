# Ec2
class Ec2
  require 'aws-sdk'

  def initialize(target)
    @target = target
    @ec2 = Aws::EC2::Resource.new(region: 'ap-southeast-2')
  end

  # Find our targeted instance "Name" and make a list of AWS::Ec2:Instances
  def create_instance_list(target)
    list = {}
    x = 1
    @ec2.instances.each do |i|
      i.tags.each do |t|
        next unless t.key == 'Name'
        next unless t.value == target.to_s
        unless list[:"#{target}"].nil?
          target = target.to_s + "_#{x}"
          x += 1
        end
        list[:"#{target}"] = i
      end
    end
    list
  end

  def start_instance
    list = create_instance_list(@target)
    list.each_value do |i|
      i.start(additional_info: 'ec2_stopstart starting instance')
      # TODO: what if it doesnt start
      puts "Instance #{i.id} started" if i.wait_until_running
    end
  end

  def stop_instance
    list = create_instance_list(@target)
    list.each_value do |i|
      i.stop(force: true)
      # TODO: what if it doesnt stop
      puts "Instance #{i.id} stopped" if i.wait_until_stopped
    end
  end

  def create_ami(backup_key)
    list = create_instance_list(@target)
    list.each do |target, iobject|
      response = @ec2.client.create_image(instance_id: iobject.id,
                                          name: "#{target}_#{iobject.id}" + Time.now.strftime('%Y_%d_%m_%H-%M_%S_%Z').to_s,
                                          description: "#{target}_#{iobject.id}" + Time.now.strftime('%Y_%d_%m_%H-%M_%S_%Z').to_s + 'scripted_backup',
                                          no_reboot: true)
      if response.successful?
        puts "Ami created : "+"#{target}_#{iobject.id} " + Time.now.strftime('%Y_%d_%m_%H-%M_%S_%Z').to_s
      else
        raise AwsError "AMI request returned error"
      end
      unless @ec2.client.create_tags(
        resources: [response.image_id.to_s],
        tags: [
          {
            key: backup_key.to_s,
            value: 'true'
          },
          {
            key: 'epoch',
            value: Time.now.to_i.to_s
          }
        ]
      )
        raise AwsError "Could not tag image #{target}: #{response.image_id}"
      end
    end
  end

  def create_image_list(backup_key)
    images = @ec2.client.describe_images(owners: ['self'],
                                         filters: [{ name: "tag:#{backup_key}",
                                                     values: ['true']
                                                   }]
                                        )
    images
  end

  def deregister_ami(backup_key, retention)
    retention_epoch = retention.to_i * 864_00
    epoch = Time.now.to_i
    list = create_image_list(backup_key)
    list.images.each do |image|
      image[:tags].each do |tag|
        next unless tag[:key] == 'epoch'
        if (epoch - tag[:value].to_i) > retention_epoch
          if @ec2.client.deregister_image(image_id: image[:image_id])
            puts "Deregistered #{image[:image_id]}"
          else
            puts "Failed to deregister #{image[:image_id]}"
          end
        end
      end
    end
  end

end
