class ChatsController < ApplicationController
  before_action :set_profile, only: [:index, :send_message]

  def index
    @messages = @profile.messages
  end

  def send_message
    @profile.messages.create(body: params[:body], sent_by: 'user', archived: false)
    ChatApiWorker.perform_async(@profile.id, params[:body])
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
