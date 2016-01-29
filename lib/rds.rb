class Rds
  require 'aws-sdk'

  def initialize
    @ec2 = Aws::EC2::Resource.new(region:'ap-southeast-2',)
  end

  def create_rds_list

  end

  # supports MySQL mariadb postgres aurora
  def create_instance(name,engine,db_instance_class,storage_type,allocated_storage,
                      storage_encrypted,db_parameter_group_name,availability_zone,
                      multi_az,db_subnet_group_name,db_security_groups,vpc_security_group_ids)
    @ec2.create_db_instance({
                               db_name: name,
                               db_instance_identifier: "String", # required
                               allocated_storage: allocated_storage,
                               db_instance_class: db_instance_class, # required
                               engine: engine, # required
                               master_username: "String",
                               master_user_password: "String",
                               db_security_groups: ["String"],
                               vpc_security_group_ids: ["String"],
                               availability_zone: "String",
                               db_subnet_group_name: "String",
                               # preferred_maintenance_window: "String",
                               db_parameter_group_name: "String",
                               # backup_retention_period: 1,
                               # preferred_backup_window: "String",
                               port: 1,
                               multi_az: true,
                               engine_version: "String",
                               auto_minor_version_upgrade: true,
                               # license_model: "String",
                               # iops: 1,
                               option_group_name: "String",
                               # character_set_name: "String",
                               # publicly_accessible: true,
                                tags: [
                                    {
                                        key: "aws_rds_helper",
                                        value: "true",
                                    },
                                ],
                               # db_cluster_identifier: "String",
                               storage_type: "String",
                               # tde_credential_arn: "String",
                               # tde_credential_password: "String",
                               storage_encrypted: true,
                               # kms_key_id: "String",
                               copy_tags_to_snapshot: true,
                               # monitoring_interval: 1,
                               # monitoring_role_arn: "String",
                           })

  end

  def dump_rds

  end

  def sync_rds

  end


end
