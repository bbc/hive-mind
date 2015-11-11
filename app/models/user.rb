class User < ActiveRecord::Base

  def self.find_or_create_from_omniauth_hash(credentials)
    User.where( provider: credentials[:provider], uid: credentials[:uid]).first_or_create do |user|
      user.email = credentials[:email]
      user.name  = credentials[:name]
    end
  end

  def self.anonymous_user
    User.find_or_create_by(:uid => 'anonymous', :provider => 'default')
  end
end