require 'docker_cleaner/containers'
require 'docker_cleaner/images'

module DockerCleaner
  def self.run(registry, prefix, logger)
    DockerCleaner::Containers.new(logger).run
    DockerCleaner::Images.new(registry, prefix, logger).run
  end
end
