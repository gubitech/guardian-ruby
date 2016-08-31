# == Schema Information
#
# Table name: certificates
#
#  id                       :integer          not null, primary key
#  certificate_authority_id :integer
#  serial                   :integer
#  country                  :string(255)
#  state                    :string(255)
#  locality                 :string(255)
#  organization             :string(255)
#  organizational_unit      :string(255)
#  common_name              :string(255)
#  expires_at               :datetime
#  certificate              :text(65535)
#  csr                      :text(65535)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  revoked_at               :datetime
#

class Certificate < ApplicationRecord

  include HasPrivateKey
  include HasCertificate

  belongs_to :certificate_authority

  validates :certificate_authority_id, :presence => true
  validates :serial, :uniqueness => {:scope => :certificate_authority_id}
  validates :expires_at, :presence => true

  default_value :country, -> { Guardian.config.certificate_defaults.country }
  default_value :state, -> { Guardian.config.certificate_defaults.state }
  default_value :locality, -> { Guardian.config.certificate_defaults.locality }
  default_value :organization, -> { Guardian.config.certificate_defaults.organization }
  default_value :expires_at, -> { Time.now + (Guardian.config.certificate_defaults.duration || 3.years).to_i }

  def description
    if organization && organizational_unit
      "#{organization} (#{organizational_unit})"
    elsif organization
      organization
    else
      nil
    end
  end

  def revoke
    self.revoked_at = Time.now
    self.save
  end

  def revoked?
    self.revoked_at.present?
  end

  def auto_generate_certificate
    if self.private_key.nil?
      # Generate a new private key if one hasn't been provided for this certificate
      self.private_key = OpenSSL::PKey::RSA.new(2048)
    end
    self.serial = self.class.next_serial_for(self.certificate_authority)
    new_certificate = self.generate_x509_certificate(:ca => self.certificate_authority, :public_key => self.private_key.public_key, :expiry => self.expires_at, :serial => self.serial)
    self.certificate_authority.sign(new_certificate)
    self.certificate = new_certificate
  end

  def generate_certificate_from_csr
    return false if self.csr.blank?
    begin
      csr = OpenSSL::X509::Request.new(self.csr)
    rescue OpenSSL::X509::RequestError => e
      return false
    end
    return false unless csr.verify(csr.public_key)
    new_certificate = OpenSSL::X509::Certificate.new
    new_certificate.not_before  = Time.now
    new_certificate.not_after   = self.expires_at
    new_certificate.subject     = csr.subject
    new_certificate.public_key  = csr.public_key
    new_certificate.serial      = self.class.next_serial_for(self.certificate_authority)
    new_certificate.issuer      = self.certificate_authority.x509_name
    certificate_authority.sign(new_certificate)
    self.certificate = new_certificate
    import_certificate_attributes
    self
  end

  def self.next_serial_for(ca)
    (where(:certificate_authority_id => ca.id).order(:serial => :desc).first&.serial || 1) + 1
  end

end
