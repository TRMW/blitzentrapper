# frozen_string_literal: true

require "digest/md5"

# Verifies "portable" phpass hashes ("$P$..."), the format used by the
# WordPress/phpBB accounts this site imported.
# https://www.openwall.com/phpass/
module Phpass
  ITOA64 = "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

  def self.valid?(password, hash)
    return false unless well_formed?(hash)

    expected = hash[0, 12] + encode64(digest(password, hash))
    ActiveSupport::SecurityUtils.secure_compare(expected, hash)
  end

  def self.well_formed?(hash)
    hash.is_a?(String) && hash.length == 34 &&
      hash.start_with?("$P$", "$H$") &&
      ITOA64.index(hash[3]).to_i.between?(7, 30)
  end

  # Salted MD5, iterated 2**(cost) times; the cost is encoded in hash[3].
  def self.digest(password, hash)
    rounds = 1 << ITOA64.index(hash[3])
    value = Digest::MD5.digest(hash[4, 8] + password)
    rounds.times { value = Digest::MD5.digest(value + password) }
    value
  end

  # phpass's base64 variant: little-endian groups of up to 3 bytes, written
  # 6 bits per character, with one more character than bytes in the group.
  def self.encode64(input)
    input.bytes.each_slice(3).map { |group| encode_group(group) }.join
  end

  def self.encode_group(bytes)
    value = bytes.each_with_index.sum { |byte, i| byte << (8 * i) }
    Array.new(bytes.length + 1) { |i| ITOA64[(value >> (6 * i)) & 0x3f] }.join
  end

  private_class_method :well_formed?, :digest, :encode64, :encode_group
end
