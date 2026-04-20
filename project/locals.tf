locals {
  tags = {
    owner = "name.surname"
  }

  string_my = "${local.tags.owner}_test"
}
