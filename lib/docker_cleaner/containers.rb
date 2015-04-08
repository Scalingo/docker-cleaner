module DockerCleaner
class Containers
  def run
    # Remove stopped container which stopped with code '0'
    one_week_ago = Time.now.to_i - 7 * 24 * 3600
    Docker::Container.all(all: true).select{ |container| 
      container.info["Status"].include?("Exited (0)") || container.info["Status"].include?("Exited (") && container.info["Created"].to_i < one_week_ago
    }.each do |container|
      $stdout.write "Remove #{container.id[0...10]} - #{container.info["Image"]} - #{container.info["Names"][0]}"
      container.remove
      $stdout.write "... OK\n"
    end
  end
end
end
