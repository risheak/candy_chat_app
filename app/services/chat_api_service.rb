class ChatApiService
  include HTTParty

  SERVERS = Server.pluck(:url).freeze

  def self.next_server_url
    server = Rails.cache.fetch('load_balancer_cache') { 0 }
    servers = SERVERS.blank? ? Server.pluck(:url) : SERVERS
    servers[server]
  end

  def self.build_message_history(payload, profile)
      previous_message = ""
      profile.messages.order(:created_at).each_with_index do |message, index|
        if message.sent_by == "profile"
        # If it's the first message from the assistant, we add the LLM format required
          if index == 0
            payload["history"]["internal"] << ["<|BEGIN-VISIBLE-CHAT|>", message.body] if index == 0
            payload["history"]["visible"] << ["", message.body]
            else
              payload["history"]["internal"] << [previous_message, message.body]
              payload["history"]["visible"] << [previous_message, message.body]
            end

           previous_message = ""
        else
          previous_message = message.body
        end
      end
      payload
    end

  def self.send_message(params, profile)
    params = JSON.parse params
    params.merge!(DEFAULT_CHARACTER)
    body = build_message_history(params, profile)
    response = HTTParty.post(next_server_url, body: body.to_json, headers: { 'Content-Type' => 'application/json' })
    if response.success?
      # Save the response as a message with the role 'Profile'
      res = JSON.parse response.body
      last_res = res['results'][0]['history']['internal'].last.last
      # last_res = JSON.parse last_res
      # last_res_message = last_res['results'][0]['history']['internal'].last.last
      new_message = profile.messages.create(body: last_res, sent_by: 'profile', archived: false)
      # broadcast_turbo_stream(new_message)
    else
      # Handle the failure scenario
      # For example, log the error or retry the job
    end
    update_cache
    response
  end

  def self.broadcast_turbo_stream(message)
    broadcast_args = {
      action: :replace,
      target: "message_#{message.id}",
      partial: "messages/message",
      locals: { message: message }
    }

    Turbo::StreamsChannel.broadcast_to("messages_list", broadcast_args)
  end

  def self.update_cache
    cache = Rails.cache.read('load_balancer_cache')
    new_val = cache == 0 ? 1 : 0
    Rails.cache.write('load_balancer_cache', new_val)
  end
end
