# == Schema Information
#
# Table name: certificate_authorities
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  private_key         :text(65535)
#  certificate         :text(65535)
#  expires_at          :datetime
#  country             :string(255)
#  state               :string(255)
#  locality            :string(255)
#  organization        :string(255)
#  organizational_unit :string(255)
#  common_name         :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class CertificateAuthority < ApplicationRecord

  include HasCertificate
  include HasPrivateKey

  has_many :certificates, :dependent => :destroy

  validates :private_key, :presence => true
  validates :expires_at, :presence => true

  def auto_generate_certificate
    self.private_key = OpenSSL::PKey::RSA.new(2048)
    new_certificate = self.generate_x509_certificate(:public_key => self.private_key.public_key, :expiry => self.expires_at, :is_ca => true)
    self.sign(new_certificate)
    self.certificate = new_certificate
  end

  def sign(certificate)
    certificate.sign(self.private_key, OpenSSL::Digest::SHA256.new)
  end

end
