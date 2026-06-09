module AttributeTypes
  class EmailType < ActiveRecord::Type::String
    def cast(value)
      return nil if value.blank?
      value.is_a?(ValueObjects::Email) ? value : ValueObjects::Email.new(value.to_s)
    end

    def serialize(value)
      return nil if value.nil?
      value.is_a?(ValueObjects::Email) ? value.value : super
    end
  end
end
