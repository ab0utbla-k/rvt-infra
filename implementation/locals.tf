locals {
    first_two_azs_list = slice(data.aws_availability_zones.this.names, 0, 2)
    first_two_azs_set = toset(local.first_two_azs_list)
}