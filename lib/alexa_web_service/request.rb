module AlexaWebService
  class Request
    attr_reader :request_hash, :api_access_token, :api_endpoint, :device_id, 
                :request_id, :request_type, :timestamp, :session_new, :user_id,
                :access_token, :application_id, :intent_name, :slots
    
    attr_accessor :attributes

    def initialize(request_hash)
      @request_hash     = request_hash
      @api_access_token = request_hash["context"]["System"]["apiAccessToken"]
      @api_endpoint     = request_hash["context"]["System"]["apiEndpoint"]
      @device_id        = request_hash["context"]["System"]["device"]["deviceId"]
      @request_id       = request_hash["request"]["requestId"]
      @request_type     = request_hash["request"]["type"]
      @timestamp        = request_hash["request"]["timestamp"]
      @session_new      = request_hash["session"]["new"]
      @user_id          = request_hash["session"]["user"]["userId"]
      @access_token     = request_hash["session"]["user"]["accessToken"]
      @application_id   = request_hash["session"]["application"]["applicationId"]
      @intent_name      = get_intent_name
      @slots            = get_slots
      @attributes       = get_attributes
    end

    def filled_slots
      @slots.select { |slot| slot != nil} rescue []
    end

    def intent_request?
      request_type == "IntentRequest"
    end

    def launch_request?
      request_type == "LaunchRequest"
    end

    def slot_hash
      if request_hash["request"]["intent"]
        request_hash["request"]["intent"]["slots"]
      end
    end

    def session_ended_request?
      request_type == "SessionEndedRequest"
    end

    def session_new?
      session_new
    end 

    
    private
    def get_intent_name
      if request_hash["request"]["intent"]
        request_hash["request"]["intent"]["name"]
      end
    end

    def get_slots
      if request_hash["request"]["intent"]
        build_struct(request_hash["request"]["intent"]["slots"])
      end
    end

    def get_attributes
      request_hash["session"]["attributes"] ? request_hash["session"]["attributes"] : {} 
    end

    def build_struct(hash)
      if hash.nil? || hash.empty?
        nil
      else
        slot_names = hash.keys.map {|k| k.to_sym.downcase }
        slot_values = hash.values.map { |v| v["value"] }
        Struct.new(*slot_names).new(*slot_values)
      end
    end
  end
end