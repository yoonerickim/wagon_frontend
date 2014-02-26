class FaxMachine

  ERRORS = {
    -112 => 'No valid recipients added or missing fax number or attempting to fax to a number that is not the designated fax number in a developer account.',
    -114 => 'Postpone date too late (can be no later than 30 days from now)',
    -123 => 'No valid documents attached',
    -150 => 'Internal System Error',
    -310 => 'User is not authorized to operate actions on RequestedUserID',
    -311 => 'Transaction does not belong to requested user',
    -312 => 'Email(s) already resent',
    -1002 => 'Number of types does not match number of document sizes string',
    -1003 => 'Authentication error',
    -1004 => 'Missing file type',
    -1005 => 'Transaction does not exist',
    -1007	=> 'Size value is not numeric or not greater than 0',
    -1008	=> 'Total sizes does not match filesdata length',
    -1009	=> "Image not available (may happen if the 'delete fax after completion' feature is active)",
    -1030	=> 'Invalid Verb or VerbData',
    -1062	=> 'Wrong session ID',
    -3001	=> 'Invalid MessageID',
    -3002	=> '"From" parameter is larger than image size',
    -3003	=> "Image doesn't exist",
    -3004	=> 'TIFF file is empty',
    -3005	=> 'Requested chunk size is invalid (less than 1 or greater than the maximum value defined under "System Limitations")',
    -3006	=> 'Max item is smaller than 1',
    -3007	=> 'No permission for this action (In inbound method GetList, LType is set to AccountAllMessages or AccountNewMessages, when the username is not a Primary user)'
  }.freeze

  # Public: Send a fax.
  #
  # Required options:
  # :fax_number
  # :data
  # :file_type - 'TXT', 'HTML', etc
  #
  def self.send(options = {})
    @client ||= Savon::Client.new do
      wsdl.document = "https://ws.interfax.net/dfs.asmx?WSDL"
    end

    @username ||= ENV['INTERFAX_USERNAME'] || config['username']
    @password ||= ENV['INTERFAX_PASSWORD'] || config['password']

    _options = {
      'Username' => @username,
      'Password' => @password
    }
    options = options.inject(_options) { |h, (k,v)| h[k.to_s.camelize] = v; h }

    response_result = @client.request 'SendCharFax' do
      http.headers["SOAPAction"] = "http://www.interfax.cc/#{soap.input[1]}"
      soap.body = options
    end

    result = response_result.to_hash[:send_char_fax_response][:send_char_fax_result]
    raise PaperJamError.new error?(result) if error?(result)
    result
  end

  private

  # Private: Get error code.
  #
  # Return message or false, if no error.
  def self.error? code
    ERRORS.fetch(code.to_i, false)
  end

  # Private: Parse the config file.
  #
  def self.config
    require 'yaml'
    YAML::load_file(File.open("#{Rails.root}/config/interfax.yml"))
  end

  # "Why does it say paper jam when there is no paper jam?!?" --Samir 
  # Nagheenanajar, Office Space
  #
  class PaperJamError < StandardError; end

end
