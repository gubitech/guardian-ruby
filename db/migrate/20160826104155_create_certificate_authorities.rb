class CreateCertificateAuthorities < ActiveRecord::Migration[5.0]
  def change
    create_table :certificate_authorities do |t|
      t.string :name
      t.text :private_key
      t.text :certificate
      t.datetime :expires_at
      t.string :country, :state, :locality, :organization, :organizational_unit, :common_name
      t.timestamps
    end
  end
end
