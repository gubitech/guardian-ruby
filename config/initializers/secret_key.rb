if Guardian.config.rails && Guardian.config.rails.secret_key
  Rails.application.secrets.secret_key_base = Guardian.config.rails.secret_key
else
  $stderr.puts "No secret key was specified in the Guardian config file. Using one for just this session"
  Rails.application.secrets.secret_key_base = SecureRandom.hex(128)
end
