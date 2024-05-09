resource "docker_image" "registry_ui" {
  name         = "joxit/docker-registry-ui:main"
  keep_locally = true
}
