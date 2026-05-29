---@diagnostic disable: undefined-global
local docker = require("config.docker-functions")
local map = require("config.utils").map

map({
  { "<Leader>cc", docker.docker_containers, { desc = "Docker containers" } },
  { "<Leader>ci", docker.docker_images, { desc = "Docker images" } },
  { "<Leader>cb", docker.docker_build, { desc = "Docker build" } },
  { "<Leader>cu", docker.docker_compose_up, { desc = "Docker compose up" } },
  { "<Leader>cd", docker.docker_compose_down, { desc = "Docker compose down" } },
  { "<Leader>cl", docker.docker_compose_logs, { desc = "Docker compose logs" } },
  { "<Leader>cp", docker.docker_prune, { desc = "Docker prune" } },
  { "<Leader>cP", docker.docker_pull, { desc = "Docker pull image" } },
})
