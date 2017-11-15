########################################################################
## AwsEfsFileSystem is the +aws_efs_file_system+ terraform resource,
##
## {https://www.terraform.io/docs/providers/aws/d/efs_file_system.html Terraform Docs}
#########################################################################
class GeoEngineer::Resources::AwsEfsFileSystem < GeoEngineer::Resource
  validate -> { validate_has_tag(:Name) }

  after :initialize, -> { _terraform_id -> { NullObject.maybe(remote_resource)._terraform_id } }
  after :initialize, -> { _geo_id -> { NullObject.maybe(tags)[:Name] } }
  
  def self._fetch_remote_resources(provider)
    AwsClients.efs.describe_file_systems['file_systems'].map(&:to_h).map do |file_system|
      tags = AwsClients.efs.describe_tags({file_system_id: file_system["file_system_id"]})['tags']
      name_tag = tags.find { |t| t["key"] == "Name" }
      name = name_tag["value"]
      file_system.merge(
        {
          _terraform_id: file_system["file_system_id"],
          _geo_id: name
        }
      )
    end
  end
end
