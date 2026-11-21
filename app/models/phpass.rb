# frozen_string_literal: true

require 'digest/md5'

# Verifies "portable" phpass hashes ("$P$..."), the format used by the
# WordPress/phpBB accounts this site imported.
# https://www.openwall.com/phpass/
module Phpass
  ITOA64 =
    './0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.freeze

  def self.valid?(password, hash)
    return false unless hash.is_a?(String) && hash.length == 34
    return false unless hash.start_with?('$P$', '$H$')

    count_log2 = ITOA64.index(hash[3])
    return false unless count_log2&.between?(7, 30)

    salt = hash[4, 8]
    digest = Digest::MD5.digest(salt + password)
    (1 << count_log2).times { digest = Digest::MD5.digest(digest + password) }
    expected = hash[0, 12] + encode64(digest)
    ActiveSupport::SecurityUtils.secure_compare(expected, hash)
  end

  def self.encode64(input)
    bytes = input.bytes
    output = +''
    i = 0
    while i < bytes.length
      value = bytes[i]
      i += 1
      output << ITOA64[value & 0x3f]
      value |= bytes[i] << 8 if i < bytes.length
      output << ITOA64[(value >> 6) & 0x3f]
      break if i >= bytes.length

      i += 1
      value |= bytes[i] << 16 if i < bytes.length
      output << ITOA64[(value >> 12) & 0x3f]
      break if i >= bytes.length

      i += 1
      output << ITOA64[(value >> 18) & 0x3f]
    end
    output
  end
  private_class_method :encode64
end
