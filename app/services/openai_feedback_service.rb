require "openai"

# Optionally configure OpenAI globally for Kamal compatibility
OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPENAI_API_KEY", ENV["OPENAI_ACCESS_TOKEN"])
  # config.organization_id = ENV["OPENAI_ORGANIZATION_ID"] if ENV["OPENAI_ORGANIZATION_ID"]
  # config.log_errors = true # Uncomment for verbose logging in development
end

class OpenaiFeedbackService
  def initialize(conjecture)
    @conjecture = conjecture
    @client = OpenAI::Client.new
  end

  def feedback
    return @conjecture.ai_feedback if @conjecture.ai_feedback.present?

    prompt = <<~PROMPT
      You are an expert scientific reviewer and AI assistant. Analyze the following conjecture, referencing the latest research and providing a Bayesian estimate (0-100%) of its likelihood of being falsified within 5 years. Structure your answer as follows:
      1. Brief critique and context
      2. Recent research (cite and link the URL if possible, not markdown, just the link)
      3. Bayesian likelihood of falsification (with reasoning)
      Be concise. Do not include any additional text outside of the three points above.
      Conjecture: "#{@conjecture.title}"
      Description: #{@conjecture.description}
      Falsification Criteria: #{@conjecture.falsification_criteria}
    PROMPT

    response = @client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [
          { role: "system", content: "You are a scientific reviewer and AI assistant." },
          { role: "user", content: prompt }
        ],
        temperature: 0.7,
        max_tokens: 4096
      }
    )
    content = response.dig("choices", 0, "message", "content") || "No feedback available."
    @conjecture.update_columns(ai_feedback: content, ai_feedback_generated_at: Time.current)
    content
  rescue => e
    "AI feedback unavailable: #{e.message}"
  end
end
