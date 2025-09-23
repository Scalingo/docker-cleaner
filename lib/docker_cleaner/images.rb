# frozen_string_literal: true

module DockerCleaner
  class Images
    def initialize(registries, prefix, logger, opts = {})
      @prefix = prefix || ""
      @registries = registries
      @logger = logger
      @delay = opts.fetch(:delay, 0)
      @retention = Time.now.to_i - opts.fetch(:retention, 6) * 3600
    end

    def run
      clean_old_images
      clean_unnamed_images
      clean_unused_images
    end

    def clean_unnamed_images
      Docker::Image.all.select do |image|
        image.info["RepoTags"].nil? || image.info["RepoTags"][0] == "<none>:<none>"
      end.each do |image|
        @logger.info "Remove unnamed image #{image.id[0...10]}"
        begin
          image.remove
          sleep(@delay)
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
        next if /.*-tmax$/.match?(app)

        images.each do |i|
          next if i.info["Created"] == apps["#{app}-tmax"]

          @logger.info "Remove #{i.info["RepoTags"][0]} => #{i.id[0...10]}"
          begin
            i.remove
            sleep(@delay)
          rescue Docker::Error::NotFoundError
          rescue Docker::Error::ConflictError => e
            @logger.warn "Conflict when removing #{i.info["RepoTags"][0]} - ID: #{i.id[0...10]}"
            @logger.warn " !     #{e.message}"
          end
        end
      end
    end

    def images_with_latest
      images ||= Docker::Image.all
      apps = {}

      images.each do |i|
        # RepoTags can be nil sometimes, in this case we ignore the image
        next if i.info["RepoTags"].nil?

        next unless registries_include?(i.info["RepoTags"][0])

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
      apps
    end

    def clean_unused_images
      used_images = Docker::Container.all.map { |c| c.info["Image"] }.select { |i| registries_include?(i) }.uniq
      # Images older than 2 months
      images = Docker::Image.all.select { |i| i.info["RepoTags"] && registries_include?(i.info["RepoTags"][0]) && i.info["Created"] < @retention }
      image_repos = images.map { |i| i.info["RepoTags"][0] }
      unused_images = image_repos - used_images

      unused_images.each do |i|
        image = images.find { |docker_image| docker_image.info["RepoTags"][0] == i }
        @logger.info "Remove unused image #{image.info["RepoTags"][0]} => #{image.id[0...10]}"
        begin
          image.remove
          sleep(@delay)
        rescue Docker::Error::NotFoundError
        rescue Docker::Error::ConflictError => e
          @logger.warn "Conflict when removing #{image.info["RepoTags"][0]} - ID: #{image.id[0...10]}"
          @logger.warn " !     #{e.message}"
        end
      end
    end

    protected

    def registries_include?(image)
      return false if image.nil? || image == ""

      @registries.each do |registry|
        return true if %r{^#{registry}/#{@prefix}}.match?(image)
      end
      false
    end
  end
end
