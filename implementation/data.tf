data "aws_availability_zones" "this" {
  state = "available"
}

data "aws_ip_ranges" "this" {
  services = ["CLOUDFRONT"]
  regions  = ["GLOBAL"]
}