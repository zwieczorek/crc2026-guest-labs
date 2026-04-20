locals {
  vm_count  = 3
  my_string = "my string   aa bb cc"
  my_list   = ["aaaaa", "bbbbb", 4]

  my_map = {
    name    = "Name"
    surname = "Surname"
    age     = 28

  }

  my_text = "${local.vm_count}_my_text_${local.my_map.surname}"


  my_map2 = {
    name    = "Name"
    surname = "Surname"
    age     = 28

  }

}
