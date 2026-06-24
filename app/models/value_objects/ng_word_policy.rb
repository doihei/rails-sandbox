module ValueObjects
  class NgWordPolicy
    attr_reader :text, :detected_words

    def self.config
      @config ||= YAML.load_file(
        Rails.root.join("config/ng_words.yml"),
        aliases: true
      ).fetch(Rails.env, {})
    end

    def self.words
      config.fetch("words", [])
    end

    def initialize(text)
      @text = text.to_s
      @detected_words = self.class.words.select { |word| @text.include?(word) }
      freeze
    end

    def valid?
      @detected_words.empty?
    end

    def errors
      return [] if @detected_words.empty?
      [ I18n.t("ng_word.errors.detected", words: @detected_words.join(", ")) ]
    end

    def ==(other)
      other.is_a?(NgWordPolicy) && other.text == text
    end

    alias eql? ==

    def hash
      text.hash
    end

    def inspect
      "#<ValueObjects::NgWordPolicy text=#{text.inspect} valid=#{valid?}>"
    end
  end
end
