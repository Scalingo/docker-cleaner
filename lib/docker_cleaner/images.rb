module DockerCleaner
class Images
  def initialize registry, prefix, logger
    @prefix = prefix || ""
    @registry = registry
    @logger = logger
  end

  def run
    clean_old_images
    clean_unnamed_images
    clean_unused_images
  end

  def clean_unnamed_images
    Docker::Image.all.select do |image|
      image.info["RepoTags"][0] == "<none>:<none>"
    end.each do |image|
      @logger.info "Remove unnamed image #{image.id[0...10]}"
      begin
        image.remove
      rescue Docker::Error::NotFoundError
      rescue Docker::Error::ConflictError => e
        @logger.warn "Conflict when removing #{image.id[0...10]}"
        @logger.warn " !     #{e.message}"
      end
    end
  end

  def clean_old_images
    apps = images_with_latest
    apps.each do |app, images|
      if app =~ /.*-tmax$/
        next
      end
      images.each do |i|
        unless i.info["Created"] == apps["#{app}-tmax"]
          @logger.info "Remove #{i.info['RepoTags'][0]} => #{i.id[0...10]}"
          begin
            i.remove
          rescue Docker::Error::NotFoundError
          rescue Docker::Error::ConflictError => e
            @logger.warn "Conflict when removing #{i.info['RepoTags'][0]} - ID: #{i.id[0...10]}"
            @logger.warn " !     #{e.message}"
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

  def clean_unused_images
    three_weeks_ago = Time.now.to_i - 21 * 24 * 3600
    used_images = Docker::Container.all.map{|c| c.info["Image"]}.select{|i| i =~ /^#{@registry}\/#{@prefix}/ }.uniq
    # Images older than 2 months
    images = Docker::Image.all.select{|i| i.info["RepoTags"][0] =~ /^#{@registry}\/#{@prefix}/ && i.info["Created"] < three_weeks_ago }
    image_repos = images.map{|i| i.info["RepoTags"][0]}
    unused_images = image_repos - used_images

    unused_images.each do |i|
      image = images.select{|docker_image| docker_image.info["RepoTags"][0] == i}[0]
      @logger.info "Remove unused image #{image.info['RepoTags'][0]} => #{image.id[0...10]}"
      begin
        image.remove
      rescue Docker::Error::NotFoundError
      rescue Docker::Error::ConflictError => e
        @logger.warn "Conflict when removing #{image.info['RepoTags'][0]} - ID: #{image.id[0...10]}"
        @logger.warn " !     #{e.message}"
      end
    end
  end
end
end
