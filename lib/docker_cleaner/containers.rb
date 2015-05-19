module DockerCleaner
class Containers
  def initialize(logger)
    @logger = logger
  end

  def remove(container)
    @logger.info "Remove #{container.id[0...10]} - #{container.info["Image"]} - #{container.info["Names"][0]}"
    container.remove
    @logger.info "Remove #{container.id[0...10]} - #{container.info["Image"]} - #{container.info["Names"][0]}... OK"
  end

  def run
    # Remove stopped container which stopped with code '0'
    one_week_ago = Time.now.to_i - 7 * 24 * 3600
    Docker::Container.all(all: true).select{ |container| 
      container.info["Status"].include?("Exited (0)") || container.info["Status"].include?("Exited (") && container.info["Created"].to_i < one_week_ago
    }.each do |container|
      remove(container)
    end

    containers_per_app = {}
    Docker::Container.all(all: true).select{ |container| 
      container.info["Status"].include?("Exited")
    }.each{ |container| 
      app = container.info["Image"].split(":", 2)[0]
      if containers_per_app[app].nil?
        containers_per_app[app] = [container]
      else
        containers_per_app[app] << container
      end
    }
    containers_per_app.each do |app, containers|
      containers.shift
      containers.each do |container|
        remove(container)
      end
    end
  end
end
end
