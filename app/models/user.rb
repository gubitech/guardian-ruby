# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  username        :string(255)
#  password_digest :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ApplicationRecord
  validates :username, :presence => true, :uniqueness => true
  has_secure_password

  def self.authenticate(username, password)
    user = self.where(:username => username).first
    return nil unless user
    return nil unless user.authenticate(password)
    user
  end

end
