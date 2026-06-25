module ValueObjects
  class TagNameList
    attr_reader :names

    def initialize(raw)
      raise ArgumentError, "String、Array、または nil を渡してください" unless raw.nil? || raw.is_a?(String) || raw.is_a?(Array)
      @names = parse(raw)
      freeze
    end

    private

    def parse(raw)
      names = case raw
      when Array  then raw.map(&:to_s)
      when String then raw.split(",")
      else []
      end
      names.map { |n| n.strip.downcase }.reject(&:blank?).uniq.freeze
    end

    public

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
