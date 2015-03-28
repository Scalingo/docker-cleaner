require 'docker_cleaner/containers'
require 'docker_cleaner/images'

module DockerCleaner
  def self.run(registry, prefix)
    DockerCleaner::Containers.new.run
    DockerCleaner::Images.new(registry, prefix).run
  end
end
