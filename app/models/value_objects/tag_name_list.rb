module ValueObjects
  class TagNameList
    attr_reader :names

    def initialize(raw)
      raise ArgumentError, "String または nil を渡してください" unless raw.nil? || raw.is_a?(String)
      @names = raw.to_s.split(",").map { |n| n.strip.downcase }.reject(&:blank?).uniq.freeze
      freeze
    end

    def empty?
      @names.empty?
    end

    def ==(other)
      other.is_a?(TagNameList) && other.names == names
    end

    alias eql? ==

    def hash
      names.hash
    end

    def to_s
      @names.join(", ")
    end

    def inspect
      "#<ValueObjects::TagNameList names=#{@names.inspect}>"
    end
  end
end
