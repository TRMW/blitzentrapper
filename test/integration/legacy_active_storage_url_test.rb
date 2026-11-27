# frozen_string_literal: true

require "test_helper"

# Active Storage URLs signed by Rails 6 (SHA1-derived keys, Marshal payloads in
# the old metadata envelope) must still resolve. Crawlers and old pages keep
# requesting them. See config/initializers/message_verifier_rotator.rb.
class LegacyActiveStorageUrlTest < ActionDispatch::IntegrationTest
  setup do
    @blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join("app/assets/images/bg-button.gif")), filename: "avatar.gif"
    )
  end

  test "a Rails 6 avatar variant URL redirects to the image" do
    get "/rails/active_storage/representations/#{legacy_signed(@blob.id, "blob_id")}/" \
      "#{legacy_signed({ resize: "115x115" }, "variation")}/avatar.gif"

    assert_response :redirect
  end

  test "a Rails 6 blob URL redirects to the file" do
    get "/rails/active_storage/blobs/#{legacy_signed(@blob.id, "blob_id")}/avatar.gif"

    assert_response :redirect
  end

  test "current URLs still work and a bad signature is still rejected" do
    get rails_blob_path(@blob, only_path: true)
    assert_response :redirect

    get "/rails/active_storage/blobs/#{legacy_signed(@blob.id, "blob_id").sub(/.{4}\z/, "0000")}/avatar.gif"
    assert_response :not_found
  end

  test "new URLs are signed with the current keys" do
    current = ActiveSupport::KeyGenerator.new(
      Rails.application.secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA256
    ).generate_key("ActiveStorage")
    verifier = ActiveSupport::MessageVerifier.new(current, digest: "SHA1", serializer: JSON)

    assert_equal @blob.id, verifier.verify(@blob.signed_id, purpose: :blob_id)
  end

  private

  # What Rails 6.0's ActiveStorage.verifier wrote, e.g.
  # eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBaDRCIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--69cb4023...
  def legacy_signed(value, purpose)
    key = ActiveSupport::KeyGenerator.new(
      Rails.application.secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
    ).generate_key("ActiveStorage")
    envelope = { "_rails" => { "message" => Base64.strict_encode64(Marshal.dump(value)), "exp" => nil, "pur" => purpose } }
    data = Base64.strict_encode64(envelope.to_json)
    "#{data}--#{OpenSSL::HMAC.hexdigest("SHA1", key, data)}"
  end
end
