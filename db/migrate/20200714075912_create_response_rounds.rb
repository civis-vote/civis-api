class CreateResponseRounds < ActiveRecord::Migration[6.0]
  def self.up
    create_table :response_rounds do |t|
      t.references :consultation, null: true, foreign_key: true

      t.timestamps
    end
    create_table :respondents do |t|
      t.references :user, null: true, foreign_key: true
      t.references :response_round, null: true, foreign_key: true
      t.references :organisation, null: true, foreign_key: true

      t.timestamps
    end
    add_reference :consultation_responses, :respondent, null: true, foreign_key: true
    add_reference :questions, :response_round, null: true, foreign_key: true
    consultation_ids = Question.all.map{|q| q.consultation_id}.compact.uniq
    consultation_ids.each do |c|
		  r = ResponseRound.create(consultation_id: c)
		  questions = Question.where(consultation_id: c)
		  questions.each do |q|
				q.update(response_round_id: r.id)	  	
		  end
    end
    Consultation.all.each do |consultation|
      consultation.create_response_round if consultation.response_rounds.blank?
    end
    remove_reference :questions, :consultation, null: true, foreign_key: true
  end
  def self.down
  	remove_reference :response_rounds, :consultation, null: true, foreign_key: true
  	remove_reference :respondents, :response_round, null: true, foreign_key: true
  	remove_reference :respondents, :user, null: true, foreign_key: true
  	remove_reference :respondents, :organisation, null: true, foreign_key: true
  	remove_reference :consultation_responses, :respondent, null: true, foreign_key: true
    remove_reference :questions, :response_round, null: true, foreign_key: true
  	add_reference :questions, :consultation, null: true, foreign_key: true
  	drop_table :response_rounds, force: true
  	drop_table :respondents, force: true
  end
end
