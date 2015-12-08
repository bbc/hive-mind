module HiveMindHive
  class RunnerPluginVersionHistory < ActiveRecord::Base
    belongs_to :plugin
    belongs_to :runner_plugin_version
  end
end
