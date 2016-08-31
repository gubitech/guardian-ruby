require 'openssl'
include OpenSSL::OCSP

module Guardian
  class OCSPMiddleware

    def initialize(app)
      @app = app
    end

    def generate_http_response(status, data = nil)
      response_der = OpenSSL::OCSP::Response.create(status, data).to_der
      [200, {'content-type' => 'application/ocsp-response', 'content-length' => response_der.bytesize.to_s}, [response_der]]
    end

    def log_error(e)
      puts "#{e.class} #{e.message}"
      puts e.backtrace
    end

    def call(env)
      path_parts = env['PATH_INFO'].sub(/^\//, '').split('/')
      if path_parts.first == 'ocsp'
        begin
          if ca = CertificateAuthority.where(:id => path_parts[1].to_i).first
            begin
              if env['REQUEST_METHOD'] == 'POST'
                request = OpenSSL::OCSP::Request.new(env['rack.input'].read)
              elsif env['REQUEST_METHOD'] == 'GET'
                req_b64 = path_parts[2..-1].join('/')
                req = Base64.decode64(req_b64)
                request = OpenSSL::OCSP::Request.new(req)
              else
                return generate_http_response(RESPONSE_STATUS_MALFORMEDREQUEST)
              end
            rescue
              return generate_http_response(RESPONSE_STATUS_MALFORMEDREQUEST)
            end
            basic_response = OpenSSL::OCSP::BasicResponse.new
            request.certid.each do |certid|
              if certificate = ca.certificates.where(:serial => certid.serial.to_i).first
                if certificate.revoked?
                  basic_response.add_status(certid, V_CERTSTATUS_REVOKED, OpenSSL::OCSP::REVOKED_STATUS_UNSPECIFIED, Time.now.to_i - certificate.revoked_at.to_i, -1800, 3600, [])
                else
                  basic_response.add_status(certid, V_CERTSTATUS_GOOD, OpenSSL::OCSP::REVOKED_STATUS_UNSPECIFIED, 0, -1800, 3600, [])
                end
              else
                basic_response.add_status(certid, V_CERTSTATUS_UNKNOWN, OpenSSL::OCSP::REVOKED_STATUS_UNSPECIFIED, 0, -1800, 3600, [])
              end
            end
            basic_response.copy_nonce(request)
            basic_response.sign(ca.certificate,ca.private_key)
            return generate_http_response(RESPONSE_STATUS_SUCCESSFUL, basic_response)
          else
            return generate_http_response(RESPONSE_STATUS_UNAUTHORIZED)
          end
        rescue => e
          log_error(e)
          return generate_http_response(RESPONSE_STATUS_INTERNALERROR)
        end
      else
        @app.call(env)
      end
    rescue => e
      log_error(e)
      [500, {}, "An internet server errror occurred."]
    end

  end
end
