require 'digest'
require 'sidekiq-scheduler'

BASE = 58
ALPHABET = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'

module Tron
  class EscrowDeploymentWorker
    include Sidekiq::Worker
    ADDRESS_PREFIX = '41';

    def perform
      timestamp = (Time.now.to_i - 30) * 1000
      contracts.each do |chain_id, contract|
        url = "#{contract.url}/v1/contracts/#{contract.address}/events?event_name=ContractCreated&min_block_timestamp=#{timestamp}"
        response = RestClient.get(url, headers = headers)
        next unless response.code == 200

        json = JSON.parse(response.body)
        data = json.fetch('data', [])
        next unless data.any?

        data.each do |event|
          new_event = OpenStruct.new(event)
          seller = new_event.result.fetch('_seller')
          address = new_event.result.fetch('_deployment')
          next unless seller && address
          
          address = get_base58_check_address(hex_str2byte_array(address.gsub(/^0x/, ADDRESS_PREFIX)))
          seller = get_base58_check_address(hex_str2byte_array(seller.gsub(/^0x/, ADDRESS_PREFIX)))

          seller = User.find_or_create_by_address(seller)
          version = Setting['contract_version'] || '1'
      
          return if seller.contracts.find_by(address: address, chain_id: chain_id, version: version)
      
          contract = seller.contracts.create(address: address, chain_id: chain_id, version: version)
          # @TODO: Setup escrow events on TronSave
          # EscrowEventsSetupWorker.new.perform(contract.id, chain_id)
        end
      end
    end

    private
    
    def contracts
      {
        999999992 => OpenStruct.new({ address: 'TFA761EdwDnr86PeEMVLopd8UbJfEz7tgn', url: 'https://nile.trongrid.io' })
      }
    end

    def headers
      {
        'accept' => 'application/json',
        'content-type' => 'application/json'
      }
    end

    def is_hex_char(c)
      if (
        (c >= "A" && c <= "F") ||
        (c >= "a" && c <= "f") ||
        (c >= "0" && c <= "9")
      )
        return 1
      end
    
      return 0
    end
    
    def hex_char2byte(c)
      d = nil
    
      if (c >= "A" && c <= "F")
        d = c.ord - "A".ord + 10
      elsif (c >= "a" && c <= "f")
        d = c.ord - "a".ord + 10
      elsif (c >= "0" && c <= "9")
        d = c.ord - "0".ord
      end
    
      if d.is_a?(Numeric)
        return d
      else
        raise "The passed hex char is not a valid hex char"
      end
    end
    
    def hex_str2byte_array(str, strict = false)
      if !str.is_a?(String)
        raise "The passed string is not a string"
      end
    
      len = str.length
    
      if strict
        if len % 2 != 0
          str = "0" + str
          len += 1
        end
      end
    
      byte_array = []
      d = 0
      j = 0
      k = 0
    
      for i in 0...len
        c = str[i]
    
        if is_hex_char(c) == 1
          d <<= 4
          d += hex_char2byte(c)
          j += 1
    
          if j % 2 == 0
            byte_array[k] = d
            k += 1
            d = 0
          end
        else
          raise "The passed hex char is not a valid hex string"
        end
      end
    
      return byte_array
    end

    def get_base58_check_address(address_bytes)
      hash0 = sha256(address_bytes)
      hash1 = sha256(hash0)

      check_sum = hash1[0, 4]
      check_sum = address_bytes + check_sum

      encode58(check_sum)
    end

    def byte2hex_str(byte)
      raise 'Input must be a number' unless byte.is_a?(Integer)
      raise 'Input must be a byte' unless byte >= 0 && byte <= 255
    
      hex_byte_map = '0123456789ABCDEF'
    
      str = ''
      str += hex_byte_map[byte >> 4]
      str += hex_byte_map[byte & 0x0f]
    
      str
    end
    
    def byte_array2hex_str(byte_array)
      str = ''
    
      byte_array.each do |byte|
        str += byte2hex_str(byte)
      end
    
      str
    end

    def sha256(msg_bytes)
      msg_hex = byte_array2hex_str(msg_bytes)
      hash_hex = Digest::SHA256.hexdigest(msg_bytes.pack('c*'))
      hex_str2byte_array(hash_hex)
    end

    def encode58(buffer)
      return "" if buffer.empty?

      digits = [0]

      buffer.each do |byte|
        carry = byte

        digits.each_index do |j|
          total = digits[j] * 256 + carry
          carry, remainder = total.divmod(BASE)
          digits[j] = remainder
        end

        while carry > 0
          carry, remainder = carry.divmod(BASE)
          digits << remainder
        end
      end

      # Deal with leading zeros
      buffer.each do |byte|
        break if byte != 0
        digits << 0
      end

      digits.reverse.map { |digit| ALPHABET[digit] }.join
    end
  end
end
