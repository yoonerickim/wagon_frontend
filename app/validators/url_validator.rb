class UrlValidator < ActiveModel::EachValidator
  def validate_each(record,attribute,value)
    begin
    address = URI.parse(value).class == URI::HTTP
    rescue URI::InvalidURIError
      address = false
    end

    return if options[:allow_blank] && value.blank?

    record.errors[attribute] << (options[:message] || "is invalid") unless address
  end
end
