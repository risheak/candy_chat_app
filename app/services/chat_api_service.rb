class ChatApiService
  include HTTParty

  def self.build_message_history(params, profile)
      previous_message = ""
      profile.messages.order(:created_at).each_with_index do |message, index|
        if message.sent_by == "profile"
        # If it's the first message from the assistant, we add the LLM format required
          if index == 0
            params["history"]["internal"] << ["<|BEGIN-VISIBLE-CHAT|>", message.body] if index == 0
            params["history"]["visible"] << ["", message.body]
            else
              params["history"]["internal"] << [previous_message, message.body]
              params["history"]["visible"] << [previous_message, message.body]
            end

           previous_message = ""
        else
          previous_message = message.body
        end
      end
      params
    end

  def self.send_message(message, profile_id)
    profile = Profile.find_by(id: profile_id)
    byebug
    moderation_result = MessageFilterService.call message
    if moderation_result
      params = build_message_params(moderation_result, profile)
      params.merge!(DEFAULT_CHARACTER)
      body = build_message_history(params, profile)
      next_server_url = LoadBalanceService.next_server_url
      response = HTTParty.post(next_server_url, body: body.to_json, headers: { 'Content-Type' => 'application/json' })
      if response.success?
        # Save the response as a message with the role 'Profile'
        res = JSON.parse response.body
        last_res = res['results'][0]['history']['internal'].last.last
        profile.messages.create(body: last_res, sent_by: 'profile', archived: false)
      else
        # Handle the failure scenario
      end
      response
    else
      profile.messages.create(body: 'Sorry, I can not process this', sent_by: 'profile', archived: false)
    end
  end

  def self.build_message_params message, profile
    params = {
      your_name: 'Risheak',#@current_user.name
      user_input: message,
      name1: 'Risheak',
      name2: profile.name,
      greeting: 'Hello!',
      context: "Friendly AI, witty, #{profile.gender}, #{profile.category}",
      character: 'Example'
    }
  end
end
