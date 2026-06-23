module ValueObjects
  class CommentBody
    MAX_LENGTH = 1000

    attr_reader :value

    def initialize(value)
      @value = value.to_s.strip
      freeze
    end

    def valid?
      errors.empty?
    end

    def errors
      errs = []
      errs << I18n.t("comments.errors.body_blank") if value.blank?
      errs << I18n.t("comments.errors.body_too_long", max: MAX_LENGTH) if value.length > MAX_LENGTH
      errs
    end

    def ==(other)
      other.is_a?(CommentBody) && other.value == value
    end

    alias eql? ==

    def hash
      value.hash
    end

    def to_s
      @value
    end

    def inspect
      "#<ValueObjects::CommentBody value=#{@value.inspect}>"
    end
  end
end
