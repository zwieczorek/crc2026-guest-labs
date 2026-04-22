output "vnet_one_id" {
  value = module.network[0].name
}

output "vnet_two_id" {
  value = module.network[1].name
}

output "location_from_module_one" {
  value = module.network[0].location
}

output "all" {
  value = module.network
}
