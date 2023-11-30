require 'digest'

module Tron
  class Address
    class << self
      def valid?(address)
        begin
          hex = base58_to_hex(address)
          data = [hex].pack('H*')
          decoded_checksum = data[-4..-1]
          
          # Take the first 21 bytes
          first_21_bytes = data[0...21]

          # Double SHA256 hash the first 21 bytes
          hash1 = Digest::SHA256.digest(first_21_bytes)
          hash2 = Digest::SHA256.digest(hash1)

          calculated_checksum = hash2.byteslice(0, 4)

          decoded_checksum == calculated_checksum
        rescue
          false
        end
      end

      private

      def base58_to_hex(base58)
        alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'

        long_value = 0
        index = 0

        base58.reverse.each_char do |char|
          long_value += alphabet.index(char) * (58**index)
          index += 1
        end

        hex = long_value.to_s(16)

        # Add leading zeros if necessary
        leading_zeros = (base58.chars.find_index { |c| c != '1' } || 0) / 3
        hex = '00' * leading_zeros + hex if leading_zeros > 0

        hex
      end
    end
  end
end
