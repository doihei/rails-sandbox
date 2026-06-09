module Mutations
  class CreateSession < BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true

    field :token, String, null: true
    field :errors, [ String ], null: false

    def resolve(email:, password:)
      user = User.find_by(email: email.downcase.strip)

      unless user&.authenticate(password)
        return { token: nil, errors: [ I18n.t("errors.invalid_credentials") ] }
      end

      token = JwtService.encode(user_id: user.id)
      { token: token, errors: [] }
    end
  end
end
