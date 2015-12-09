module HiveMindHive
  class RunnerPluginVersion < ActiveRecord::Base
    has_many :runner_plugin_version_history
  end
end
