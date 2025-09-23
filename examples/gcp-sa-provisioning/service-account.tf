module "gcp-sa-provisioning" {
  source         = "../../modules/gcp-sa-provisioning"
  prefix         = var.prefix
  google_project = var.google_project
  delegate_from  = var.delegate_from
}
