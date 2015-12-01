module HiveMindHive
  class RunnerVersion < ActiveRecord::Base
    has_many :runner_version_history
  end
end
