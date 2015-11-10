class DeviceOramaMock
  attr_reader :id
  attr_reader :data_one_set
  attr_reader :data_two_set
  attr_reader :data_three_set

  @@data_one_set = false
  @@data_two_set = false
  @@data_three_set = false

  def self.data_set
    [
      @@data_one_set,
      @@data_two_set,
      @@data_three_set,
    ]
  end

  def initialize(id, options)
    @id = id
    @@data_one_set = options.has_key?('extra_data_one')
    @@data_two_set = options.has_key?('extra_data_two')
    @@data_three_set = options.has_key?('extra_data_three')
  end

  def self.find_or_create_by options
    data = self.new(1, options)
  end

  def name
    "Mock device name"
  end
end
