require_relative '../lib/guardian/config'
threads_count = Guardian.config.web_server&.max_threads&.to_i || 5
threads         threads_count, threads_count

bind_address  = Guardian.config.web_server&.bind_address || '127.0.0.1'
bind_port     = Guardian.config.web_server&.port&.to_i || 5000
bind            "tcp://#{bind_address}:#{bind_port}"

environment     Guardian.config.rails&.environment || 'development'
