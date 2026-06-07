---
plugin: azure.azcollection.azure_rm
auth_source: cli
plain_host_names: true

include_vm_resource_groups:
  - __AZURE_RESOURCE_GROUP_NAME__

exclude_host_filters:
  - "'project' not in tags or tags.project != 'eind-opdracht'"

conditional_groups:
  platform_azure: "true"
  docker_hosts: "true"