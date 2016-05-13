class AddAttachmentScreenshotToHiveMindMobilePlugins < ActiveRecord::Migration
  def self.up
    change_table :hive_mind_mobile_plugins do |t|
      t.attachment :screenshot
    end
  end

  def self.down
    remove_attachment :hive_mind_mobile_plugins, :screenshot
  end

end
