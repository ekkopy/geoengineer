require_relative '../spec_helper'

describe(GeoEngineer::Resources::AwsCloudhsmV2Hsm) do
  common_resource_tests(described_class, described_class.type_from_class_name)
  name_tag_geo_id_tests(GeoEngineer::Resources::AwsCloudhsmV2Hsm)

  describe "#_fetch_remote_resources" do
    it 'should create list of hashes from returned AWS SDK' do
      chsm_client = AwsClients.cloudhsm
      cluster_stub = chsm_client.stub_data(
        :describe_clusters, {
          clusters: [{
            backup_policy: "DEFAULT",
            cluster_id: "cluster-mqgqtqrwatj",
            hsms: [{
              availability_zone: "us-east-1a",
              cluster_id: "cluster-mqgqtqrwatj",
              subnet_id: "subnet-baf20c95",
              eni_id: "eni-0c87c1b591cf298ac",
              eni_ip: "10.200.42.69",
              hsm_id: "hsm-m2q2dtteorm",
              state: "ACTIVE",
              state_message: "HSM created."
            }],
            hsm_type: "hsm1.medium",
            pre_co_password: nil,
            security_group: "sg-0a3ff2fb752fa05f9",
            source_backup_id: nil,
            state: "UNINITIALIZED",
            state_message: nil,
            vpc_id: "vpc-f8e36c9d",
            certificates: {
              cluster_csr: "-----BEGIN CERTIFICATE REQUEST-----[ content removed ]-----END CERTIFICATE REQUEST-----\n",
              hsm_certificate: "-----BEGIN CERTIFICATE-----[ content removed ]-----END CERTIFICATE-----\n",
              aws_hardware_certificate: "-----BEGIN CERTIFICATE-----[ content removed ]-----END CERTIFICATE-----\n",
              manufacturer_hardware_certificate: "-----BEGIN CERTIFICATE-----[ content removed ]-----END CERTIFICATE-----\n",
              cluster_certificate: nil
            }
          }]
        }
      )
      tags_stub = chsm_client.stub_data(
        :list_tags, {
          tag_list: [{ key: "Name", value: "testing" }]
        }
      )

      chsm_client.stub_responses(:describe_clusters, cluster_stub)
      chsm_client.stub_responses(:list_tags, tags_stub)

      ec2_client = AwsClients.ec2
      subnet_stub = ec2_client.stub_data(
        :describe_subnets, {
          subnets: [{
            subnet_id: '1',
            cidr_block: "10.10.0.0/24",
            tags: [{ key: 'Name', value: 'one' }]
          }]
        }
      )
      ec2_client.stub_data(:describe_subnet, subnet_stub)

      remote_resources = GeoEngineer::Resources::AwsCloudhsmV2Hsm._fetch_remote_resources(nil)
      expect(remote_resources.length).to eq(1)
    end
  end
end
