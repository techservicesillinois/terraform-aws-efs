# efs

[![Terraform actions status](https://github.com/techservicesillinois/terraform-aws-efs/workflows/terraform/badge.svg)](https://github.com/techservicesillinois/terraform-aws-efs/actions)

Provides an Elastic File System (EFS) volume with mount targets and security groups.
This module only supports mount targets within one VPC.

Example Usage
-----------------

```hcl
module "volume" {
  source = "git@github.com:techservicesillinois/terraform-aws-efs"

  name        = "example"
  subnet_type = "public"
  vpc         = "vpc_name"
}
```
Note that this module uses a Terraform `lifecycle` block with `prevent_destroy`
set to *true*, because the consequences of an accidental `terraform destroy` 
on an EFS volume is to wipe out any data stored there.

The Terraform documentation states:

* `prevent_destroy `(bool) - This flag provides extra protection against the
destruction of a given resource.
When this flag is set to true, any plan that includes a destroy of this
resource will return an error message.

Unfortunately, Terraform does not support interpolations in the `lifecycle`
block, which means that the only way to intentionally destroy the affected
resource is to do so in the AWS console.

Argument Reference
-----------------

The following arguments are supported:

* `name` - (Required) The name of the EFS file system. This name is only
used to identify the volume; a unique volume identifier provided by
the module will be used to mount the volume.

* `vpc` - (Required) The name of the virtual private cloud to be
associated with the load balancer.

* `subnet_type` - (Required) Subnet type (e.g., 'campus', 'private', 'public') for resource placement.

* `encrypted` - (Optional) Encrypt data on volume at rest. Default: true.

* `performance_mode` - (Optional) File system performance mode
(generalPurpose or maxIO). Default: generalPurpose.

* `tags` - (Optional) A mapping of tags to assign to the resource.

* `throughput_mode` - (Optional) Throughput mode for the file system
(bursting or provisioned). Default: bursting.

Attributes Reference
--------------------

The following attributes are exported:

* `arn` - The ARN of the EFS volume.

* `client_security_group` - The name of the security group created for
clients of the EFS server.

* `id` - The ID of the EFS volume.

* `fqdn` - The the EFS volume's fully qualified domain name.

* `mount_targets` - A map consisting of a key/value pair wherein each key represents an availability zones (AZ) paired with the EFS volume's mount target ID in the respective AZ.

* `server_security_group` - The name of the security group created for
the EFS server.
