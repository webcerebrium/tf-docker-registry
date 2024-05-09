resource "docker_container" "registry_ui" {
  count   = local.host_ui == "localhost" ? 0 : 1
  image   = docker_image.registry_ui.image_id
  name    = local.hostname_ui
  restart = "always"

  env      = local.env_ui
  log_opts = var.network_params.log_opts

  networks_advanced {
    name = local.network_id
  }
  networks_advanced {
    name = local.zone_ui.network_public_id
  }

  dynamic "labels" {
    for_each = local.labels_ui
    content {
      label = labels.value.label
      value = labels.value.value
    }
  }

  dynamic "upload" {
    for_each = local.upload_ui
    content {
      file       = upload.value.file
      content    = upload.value.content
      executable = false
    }
  }

}

