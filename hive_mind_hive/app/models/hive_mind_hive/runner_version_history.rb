module HiveMindHive
  class RunnerVersionHistory < ActiveRecord::Base
    belongs_to :plugin
    belongs_to :runner_version
  end
end
