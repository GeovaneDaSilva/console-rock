module Users
  # Two Factor Authentication
  class TwoFactorController < AuthenticatedController
    helper_method :fill_qr!, :fill_backup_codes

    skip_before_action :force_2fa

    def show
      authorize current_user, :show?
    end

    def destroy
      authorize current_user, :destroy?
      current_user.remove_two_factor_authentication!
      redirect_back fallback_location: :edit_user_registration_path
    end

    def create
      authorize current_user, :create?
      if current_user.authenticate_otp(params[:code])
        current_user.update(otp_backup_codes: [])
        render "new_two_factor"
      else
        flash[:error] = "Incorrect code.  Please try your code again or re-initialize your app"
        redirect_back fallback_location: qr_path
      end
    end

    private

    def fill_backup_codes
      current_user.render_backup_codes
    end

    def fill_qr!
      qrcode = current_user.generate_qr!

      if !qrcode.nil?
        qrcode.as_html
      else
        flash.now[:error] = "Problem setting up two factor authentication"
        RQRCode::QRCode.new("www.google.com").as_html
      end
    end
  end
end
