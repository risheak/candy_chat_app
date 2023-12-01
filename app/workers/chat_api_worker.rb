class ChatApiWorker
  include Sidekiq::Worker

  def perform(profile_id, message)
    response = ChatApiService.send_message(message, profile_id)
  end
end
