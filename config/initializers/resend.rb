# frozen_string_literal: true

require Rails.root.join('lib/resend_delivery')

# Send mail through Resend's API when RESEND_API_KEY is set. This runs after
# config/environments/*.rb, so it takes precedence over any SMTP settings.
ActiveSupport.on_load(:action_mailer) do
  add_delivery_method :resend, ResendDelivery

  if ENV['RESEND_API_KEY'].present? && !Rails.env.test?
    self.delivery_method = :resend
    self.resend_settings = { api_key: ENV['RESEND_API_KEY'] }
    self.raise_delivery_errors = true
  end
end
