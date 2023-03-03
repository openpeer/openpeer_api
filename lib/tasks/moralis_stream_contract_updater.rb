class MoralisStreamContractUpdater
  attr_accessor :abi_file, :stream_id

  def initialize(stream_id, abi_file)
    @stream_id = stream_id
    @abi_file = abi_file
  end

  def execute
    if abi
      puts abi
      # puts "ABI update: #{RestClient.post(url, payload, headers).code}"
    end
  end

  private

  def url
    "https://api.moralis-streams.com/streams/evm/#{stream_id}"
  end

  def payload
    {'abi' => abi }.to_json
  end

  def abi
    JSON.parse(File.read(abi_file)) if abi_file
  end

  def headers
    {
      'accept' => 'application/json',
      'X-API-Key' => ENV['MORALIS_API_KEY'],
      'content-type' => 'application/json'
    }
  end
end
