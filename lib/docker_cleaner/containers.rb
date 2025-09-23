# frozen_string_literal: true

module DockerCleaner
  class Containers
    def initialize(logger, opts = {})
      @logger = logger
      @delay = opts.fetch(:delay, 0)
    end

    def remove(container)
      @logger.info "Remove #{container.id[0...10]} - #{container.info["Image"]} - #{container.info["Names"][0]}"
      container.remove v: true
      @logger.info "Remove #{container.id[0...10]} - #{container.info["Image"]} - #{container.info["Names"][0]}... OK"
    end

    def run
      # Remove stopped container which stopped with code '0'
      two_hours_ago = Time.now.to_i - 2 * 3600
      Docker::Container.all(all: true).select do |container|
        status = container.info["Status"]
        (status == "Created" && container.info["Created"].to_i < two_hours_ago) ||
          (status.include?("Exited (") && container.info["Created"].to_i < two_hours_ago)
      end.each do |container|
        remove(container)
        sleep(@delay)
      end

      containers_per_app = {}
      Docker::Container.all(all: true).select do |container|
        container.info["Status"].include?("Exited")
      end.each do |container|
        app = container.info["Image"].split(":", 2)[0]
        if containers_per_app[app].nil?
          containers_per_app[app] = [container]
        else
          containers_per_app[app] << container
        end
      end
      containers_per_app.each_value do |containers|
        containers.shift
        containers.each do |container|
          remove(container)
          sleep(@delay)
        end
      end
    end
  end
end
