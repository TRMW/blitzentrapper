# frozen_string_literal: true

require 'json'
require 'net/http'

# ActionMailer delivery method that sends through Resend's HTTPS API.
# Railway blocks outbound SMTP below the Pro plan, so SMTP can't be used.
# https://resend.com/docs/api-reference/emails/send-email
class ResendDelivery
  class DeliveryError < StandardError; end

  ENDPOINT = URI('https://api.resend.com/emails').freeze

  attr_accessor :settings

  def initialize(settings)
    @settings = settings
  end

  def deliver!(mail)
    response = Net::HTTP.start(ENDPOINT.host, ENDPOINT.port, use_ssl: true,
                               open_timeout: 5, read_timeout: 10) do |http|
      http.request(build_request(mail))
    end
    return response if response.is_a?(Net::HTTPSuccess)

    raise DeliveryError, "Resend returned #{response.code}: #{response.body}"
  end

  private

  def build_request(mail)
    request = Net::HTTP::Post.new(ENDPOINT)
    request['Authorization'] = "Bearer #{settings.fetch(:api_key)}"
    request['Content-Type'] = 'application/json'
    request.body = payload(mail).to_json
    request
  end

  def payload(mail)
    {
      from: mail[:from].to_s,
      to: mail.to,
      subject: mail.subject,
      text: (mail.text_part || mail).body.decoded,
      html: mail.html_part&.body&.decoded
    }.compact
  end
end
