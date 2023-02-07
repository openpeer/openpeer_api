class Uuid
  class << self
    def generate
      convert_string_bytes_32 SecureRandom.hex(15)
    end

    def convert_string_bytes_32(str)
      hex = str.unpack("H*")[0]
      "0x#{hex}#{"0" * (64 - hex.length)}"
    end
  end
end
