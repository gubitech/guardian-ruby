class CreateCertificates < ActiveRecord::Migration[5.0]
  def change
    create_table :certificates do |t|
      t.integer :certificate_authority_id
      t.integer :serial
      t.string :country, :state, :locality, :organization, :organizational_unit, :common_name
      t.datetime :expires_at
      t.text :certificate, :csr
      t.timestamps
    end
  end
end
