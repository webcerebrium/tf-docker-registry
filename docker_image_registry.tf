resource "docker_image" "registry" {
  name         = "registry:2"
  keep_locally = true
}
