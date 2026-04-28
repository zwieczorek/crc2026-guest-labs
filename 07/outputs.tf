output "my_vm_public_ip" {
  value = module.vm.vm_public_ip
}

output "kv_name" {
  value = module.keyvault.key_vault_name
}
