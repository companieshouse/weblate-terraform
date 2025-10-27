
//Get managed prefix list for shared services CIDRs (Concourse workers)
data "aws_ec2_managed_prefix_list" "shared_services_cidrs" {
  name = "shared-services-management-cidrs"
}
