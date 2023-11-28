class ChatApiWorker
  include Sidekiq::Worker

  def perform(profile_id, params)
    profile = Profile.find(profile_id)
    response = ChatApiService.send_message(params, profile)
    # broadcast_turbo_stream(message)
  end

  private

  def broadcast_turbo_stream(message)
    broadcast_args = {
      action: :replace,
      target: "message_#{message.id}",
      partial: "messages/message",
      locals: { message: message }
    }

    Turbo::StreamsChannel.broadcast_to("messages_list", broadcast_args)
  end
end
