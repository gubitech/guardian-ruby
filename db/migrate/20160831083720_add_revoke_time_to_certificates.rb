class AddRevokeTimeToCertificates < ActiveRecord::Migration[5.0]
  def change
    add_column :certificates, :revoked_at, :datetime
  end
end
