class CertificatesController < ApplicationController

  before_action { params[:id] && @cert = Certificate.find(params[:id]) }

  def index
    @ca = CertificateAuthority.find(params[:ca])
    @certs = @ca.certificates.order(:serial => :desc)
  end

  def show
  end

  def new
    @cert = Certificate.new
    @cert.expires_at = Time.at(Time.now + (Guardian.config.certificate_defaults.duration || 3.years).to_i)
    if params[:ca]
      @cert.certificate_authority = CertificateAuthority.find(params[:ca])
    end
  end

  def new_from_csr
    new
  end

  def create
    @cert = Certificate.new(params.require(:certificate).permit(:certificate_authority_id, :country, :state, :locality, :organization, :organizational_unit, :common_name, :expires_at))
    @cert.auto_generate_certificate
    if @cert.save
      flash[:private_key] =  @cert.private_key.to_pem if @cert.private_key
      redirect_to certificate_path(@cert), :notice => "Certificate has been generated successfully"
    else
      render 'new'
    end
  end

  def create_from_csr
    @cert = Certificate.new(params.require(:certificate).permit(:certificate_authority_id, :expires_at, :csr))
    @cert.generate_certificate_from_csr
    if @cert.save
      redirect_to certificate_path(@cert), :notice => "Certificate has been s successfully"
    else
      render 'new_from_csr'
    end
  end

  def revoke
    if @cert.revoke
      redirect_to certificate_path(@cert), :notice => "Certificate has been marked as revoked."
    else
      redirect_to certificate_path(@cert), :alert => @cert.errors.full_messages.to_sentence
    end
  end

end
