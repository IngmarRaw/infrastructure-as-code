---
plugin: azure.azcollection.azure_rm
auth_source: cli

include_vm_resource_groups:
  - "${AZURE_RESOURCE_GROUP_NAME}"

plain_host_names: true

exclude_host_filters:
  - "'project' not in tags or tags.project != 'eind-opdracht'"

conditional_groups:
  platform_azure: "true"
  docker_hosts: "true"