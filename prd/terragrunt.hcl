include "root" {
  path = find_in_parent_folders()
}

generate "variables" {
  path = "_variables.tf"
  if_exists = "overwrite"
  contents = file("../variables.tf")
}

generate "backend" {
  path = "_backend.tf"
  if_exists = "overwrite"
  contents = file("../backend.tf")
}

generate "provider" {
  path = "_provider.tf"
  if_exists = "overwrite"
  contents = file("../provider.tf")
}

terraform {
  source = "${get_path_to_repo_root()}/_modules//iam"
}
