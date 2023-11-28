class Message < ApplicationRecord
  include ActionView::RecordIdentifier
  belongs_to :profile

  enum sent_by: { user: 0, profile: 1 }
  # after_create_commit -> { broadcast_append_to :message }
  # broadcasts_to ->(message){:messages_list}

  after_create_commit -> { broadcast_created }
  after_update_commit -> { broadcast_updated }

  def broadcast_created
    broadcast_append_later_to(
      "#{dom_id(profile)}_messages",
      partial: "messages/message",
      locals: { message: self, scroll_to: true },
      target: "#{dom_id(profile)}_messages"
    )
  end

  def broadcast_updated
    broadcast_append_to(
      "#{dom_id(profile)}_messages",
      partial: "messages/message",
      locals: { message: self, scroll_to: true },
      target: "#{dom_id(profile)}_messages"
    )
  end
end
