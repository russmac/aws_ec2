class Ec2
  require 'aws-sdk'

  def initialize(target)
    @target=target
    @ec2 = Aws::EC2::Resource.new(region:'ap-southeast-2',)
  end

  # Find our targeted instance "Name" and make a list of AWS::Ec2:Instances objects
  def create_instance_list(target)
    list=Hash.new
    @ec2.instances.each do |i|
      i.tags.each do |t|
        if t.key == 'Name'
          if t.value == "#{@target}"
            list[:"'#{@target}'"]=i
          end
        end
      end
    end
    list
  end

  def start_instance
    list=create_instance_list(@target)
    list.each_value do |i|
      i.start({ additional_info: "ec2_stopstart starting instance",})
      #todo: what if it doesnt start
      if i.wait_until_running
        puts "Instance #{i.id} started"
      end
    end
  end

  def stop_instance
    list=create_instance_list(@target)
    list.each_value do |i|
      i.stop({  force: true,})
      #todo: what if it doesnt stop
      if i.wait_until_stopped
        puts "Instance #{i.id} stopped"
      end
    end
  end

  def create_ami(backup_key)
    list=create_instance_list(@target)
    list.each do |target,iobject|
      response=@ec2.client.create_image({instance_id: iobject.id,
                                                name: "#{target}_#{iobject.id}_#{Time.now.strftime("%Y_%d_%m_%H-%M_%S_%Z")}",
                                         description: "#{target}_#{iobject.id}_#{Time.now.strftime("%Y_%d_%m_%H-%M_%S_%Z")}_scripted_backup",
                                          no_reboot:  true, })
      puts "Created ami from #{target}: #{response.image_id}"
      unless @ec2.client.create_tags({
                                  resources: ["#{response.image_id}"], # required
                                  tags: [ # required
                                   {
                                         key: "#{backup_key}",
                                       value: 'true',
                                   },
                                   {
                                         key: 'epoch',
                                       value: "#{Time.now.to_i}",
                                   },
                               ],
                           })
        abort "Could not tag image #{target}: #{response.image_id}"
    end
    end
end

  def create_image_list(backup_key)
    images=@ec2.client.describe_images({ owners: ["self"],
                                        filters: [
                                                  {
                                                      name: "tag:#{backup_key}",
                                                      values: ['true'],
                                                  },
                                                  ],
                                       })
    images
  end

  def deregister_ami(backup_key,retention)
    retention_epoch=retention.to_i * 86400
    epoch=Time.now.to_i
    list=create_image_list(backup_key)
    list.images.each do |image|
      image[:tags].each do |tag|
        if tag[:key] == 'epoch'
           if ( epoch - tag[:value].to_i ) > retention_epoch
             if @ec2.client.deregister_image({image_id: image[:image_id],})
               puts "Deregistered #{image[:image_id]}"
             else
               puts "Failed to deregister #{image[:image_id]}"
             end
           end
           end
      end
    end
  end


end