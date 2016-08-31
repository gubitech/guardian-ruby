require 'guardian/config'

# Add the OCSP middleware
Rails.application.config.middleware.use Guardian::OCSPMiddleware
