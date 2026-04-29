module ValueObjects
  class ArticleStatus
    VALID = %w[draft published archived].freeze

    attr_reader :value

    def initialize(value)
      raise ArgumentError, "不正なステータスです: #{value}" unless VALID.include?(value.to_s)
      @value = value.to_s
      freeze
    end

    # 状態確認メソッド — ドメイン語彙として表現
    def draft?      = @value == "draft"
    def published?  = @value == "published"
    def archived?   = @value == "archived"

    # 遷移可否のビジネスルール
    def publishable?  = draft?
    def archivable?   = published?

    def ==(other)
      other.is_a?(ArticleStatus) && other.value == value
    end

    alias eql? ==

    def hash
      value.hash
    end

    def to_s = @value
    def inspect = "#<ValueObjects::ArticleStatus value=#{@value.inspect}>"
  end
end
