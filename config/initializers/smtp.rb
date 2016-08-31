require 'guardian/config'
if Guardian.config&.smtp
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {:address => Guardian.config.smtp.host, :user_name => Guardian.config.smtp.username, :password => Guardian.config.smtp.password}
end
