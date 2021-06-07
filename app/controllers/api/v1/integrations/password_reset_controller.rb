module Api
  module V1
    module Integrations
      # API endpoint allowing for request of password reset link
      class PasswordResetController < Api::V1::Integrations::Pax8BaseController
        # by extending Pax8BaseController, these all have "authenticate" as a before_action

        def create
          reset_link = generate_password_reset

          if reset_link.nil?
            render json: { error: "Password generation failure" }, status: :not_found
          else
            render json: { link: reset_link }
          end
        end

        def generate_password_reset
          user = find_user
          return if user.nil?

          raw, hashed = Devise.token_generator.generate(User, :reset_password_token)
          user.reset_password_token = hashed
          user.reset_password_sent_at = Time.now.utc
          if user.save
            return edit_password_url(
              user,
              reset_password_token: raw,
              host:                 ENV.fetch("HOST", "example.com")
            ).remove(/:\d+/)
          end
          nil
        end

        def find_user
          account.self_and_all_descendants.collect do |acc|
            acc.users.where(email: params[:email])
          end.flatten.first
        end
      end
    end
  end
end
