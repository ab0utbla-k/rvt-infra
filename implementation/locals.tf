locals {
  first_two_azs_list = slice(data.aws_availability_zones.this.names, 0, 2)
  first_two_azs_set  = toset(local.first_two_azs_list)

  cloudfront_cidr_chunks = {
    for i, chunk in chunklist(data.aws_ip_ranges.this.cidr_blocks, 60) :
    "cloudfront-chunk-${i}" => chunk
  }
}