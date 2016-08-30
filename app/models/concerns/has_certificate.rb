module HasCertificate
  extend ActiveSupport::Concern

  included do
    attribute :certificate, CertificateType.new
    validates :country, :presence => true
    validates :state, :presence => true
    validates :organization, :presence => true
    validates :common_name, :presence => true
  end

  def x509_name
    @x509_name ||= begin
      hash = {}
      hash['C']   = self.country
      hash['ST']  = self.state
      hash['CN']  = self.common_name
      hash['O']   = self.organization
      hash['L']   = self.locality             if self.locality
      hash['OU']  = self.organizational_unit  if self.organizational_unit
      OpenSSL::X509::Name.new(hash.to_a)
    end
  end

  def generate_x509_certificate(options = {})
    options[:serial]              ||= 1
    options[:expiry]              ||= 1.year.from_now
    options[:version]             ||= 2 # 0x2 is actually v3

    x509_certificate              = OpenSSL::X509::Certificate.new
    x509_certificate.not_before   = Time.now
    x509_certificate.not_after    = options[:expiry]
    x509_certificate.serial       = options[:serial]
    x509_certificate.version      = options[:version]
    x509_certificate.subject      = self.x509_name

    if options[:ca]
      x509_certificate.issuer     = options[:ca].x509_name
    else
      x509_certificate.issuer     = self.x509_name
    end

    if options[:public_key]
      x509_certificate.public_key = options[:public_key]
    end

    if options[:is_ca]
      extension_factory = OpenSSL::X509::ExtensionFactory.new
      extension_factory.subject_certificate = x509_certificate
      extension_factory.issuer_certificate = x509_certificate
      x509_certificate.add_extension(extension_factory.create_extension('subjectKeyIdentifier', 'hash'))
      x509_certificate.add_extension(extension_factory.create_extension('basicConstraints', 'CA:TRUE', true))
      x509_certificate.add_extension(extension_factory.create_extension('keyUsage', 'cRLSign,keyCertSign', true))
    end

    x509_certificate
  end

  def import_certificate_attributes
    self.expires_at           = certificate.not_after
    self.serial               = certificate.serial.to_i if self.respond_to?(:serial=)
    self.country              = value_from_x509_name(certificate.subject, 'C')
    self.state                = value_from_x509_name(certificate.subject, 'ST')
    self.locality             = value_from_x509_name(certificate.subject, 'L')
    self.common_name          = value_from_x509_name(certificate.subject, 'CN')
    self.organization         = value_from_x509_name(certificate.subject, 'O')
    self.organizational_unit  = value_from_x509_name(certificate.subject, 'OU')
  end

  def value_from_x509_name(subject, field)
    item = subject.to_a.select { |a| a[0] == field }.first
    item ? item[1] : nil
  end

end

class CertificateType < ActiveModel::Type::Value

  def cast(value)
    if value.is_a?(OpenSSL::X509::Certificate)
      value
    else
      OpenSSL::X509::Certificate.new(value)
    end
  end

  def serialize(value)
    if value.is_a?(OpenSSL::X509::Certificate)
      value.to_s
    elsif value.is_a?(String)
      value
    else
      nil
    end
  end

  def deserialize(value)
    value.is_a?(String) ? OpenSSL::X509::Certificate.new(value) : nil
  rescue OpenSSL::X509::CertificateError => e
    puts "\e[41;37mCertificate Error: #{e.message}\e[0m\e[31m"
    puts value.inspect + "\e[0m"
    raise
  end

end
