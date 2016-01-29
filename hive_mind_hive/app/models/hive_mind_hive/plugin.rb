module HiveMindHive
  class Plugin < ActiveRecord::Base
    has_one :device, as: :plugin
    has_many :runner_version_history
    has_many :runner_plugin_version_history

    def self.create(*args)
      copy = ActionController::Parameters.new(args[0])
      args[0] = copy.permit(:hostname)
      [:runner_version_history, :runner_plugin_version_history].each do |key|
        args[0][key] = copy[key] if copy.has_key?(key)
      end

      hive = super(*args)
      hive.update_version(copy['version']) if copy.has_key?('version')
      hive.update_runner_plugins(copy['runner_plugins']) if copy.has_key?('runner_plugins')
      hive
    end

    def update(*args)
      copy = ActionController::Parameters.new(args[0])
      args[0] = copy.permit(:hostname)
      [:runner_version_history, :runner_plugin_version_history].each do |key|
        args[0][key] = copy[key] if copy.has_key?(key)
      end

      self.update_version(copy['version']) if copy.has_key?('version')
      self.update_runner_plugins(copy['runner_plugins']) if copy.has_key?('runner_plugins')
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

    def json_keys
      [ :version, :connected_devices ]
    end

    def connect device
      if (h = Plugin.find_by_connected_device(device)) && (h != self)
        h.plugin.disconnect device
      end
      self.device.add_relation 'connected', device
    end

    def disconnect device
      self.device.delete_relation 'connected', device
    end

    def connected_devices
      Relationship.where(primary: self.device).map { |r| r.secondary }
    end

    def self.plugin_params params
      params.permit(:hostname, :version).merge(params.select { |key, value| key.to_s.match(/^runner_plugins$/) })
    end

    def self.find_by_connected_device device
      if r = Relationship.where(secondary: device).first
        r.primary
      end
    end
  end
end
