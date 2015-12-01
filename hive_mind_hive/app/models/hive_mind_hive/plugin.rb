module HiveMindHive
  class Plugin < ActiveRecord::Base
    has_one :device, as: :plugin
    has_many :runner_version_history

    def self.create(*args)
      if args[0].keys.include? :version
        version = args[0][:version]
        args[0].delete(:version)
      end

      hive = super(*args)
      hive.update_version(version) if version
      hive
    end

    def update(*args)
      if args[0].keys.include? :version
        version = args[0][:version]
        args[0].delete(:version)
      end

      self.update_version(version) if version
      super(*args)
    end

    def name
      self.hostname
    end

    def version
      history = self.runner_version_history.where(end_timestamp: nil).order(start_timestamp: :desc)
      history.length > 0 ? history.first.runner_version.version : nil
    end

    def update_version version
      if self.runner_version_history.length > 0
        self.runner_version_history.last.end_timestamp = Time.now
      end
      self.runner_version_history << RunnerVersionHistory.create(
        runner_version: RunnerVersion.find_or_create_by(version: version),
        start_timestamp: Time.now
      )
    end

    def details
      {
        'version' => self.version
      }
    end

    def self.plugin_params params
      params.permit(:hostname, :version)
    end
  end
end
