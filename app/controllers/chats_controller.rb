class ChatsController < ApplicationController
  before_action :set_profile, only: [:index, :create, :send_message]

  def index
    @messages = @profile.messages
  end

  def create
    # ... (your existing code)

    redirect_to send_message_chat_path(profile_id: @profile.id)
  end

  def send_message
    message_params = {
      your_name: 'Risheak',#@current_user.name
      user_input: params[:body],
      name1: 'Risheak',
      name2: @profile.name,
      greeting: 'Hello!',
      context: "Friendly AI, witty, #{@profile.gender}, #{@profile.category}",
      character: 'Example'
    }

    # Enqueue the Sidekiq job
    ChatApiWorker.perform_async(@profile.id, message_params.to_json)

    # Save the user's message in the chat history with 'User' role
    @profile.messages.create(body: params[:body], sent_by: 'user', archived: false)
    respond_to do |format|
      format.turbo_stream
      format.html { render 'index' }
    end
  end

  private

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end
end
