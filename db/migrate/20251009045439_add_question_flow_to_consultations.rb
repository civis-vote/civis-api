class AddQuestionFlowToConsultations < ActiveRecord::Migration[7.1]
  def change
    add_column :consultations, :question_flow, :integer, default: 0
    add_column :questions, :accept_voice_message, :boolean, default: false
    add_column :consultation_responses, :voice_message_answers, :jsonb, default: {}
  end
end
