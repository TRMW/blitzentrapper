# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

class ResendDeliveryTest < ActiveSupport::TestCase
  # Stands in for Net::HTTP: records the request and returns a response.
  class FakeHTTP
    attr_reader :last_request

    def initialize(response)
      @response = response
    end

    def request(req)
      @last_request = req
      @response
    end
  end

  setup do
    @mail = Mail.new do
      from "Blitzen Trapper Forum <forum@example.com>"
      to "fan@example.com"
      subject "Reset your password"
      body "Open this link"
    end
    @delivery = ResendDelivery.new(api_key: "re_test")
  end

  test "posts the email to the Resend API" do
    fake = FakeHTTP.new(Net::HTTPOK.new("1.1", "200", "OK"))
    Net::HTTP.stub(:start, ->(*_args, **_opts, &blk) { blk.call(fake) }) do
      @delivery.deliver!(@mail)
    end

    assert_equal "Bearer re_test", fake.last_request["Authorization"]
    body = JSON.parse(fake.last_request.body)
    assert_equal "Blitzen Trapper Forum <forum@example.com>", body["from"]
    assert_equal [ "fan@example.com" ], body["to"]
    assert_equal "Reset your password", body["subject"]
    assert_equal "Open this link", body["text"]
  end

  test "raises when Resend rejects the email" do
    response = Net::HTTPUnprocessableEntity.new("1.1", "422", "Unprocessable")
    response.instance_variable_set(:@read, true)
    response.instance_variable_set(:@body, '{"message":"bad from"}')
    fake = FakeHTTP.new(response)

    Net::HTTP.stub(:start, ->(*_args, **_opts, &blk) { blk.call(fake) }) do
      error = assert_raises(ResendDelivery::DeliveryError) do
        @delivery.deliver!(@mail)
      end
      assert_match "422", error.message
    end
  end
end
