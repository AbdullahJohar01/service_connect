module Mutations
  class ApproveProvider < BaseMutation
    argument :id, ID, required: true
    field :provider, Types::ProviderProfileType, null: false
    def resolve(id:)
      require_admin!
      provider = ProviderProfile.find_by(id: id)
      raise GraphQL::ExecutionError, "Provider not found" unless provider
      provider.update!(approval_status: :approved)
      ActivityLogs::Record.call(action: "provider.approved", actor: current_user, subject: provider)
      { provider: provider }
    end
  end
end
