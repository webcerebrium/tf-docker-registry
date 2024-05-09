locals {
  network_id = var.network_params.network_id
  project    = var.network_params.project
  postfix    = var.network_params.postfix
  zone       = var.zone
  zone_ui    = var.zone_ui

  shortname    = "registry${var.suffix}"
  shortname_ui = "registry${var.suffix}-ui"
  hostname     = "${local.shortname}-${local.postfix}"
  hostname_ui  = "${local.shortname}-ui-${local.postfix}"

  entrypoint      = var.zone.entrypoint
  entrypoint_ui   = var.zone_ui.entrypoint
  route           = local.shortname
  route_ui        = local.shortname_ui
  service_port    = 5000
  service_port_ui = 80

  host   = var.zone.https == 1 ? var.zone.host : "localhost"
  scheme = var.zone.https == 1 ? "https" : "http"

  host_ui   = var.zone_ui.https == 1 ? var.zone_ui.host : "localhost"
  scheme_ui = var.zone_ui.https == 1 ? "https" : "http"
}

locals {
  env = [
    "REGISTRY_AUTH=htpasswd",
    "REGISTRY_AUTH_HTPASSWD_REALM=${var.realm}",
    "REGISTRY_AUTH_HTPASSWD_PATH=/auth/registry.password",
    "REGISTRY_STORAGE_DELETE_ENABLED=true",
  ]
  upload = [
    {
      file    = "/auth/registry.password",
      content = var.htpasswd
    }
  ]

  env_ui = [
    "SINGLE_REGISTRY=true",
    "REGISTRY_TITLE=${var.realm} UI",
    "DELETE_IMAGES=true",
    "SHOW_CONTENT_DIGEST=true",
    "NGINX_PROXY_PASS_URL=http://${local.hostname}:5000",
    "SHOW_CATALOG_NB_TAGS=true",
    "CATALOG_MIN_BRANCHES=1",
    "CATALOG_MAX_BRANCHES=1",
    "TAGLIST_PAGE_SIZE=100",
    "REGISTRY_SECURED=false",
    "CATALOG_ELEMENTS_LIMIT=1000"
  ]
  upload_ui = []
}

locals {
  labels_https = [{
    label = "traefik.http.routers.${local.route}.entrypoints"
    value = "https"
    }, {
    label = "traefik.http.routers.${local.route}.tls"
    value = "true"
    }, {
    label = "traefik.http.routers.${local.route}.tls.certresolver"
    value = "le"
  }]

  labels_entrypoint = [
    {
      label = "traefik.http.routers.${local.route}.rule"
      value = "Host(`${local.host}`)"
    },
    {
      label = "traefik.http.routers.${local.route}.entrypoints"
      value = local.entrypoint
    }
  ]

  labels_service = [
    {
      label = "traefik.http.routers.${local.route}.service"
      value = "${local.shortname}@docker"
    },
    {
      label = "traefik.http.services.${local.shortname}.loadbalancer.server.port"
      value = local.service_port
    }
  ]


  labels = concat(
    var.network_params.labels,
    var.zone.labels,
    local.labels_entrypoint,
    local.labels_service,
    var.zone.https == 1 ? local.labels_https : [],
    [{
      label = "role"
      value = local.shortname
    }]
  )

}


locals {
  labels_ui_https = [{
    label = "traefik.http.routers.${local.route_ui}.entrypoints"
    value = "https"
    }, {
    label = "traefik.http.routers.${local.route_ui}.tls"
    value = "true"
    }, {
    label = "traefik.http.routers.${local.route_ui}.tls.certresolver"
    value = "le"
  }]

  labels_ui_entrypoint = [
    {
      label = "traefik.http.routers.${local.route_ui}.rule"
      value = "Host(`${local.host_ui}`)"
    },
    {
      label = "traefik.http.routers.${local.route_ui}.entrypoints"
      value = local.entrypoint_ui
    }
  ]

  labels_ui_service = [
    {
      label = "traefik.http.routers.${local.route_ui}.service"
      value = "${local.shortname_ui}@docker"
    },
    {
      label = "traefik.http.services.${local.shortname_ui}.loadbalancer.server.port"
      value = local.service_port_ui
    }
  ]

  labels_ui = concat(
    var.network_params.labels,
    var.zone_ui.labels,
    local.labels_ui_entrypoint,
    local.labels_ui_service,
    var.zone_ui.https == 1 ? local.labels_ui_https : [],
    [{
      label = "role"
      value = local.shortname_ui
    }]
  )
}

