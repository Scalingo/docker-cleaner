require 'docker_cleaner/containers'
require 'docker_cleaner/images'

module DockerCleaner
  def self.run(registry, prefix, delay, logger)
    DockerCleaner::Containers.new(logger, delay: delay).run
    DockerCleaner::Images.new(registry, prefix, logger, delay: delay).run
  end
end
