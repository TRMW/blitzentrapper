# frozen_string_literal: true

# Base class for the app's mailers.
class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV.fetch("MAIL_FROM", "forum@blitzentrapper.net") }

  # Production only sends mail once a provider is configured: RESEND_API_KEY
  # (config/initializers/resend.rb) or SMTP_ADDRESS (production.rb; Railway
  # only allows SMTP on the Pro plan). Until then, features that depend on
  # email stay hidden.
  def self.configured?
    return true unless Rails.env.production?

    provider = ENV["RESEND_API_KEY"].presence || ENV["SMTP_ADDRESS"].presence
    provider.present? && ENV["MAIL_FROM"].present?
  end
end
