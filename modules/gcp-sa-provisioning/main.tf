resource "google_service_account" "sa" {
  account_id   = "${var.prefix}-sa"
  display_name = "Service Account for Databricks Provisioning"
}

output "service_account" {
  value       = google_service_account.sa.email
  description = "Add this email as a user in the Databricks account console"
}

data "google_iam_policy" "this" {
  binding {
    role    = "roles/iam.serviceAccountTokenCreator"
    members = var.delegate_from
  }
}

resource "google_service_account_iam_policy" "impersonatable" {
  service_account_id = google_service_account.sa.name
  policy_data        = data.google_iam_policy.this.policy_data
}

resource "google_project_iam_custom_role" "workspace_creator" {
  role_id = "${var.prefix}_workspace_creator"
  title   = "Databricks Workspace Creator"
  project = var.google_project
  permissions = [
    "compute.addresses.createInternal",
    "compute.addresses.deleteInternal",
    "compute.addresses.get",
    "compute.addresses.setLabels",
    "compute.addresses.use",
    "compute.disks.get",
    "compute.disks.setLabels",
    "compute.firewalls.create",
    "compute.firewalls.get",
    "compute.forwardingRules.create",
    "compute.forwardingRules.delete",
    "compute.forwardingRules.get",
    "compute.forwardingRules.pscCreate",
    "compute.forwardingRules.pscDelete",
    "compute.forwardingRules.pscSetLabels",
    "compute.forwardingRules.setLabels",
    "compute.globalOperations.get",
    "compute.instanceGroups.get",
    "compute.instanceGroups.list",
    "compute.instances.get",
    "compute.instances.list",
    "compute.instances.setLabels",
    "compute.networks.access",
    "compute.networks.create",
    "compute.networks.delete",
    "compute.networks.get",
    "compute.networks.updatePolicy",
    "compute.networks.use",
    "compute.networks.useExternalIp",
    "compute.projects.get",
    "compute.regionOperations.get",
    "compute.routers.create",
    "compute.routers.delete",
    "compute.routers.get",
    "compute.routers.update",
    "compute.routers.use",
    "compute.subnetworks.create",
    "compute.subnetworks.delete",
    "compute.subnetworks.expandIpCidrRange",
    "compute.subnetworks.get",
    "compute.subnetworks.getIamPolicy",
    "compute.subnetworks.setIamPolicy",
    "compute.subnetworks.setPrivateIpGoogleAccess",
    "compute.subnetworks.update",
    "compute.subnetworks.use",
    "compute.subnetworks.useExternalIp",
    "container.clusterRoleBindings.create",
    "container.clusterRoleBindings.get",
    "container.clusterRoles.bind",
    "container.clusterRoles.create",
    "container.clusterRoles.get",
    "container.clusters.create",
    "container.clusters.delete",
    "container.clusters.get",
    "container.clusters.getCredentials",
    "container.clusters.list",
    "container.clusters.update",
    "container.configMaps.create",
    "container.configMaps.get",
    "container.configMaps.update",
    "container.customResourceDefinitions.create",
    "container.customResourceDefinitions.get",
    "container.customResourceDefinitions.update",
    "container.daemonSets.create",
    "container.daemonSets.get",
    "container.daemonSets.update",
    "container.deployments.create",
    "container.deployments.get",
    "container.deployments.update",
    "container.jobs.create",
    "container.jobs.get",
    "container.jobs.update",
    "container.namespaces.create",
    "container.namespaces.get",
    "container.namespaces.list",
    "container.operations.get",
    "container.pods.get",
    "container.pods.getLogs",
    "container.pods.list",
    "container.roleBindings.create",
    "container.roleBindings.get",
    "container.roles.bind",
    "container.roles.create",
    "container.roles.get",
    "container.secrets.create",
    "container.secrets.get",
    "container.secrets.update",
    "container.serviceAccounts.create",
    "container.serviceAccounts.get",
    "container.services.create",
    "container.services.get",
    "container.thirdPartyObjects.create",
    "container.thirdPartyObjects.delete",
    "container.thirdPartyObjects.get",
    "container.thirdPartyObjects.update",
    "iam.roles.create",
    "iam.roles.delete",
    "iam.roles.get",
    "iam.roles.update",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.setIamPolicy",
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy",
    "servicedirectory.namespaces.create",
    "servicedirectory.services.create",
    "servicedirectory.services.delete",
    "serviceusage.services.enable",
    "serviceusage.services.get",
    "serviceusage.services.list",
    "storage.buckets.create",
    "storage.buckets.delete",
    "storage.buckets.get",
    "storage.buckets.getIamPolicy",
    "storage.buckets.list",
    "storage.buckets.setIamPolicy",
    "storage.buckets.update",
    "storage.hmacKeys.create",
    "storage.hmacKeys.get",
    "storage.hmacKeys.list",
    "storage.hmacKeys.update",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.get",
    "storage.objects.getIamPolicy",
    "storage.objects.list",
    "storage.objects.setIamPolicy",
    "storage.objects.update",
  ]
}

data "google_client_config" "current" {}

resource "google_project_iam_member" "sa_can_create_workspaces" {
  role    = google_project_iam_custom_role.workspace_creator.id
  member  = "serviceAccount:${google_service_account.sa.email}"
  project = var.google_project
}
