module Mutations
  class SuspendUser < BaseMutation
    argument :id, ID, required: true
    field :user, Types::UserType, null: false
    def resolve(id:)
      require_admin!
      user = User.find_by(id: id)
      raise GraphQL::ExecutionError, "User not found" unless user
      raise GraphQL::ExecutionError, "An administrator cannot suspend themselves" if user == current_user
      user.update!(status: :suspended)
      ActivityLogs::Record.call(action: "user.suspended", actor: current_user, subject: user)
      { user: user }
    end
  end
end
