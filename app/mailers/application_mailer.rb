# frozen_string_literal: true

# Base class for the app's mailers.
class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV.fetch('MAIL_FROM', 'forum@blitzentrapper.net') }

  # Production only sends mail once an SMTP provider is configured (see
  # config/environments/production.rb). Until then, features that depend on
  # email stay hidden.
  def self.configured?
    return true unless Rails.env.production?

    ENV['SMTP_ADDRESS'].present? && ENV['MAIL_FROM'].present?
  end
end
