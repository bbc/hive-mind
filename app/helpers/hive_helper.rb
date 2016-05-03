module HiveHelper
  def all_hives
    Device.where(
      model: Model.where(
        device_type: DeviceType.where(classification: 'Hive')
      )
    )
  end
end
