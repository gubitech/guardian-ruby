module HasPrivateKey
  extend ActiveSupport::Concern

  included do
    attribute :private_key, PrivateKeyType.new
  end

end

class PrivateKeyType < ActiveModel::Type::Value

  def cast(value)
    if value.is_a?(OpenSSL::PKey::RSA)
      value
    else
      OpenSSL::PKey::RSA.new(value)
    end
  end

  def serialize(value)
    if value.is_a?(OpenSSL::PKey::RSA)
      value.to_s
    elsif value.is_a?(String)
      value
    else
      nil
    end
  end

  def deserialize(value)
    value.is_a?(String) ? OpenSSL::PKey::RSA.new(value) : nil
  end

end
