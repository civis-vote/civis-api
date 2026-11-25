require 'rails_helper'

RSpec.describe Consultation, type: :model do
  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end

  def create_consultation(attrs = {})
    Consultation.create!({
      title: "Consultation #{SecureRandom.hex(4)}",
      department: department,
      response_deadline: 1.day.from_now,
      question_flow: :question_list,
      consultation_feedback_email: 'feedback@test.com'
    }.merge(attrs))
  end

  # Responses cannot be created after the deadline passes, so move the deadline
  # into the past with update_column (bypasses the expiry job callbacks).
  def expire_after(consultation)
    consultation.update_column(:response_deadline, 1.day.ago)
    consultation.expire
  end

  def create_acceptable_response(consultation)
    ConsultationResponse.create!(consultation: consultation, response_round: consultation.response_rounds.first,
                                 visibility: :shared, response_status: :acceptable, response_text: 'My feedback')
  end

  describe 'timeline fields' do
    let(:consultation) { create_consultation }

    it 'persists feedback_submitted_at, acknowledged_at and policy_released_at' do
      timestamp = 2.days.ago
      consultation.update!(feedback_submitted_at: timestamp, acknowledged_at: timestamp,
                           policy_released_at: timestamp)

      expect(consultation.reload.feedback_submitted_at).to be_within(1.minute).of(timestamp)
      expect(consultation.reload.acknowledged_at).to be_within(1.minute).of(timestamp)
      expect(consultation.reload.policy_released_at).to be_within(1.minute).of(timestamp)
    end
  end

  describe '#expire' do
    context 'when there are acceptable responses and a feedback report email is sent' do
      it 'sets feedback_submitted_at to the current time' do
        consultation = create_consultation
        create_acceptable_response(consultation)

        expire_after(consultation)

        expect(consultation.reload.feedback_submitted_at).to be_within(1.minute).of(Time.current)
      end
    end

    context 'when there are no acceptable responses' do
      it 'does not set feedback_submitted_at' do
        consultation = create_consultation

        expire_after(consultation)

        expect(consultation.reload.feedback_submitted_at).to be_nil
      end
    end

    context 'when feedback_submitted_at has already been set' do
      it 'does not overwrite the manually edited value' do
        consultation = create_consultation
        create_acceptable_response(consultation)
        consultation.update!(feedback_submitted_at: 1.week.ago)

        expire_after(consultation)

        expect(consultation.reload.feedback_submitted_at).to be_within(1.minute).of(1.week.ago)
      end
    end
  end

  describe '#blog_posts' do
    it 'links multiple blog posts to a consultation' do
      consultation = create_consultation
      post1 = Fabricate(:blog_post)
      post2 = Fabricate(:blog_post)

      consultation.update!(blog_post_ids: [post1.id, post2.id])

      expect(consultation.blog_posts).to match_array([post1, post2])
      expect(post1.reload.consultation).to eq(consultation)
    end

    it 'removes a linked blog post when it is unassigned' do
      consultation = create_consultation
      post = Fabricate(:blog_post, consultation: consultation)

      consultation.update!(blog_post_ids: [])

      expect(consultation.blog_posts.reload).to be_empty
      expect(post.reload.consultation_id).to be_nil
    end

    it 'rejects reassigning a blog post that is already linked to another consultation' do
      consultation = create_consultation
      other = create_consultation
      post = Fabricate(:blog_post, consultation: consultation)

      expect { other.update!(blog_post_ids: [post.id]) }.to raise_error(ActiveRecord::RecordNotSaved)
      expect(post.reload.consultation).to eq(consultation)
    end

    it 'allows reassigning a blog post after it is unlinked' do
      consultation = create_consultation
      other = create_consultation
      post = Fabricate(:blog_post, consultation: consultation)

      consultation.update!(blog_post_ids: [])
      other.update!(blog_post_ids: [post.id])
      expect(post.reload.consultation).to eq(other)
    end

    it 'nullifies blog posts when the consultation is destroyed' do
      consultation = create_consultation
      post = Fabricate(:blog_post, consultation: consultation)

      consultation.destroy

      expect(post.reload.consultation_id).to be_nil
    end
  end

  describe '#publish' do
    # Publish scores the creator, so a created_by must exist (its city may be nil).
    let(:creator) do
      User.create!(first_name: 'Creator', last_name: 'User', email: Faker::Internet.unique.email,
                   password: 'Password@123', role: :citizen, confirmed_at: Time.current)
    end

    before { Current.user = creator }
    after { Current.reset }

    it 'marks the consultation published with a timestamp' do
      consultation = create_consultation

      consultation.publish

      expect(consultation.reload).to be_published
      expect(consultation.published_at).to be_present
    end

    it 'keeps the original published_at when republishing' do
      consultation = create_consultation
      consultation.publish
      original = consultation.reload.published_at

      consultation.publish

      expect(consultation.reload.published_at).to be_within(1.minute).of(original)
    end

    it 'invites the respondents of a private consultation' do
      consultation = create_consultation(visibility: :private_consultation,
                                         organisation: Organisation.create!(name: "Org #{SecureRandom.hex(4)}"))
      respondent_user = User.create!(first_name: 'Invited', last_name: 'User',
                                     email: Faker::Internet.unique.email, password: 'Password@123',
                                     role: :citizen, confirmed_at: Time.current)
      Respondent.create!(user: respondent_user, response_round: consultation.response_rounds.first)

      expect { consultation.publish }
        .to have_enqueued_job(InviteRespondentJob).with(consultation, respondent_user, String)
    end
  end

  describe '#extend_deadline' do
    let(:creator) do
      User.create!(first_name: 'Creator', last_name: 'User', email: Faker::Internet.unique.email,
                   password: 'Password@123', role: :citizen, confirmed_at: Time.current)
    end

    before { Current.user = creator }
    after { Current.reset }

    it 'moves the deadline and republishes an expired consultation' do
      consultation = create_consultation
      consultation.publish
      consultation.update_column(:response_deadline, 1.day.ago)
      consultation.expire
      new_deadline = 5.days.from_now

      consultation.extend_deadline(new_deadline)

      expect(consultation.reload.response_deadline).to be_within(1.minute).of(new_deadline)
      expect(consultation).to be_published
    end
  end

  describe '#compute_response_summary' do
    let(:consultation) { create_consultation }

    let(:support_question) do
      consultation.response_rounds.last.questions.create!(
        question_text: 'Do you support this policy?', question_type: :multiple_choice,
        is_optional: false, sub_questions_attributes: [{ question_text: 'Yes' }, { question_text: 'No' }]
      )
    end

    def respond_with(user, answer:)
      ConsultationResponse.create!(user: user, consultation: consultation,
                                   response_round: consultation.response_rounds.last,
                                   visibility: :shared, response_status: :acceptable,
                                   answers: [{ 'question_id' => support_question.id.to_s, 'answer' => answer }])
    end

    it 'aggregates option counts and percentages across acceptable responses' do
      yes_option = support_question.sub_questions.first
      respond_with(User.create!(first_name: 'One', last_name: 'User', email: Faker::Internet.unique.email,
                                password: 'Password@123', role: :citizen, confirmed_at: Time.current),
                   answer: [yes_option.id])
      respond_with(User.create!(first_name: 'Two', last_name: 'User', email: Faker::Internet.unique.email,
                                password: 'Password@123', role: :citizen, confirmed_at: Time.current),
                   answer: [yes_option.id])

      consultation.compute_response_summary

      summary = consultation.reload.response_summary
      question_summary = summary.question_summaries.find_by(question_id: support_question.id)
      yes_breakdown = question_summary.option_breakdowns.find_by(option_id: yes_option.id)

      expect(summary.total_responses).to eq(2)
      expect(question_summary.total_responses).to eq(2)
      expect(yes_breakdown.selection_count).to eq(2)
      expect(yes_breakdown.percentage).to eq(100.0)
    end

    it 'replaces a stale summary when recomputed' do
      consultation.compute_response_summary
      stale_id = consultation.reload.response_summary.id

      consultation.compute_response_summary

      expect(consultation.reload.response_summary.id).not_to eq(stale_id)
    end
  end
end
