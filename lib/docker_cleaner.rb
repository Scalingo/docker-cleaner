require 'docker_cleaner/containers'
require 'docker_cleaner/images'

module DockerCleaner
  def self.run(registries, prefix, logger, opts)
    DockerCleaner::Containers.new(logger, opts).run
    DockerCleaner::Images.new(registries, prefix, logger, opts).run
  end
end
