module HiveMindHive
  class Plugin < ActiveRecord::Base
    has_one :device, as: :plugin
    has_many :runner_version_history
    has_many :runner_plugin_version_history

    def self.create(*args)
      special = {}
      ['version', 'runner_plugins'].each do |key|
        if args[0].keys.include? key
          special[key] = args[0][key]
          args[0].delete(key)
        end
      end

      hive = super(*args)
      hive.update_version(special['version']) if special.has_key?('version')
      hive.update_runner_plugins(special['runner_plugins']) if special.has_key?('runner_plugins')
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

    def runner_plugins
      Hash[self.runner_plugin_version_history.where(end_timestamp: nil).map{ |h| [ h.runner_plugin_version.name, h.runner_plugin_version.version ] }]
    end

    def update_runner_plugins plugins = {}
      self.runner_plugin_version_history.each do |rpvh|
        rpvh.end_timestamp = Time.now if rpvh.end_timestamp == nil
        rpvh.save
      end
      plugins.each_pair do |p, v|
        self.runner_plugin_version_history << RunnerPluginVersionHistory.create(
          runner_plugin_version: RunnerPluginVersion.find_or_create_by(
            name: p,
            version: v
          ),
          start_timestamp: Time.now
        )
      end
    end

    def details
      {
        'version' => self.version,
        'runner_plugins' => self.runner_plugins
      }
    end

    def self.plugin_params params
      params.permit(:hostname, :version, runner_plugins: {})
    end
  end
end
