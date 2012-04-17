# encoding: utf-8
module WebTranslateIt
  class String
    require 'net/https'
    
    attr_accessor :api_key, :id, :key, :plural, :type, :dev_comment, :word_count, :status, :category, :label, :file,
                  :created_at, :updated_at, :translations, :new_record
    
    # Initialize a new WebTranslateIt::String
    # The only mandatory parameter is `api_key`
    #
    # Implementation Example:
    #
    #   WebTranslateIt::String.new('secret_api_token', { "key" => "product_name_123" }
    #
    # to instantiate a new String without any text.
    #
    #   translation = WebTranslateIt::Translation.new({ "locale" => "en", "text" => "Some text" })
    #   WebTranslateIt::String.new('secret_api_token, { "key" => "product_name_123", "translations" => [translation]})
    #
    # to instantiate a new String with a source translation.
    
    def initialize(api_key, params = {})
      self.api_key      = api_key
      self.id           = params["id"] || nil
      self.key          = params["key"] || nil
      self.plural       = params["plural"] || nil
      self.type         = params["type"] || nil
      self.dev_comment  = params["dev_comment"] || nil
      self.word_count   = params["word_count"] || nil
      self.status       = params["status"] || nil
      self.category     = params["category"] || nil
      self.label        = params["label"] || nil
      self.file         = params["file"] || nil
      self.created_at   = params["created_at"] || nil
      self.updated_at   = params["updated_at"] || nil
      self.translations = params["translations"] || []
      self.new_record   = true
    end
    
    # Find a String based on criteria
    # Needs a HTTPS Connection
    #
    # Implementation Example:
    #
    #   http = WebTranslateIt::Util.http_connection
    #   WebTranslateIt::String.find_all(http_connection, 'secret_api_token', { "key" => "product_name_123" }
    #
    # to find and instantiate an array of String which key is like `product_name_123`.
    #
    
    def self.find_all(http_connection, api_key, params = {})
      url = "/api/projects/#{api_key}/strings.yaml"
      url += '?' + HashUtil.to_param({ :filters => params }) unless params.blank?

      request = Net::HTTP::Get.new(url)
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)

      begin
        response = Util.handle_response(http_connection.request(request), true)
        strings = []
        YAML.load(response).each do |string_response|
          string = WebTranslateIt::String.new(api_key, string_response)
          string.new_record = false
          strings.push(string)
        end
        return strings
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        retry
      end
    end
    
    # Find a String based on its ID
    # Needs a HTTPS Connection
    #
    # Implementation Example:
    #
    #   http = WebTranslateIt::Util.http_connection
    #   WebTranslateIt::String.find(http_connection, 'secret_api_token', 1234 }
    #
    # to find and instantiate the String which ID is `1234`.
    #
    
    def self.find(http_connection, api_key, id)
      request = Net::HTTP::Get.new("/api/projects/#{api_key}/strings/#{id}.yaml")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)

      begin
        response = Util.handle_response(http_connection.request(request), true)
        string = WebTranslateIt::String.new(api_key, YAML.load(response))
        string.new_record = false
        return string
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        retry
      end
    end
    
    # Save changes or create a String to WebTranslateIt.com
    # Needs a HTTPS Connection
    #
    # Implementation Example:
    #
    #   http = WebTranslateIt::Util.http_connection
    #   string = WebTranslateIt::String.find(http_connection, 'secret_api_token', 1234 }
    #   string.status = "status_obsolete"
    #   string.save(http_connection)
    #
    
    def save(http_connection)
      if self.new_record
        self.create(http_connection)
      else
        self.update(http_connection)
      end
    end
    
    # Delete a String on WebTranslateIt.com
    # Needs a HTTPS Connection
    #
    # Implementation Example:
    #
    #   http = WebTranslateIt::Util.http_connection
    #   string = WebTranslateIt::String.find(http_connection, 'secret_api_token', 1234 }
    #   string.delete(http_connection)
    #
    
    def delete(http_connection)
      request = Net::HTTP::Delete.new("/api/projects/#{self.api_key}/strings/#{self.id}")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)

      begin
        Util.handle_response(http_connection.request(request), true)
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        retry
      end
    end
    
    def translation_for(http_connection, locale)
      return self.translations unless self.translations == []
      request = Net::HTTP::Get.new("/api/projects/#{self.api_key}/strings/#{self.id}/locales/#{locale}/translations.yaml")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)

      begin
        response = Util.handle_response(http_connection.request(request), true)
        translation = WebTranslateIt::Translation.new(api_key, YAML.load(response))
        translation.new_record = false
        return translation
        
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        retry
      end      
    end
    
    protected
    
    # Save the changes made to a String to WebTranslateIt.com
    # Needs a HTTPS Connection
    #
    
    def update(http_connection)
      request = Net::HTTP::Put.new("/api/projects/#{self.api_key}/strings/#{self.id}.yaml")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)
      request.add_field("Content-Type", "application/json")
          
      request.body = self.to_json # TODO: Handle Array of Translation

      begin
        Util.handle_response(http_connection.request(request), true)
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        retry
      end
    end
    
    # Create a new String to WebTranslateIt.com
    # Needs a HTTPS Connection
    #
    
    def create(http_connection)
      request = Net::HTTP::Post.new("/api/projects/#{self.api_key}/strings")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)
      request.add_field("Content-Type", "application/json")
        
      request.body = self.to_json # TODO: Handle Array of Translation

      begin
        response = YAML.load(Util.handle_response(http_connection.request(request), true))
        self.id = response["id"]
        return true
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        retry
      end
    end
    
  end
end
