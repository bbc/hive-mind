module HiveHelper
  def all_hives
    Device.joins(model: :device_type).where('device_types.classification = ?', 'Hive')
    #Device.where(
    #  model: Model.where(
    #    device_type: DeviceType.where(classification: 'Hive')
    #  )
    #)
  end
end
