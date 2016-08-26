class CertificateAuthoritiesController < ApplicationController

  def index
    @cas = CertificateAuthority.order(:name)
  end

  def show
    @ca = CertificateAuthority.find(params[:id])
  end

  def new
    @ca = CertificateAuthority.new
  end

  def create
    @ca = CertificateAuthority.new(params.require(:certificate_authority).permit(:country, :state, :locality, :organization, :organization_unit, :common_name))
    @ca.expires_at = 50.years.from_now
    @ca.auto_generate_certificate
    if @ca.save
      redirect_to certificates_path(:ca => @ca), :notice => "Certificate Authority has been created successfully"
    else
      render 'new'
    end
  end

  def destroy
    @ca = CertificateAuthority.find(params[:id])
    @ca.destroy
    redirect_to root_path, :notice => "Certificate Authority has been removed successfully"
  end

end
