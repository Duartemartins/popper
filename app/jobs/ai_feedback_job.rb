class AiFeedbackJob < ApplicationJob
  queue_as :default

  def perform(conjecture_id)
    conjecture = Conjecture.find_by(id: conjecture_id)
    return unless conjecture
    OpenaiFeedbackService.new(conjecture).feedback
  end
end
