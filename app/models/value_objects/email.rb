module ValueObjects
  class Email
    attr_reader :value

    def initialize(value)
      raise ArgumentError, "Email は String である必要があります" unless value.is_a?(String)
      @value = value.downcase.strip
      freeze
    end

    def domain
      @value.split("@").last
    end

    def local_part
      @value.split("@").first
    end

    def ==(other)
      other.is_a?(Email) && other.value == value
    end

    alias eql? ==

    def hash
      value.hash
    end

    def to_s
      @value
    end

    def inspect
      "#<ValueObjects::Email value=#{@value.inspect}>"
    end
  end
end
