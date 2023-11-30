class MessageFilterService
  DIRTY_KEYWORDS = ['bad', 'dirty', 'baby', 'children', 'kill'].freeze

  class << self
    def call(message)
      filtered_message = filter_dirty_keywords(message)
      return false if open_ai_flagged?(filtered_message)

      filtered_message
    end

    private

    def filter_dirty_keywords(message)
      dirty_keywords = DIRTY_KEYWORDS.select { |keyword| message.include?(keyword) }
      dirty_keywords.each { |keyword| message.gsub!(keyword, "") }
      message
    end

    def open_ai_flagged?(message)
      client = OpenAI::Client.new
      openai_result = client.moderations(parameters: { input: message })
      openai_result['results'][0]['flagged']
    end
  end
end
