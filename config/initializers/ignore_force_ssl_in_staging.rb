module ActionController
  module ForceSSL
    module ClassMethods
      def force_ssl(options = {})
        before_filter(options) do
          if !request.ssl? && !Rails.env.staging? && !Rails.env.development? && !Rails.env.test?
            redirect_to :protocol => 'https://', :status => :moved_permanently
          end
        end
      end
    end
  end
end
