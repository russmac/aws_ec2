class Ec2
  require 'aws-sdk'

  def initialize(target)
    @target=target
    @ec2 = Aws::EC2::Resource.new(region:'ap-southeast-2')
  end

  def start
    list=create_list
    start_list(list)
  end

  def stop
    list=create_list
    stop_list(list)
  end

  def create_list
    list=Hash.new
    @ec2.instances.each do |i|
      i.tags.each do |t|
        if t.key == 'Name'
          if t.value == "#{@target}"
            # Make a list containing the AWS::Ec2:Instances instance object
            list[:"'#{@target}'"]=i
          end
        end
      end
    end
    list
  end

  def start_list(list)
    list.each_value do |i|
      i.start({ additional_info: "ec2_stopstart starting instance",})
      if i.wait_until_running
        puts "Instance #{i.id} started"
      end
    end
  end

  def stop_list(list)
    list.each_value do |i|
      i.stop({  force: true,})
      if i.wait_until_stopped
        puts "Instance #{i.id} stopped"
      end
    end
  end

 end
