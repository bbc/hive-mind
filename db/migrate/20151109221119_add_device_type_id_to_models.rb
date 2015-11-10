class AddDeviceTypeIdToModels < ActiveRecord::Migration
  def change
    add_reference :models, :device_type, index: true
  end
end
