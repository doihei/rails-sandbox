module Mutations
  class DeleteSession < Mutations::BaseMutation
    field :success, Boolean, null: false

    def resolve
      # JWT はステートレスなためサーバー側での無効化は行わない
      # フロント側でトークンを破棄する
      { success: true }
    end
  end
end
