require 'digest'
require 'base58'

module Tron
  class EscrowDeploymentWorker
    include Sidekiq::Worker
    ADDRESS_PREFIX = '41';

    def perform
      # timestamp = (Time.now.to_i - 30) * 1000
      contracts.each do |chain_id, contract|
        url = "#{contract.url}/v1/contracts/#{contract.address}/events?event_name=ContractCreated" # &min_block_timestamp=#{timestamp}"
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
      hash0 = Digest::SHA256.digest(address_bytes.pack('C*'))
      hash1 = Digest::SHA256.digest(hash0)

      check_sum = hash1.bytes[0, 4]
      check_sum = address_bytes + check_sum

      Base58.binary_to_base58(check_sum.pack('C*'))
    end
  end
end
