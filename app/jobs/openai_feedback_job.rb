class OpenaiFeedbackJob < ApplicationJob
  queue_as :default

  def perform(conjecture_id)
    conjecture = Conjecture.find(conjecture_id)
    return if conjecture.ai_feedback.present?

    feedback = OpenaiFeedbackService.new(conjecture).feedback
    conjecture.update(ai_feedback: feedback, ai_feedback_generated_at: Time.current)
  rescue => e
    Rails.logger.error("[OpenaiFeedbackJob] Failed for conjecture #{conjecture_id}: #{e.message}")
  end
end
