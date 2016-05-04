module HiveHelper
  def all_hives
    Device.joins(model: :device_type).where('device_types.classification = ?', 'Hive')
  end
end
