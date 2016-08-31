class ApplicationMailer < ActionMailer::Base
  default :from => Guardian.config.smtp.from_address
  layout false
end

