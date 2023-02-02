class Uuid
  class << self
    def generate
      convert_string_bytes_32 SecureRandom.hex(15)
    end

    def convert_string_bytes_32(str)
      bytes32 = [str[2..-1]].pack("H*")
      hex = bytes32.unpack("H*")[0]
      "0x#{hex}#{"0" * (64 - hex.length)}"
    end
  end
end
