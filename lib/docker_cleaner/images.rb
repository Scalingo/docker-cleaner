module DockerCleaner
class Images
  def initialize registry, prefix
    @prefix = prefix || ""
    @registry = registry
  end

  def run
    clean_old_images
  end

  def clean_old_images
    apps = images_with_latest
    apps.each do |app, images|
      if app =~ /.*-tmax$/
        next
      end
      images.each do |i|
        unless i.info["Created"] == apps["#{app}-tmax"]
          puts "Remove #{i.info['RepoTags'][0]} => #{i.id[0...10]}"
          begin
            i.remove
          rescue Docker::Error::NotFoundError
          rescue Excon::Errors::Conflict => e
            puts "Conflict when removing #{i.info['RepoTags'][0]} - ID: #{i.id[0...10]}"
            puts " !     #{e.response.body}"
          end
        end
      end
    end
  end

  def images_with_latest
    images ||= Docker::Image.all
    apps = {}

    images.each do |i|
      if i.info["RepoTags"][0] =~ /^#{@registry}\/#{@prefix}/
        name = i.info["RepoTags"][0].split(":")[0]
        tmax = "#{name}-tmax"

        if apps[name].nil?
          apps[name] = [i]
        else
          apps[name] << i
        end
      
        if apps[tmax].nil?
          apps[tmax] = i.info["Created"]
        elsif apps[tmax] < i.info["Created"]
          apps[tmax] = i.info["Created"]
        end
      end
    end
    apps
  end
end
end
