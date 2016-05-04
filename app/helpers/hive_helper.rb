module HiveHelper
  def all_hives
    Device.classification('Hive')
  end
end
