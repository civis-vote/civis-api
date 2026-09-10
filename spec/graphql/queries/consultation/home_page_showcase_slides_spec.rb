require 'rails_helper'

RSpec.describe Queries::Consultation::HomePageShowcaseSlides, type: :graphql do
  let(:query) do
    <<~GQL
      query GetHomePageShowcaseSlides($status: ConsultationStatuses, $limit: Int) {
        homePageShowcaseSlides(status: $status, limit: $limit) {
          id
          title
          description
          image { url }
          cta { label url }
          status
          responseDeadline
          publishedAt
        }
      }
    GQL
  end

  let(:variables) { {} }
  let(:context) { {} }

  let(:result) do
    CivisApiSchema.execute(query, variables: variables, context: context)
  end

  let(:slides) { result.dig('data', 'homePageShowcaseSlides') }

  # Helper: create a consultation with a specific status, bypassing scoring callbacks
  def create_consultation(status:, visibility: :public_consultation, response_deadline: 10.days.from_now,
                          url: Faker::Internet.url, cta_label: nil)
    consultation = Fabricate(:consultation, visibility: visibility, response_deadline: response_deadline, url: url)
    consultation.update_columns(status: Consultation.statuses[status],
                                published_at: status == :published ? Time.now : nil,
                                cta_label: cta_label)
    consultation.reload
  end

  describe 'homePageShowcaseSlides query' do
    it 'returns only published consultations by default' do
      published = create_consultation(status: :published)
      submitted = create_consultation(status: :submitted)

      expect(slides.map { |s| s['id'] }).to include(published.id)
      expect(slides.map { |s| s['id'] }).not_to include(submitted.id)
    end

    it 'does not return expired consultations' do
      published = create_consultation(status: :published)
      expired = create_consultation(status: :expired)

      expect(slides.map { |s| s['id'] }).to include(published.id)
      expect(slides.map { |s| s['id'] }).not_to include(expired.id)
    end

    it 'does not return rejected consultations' do
      published = create_consultation(status: :published)
      rejected = create_consultation(status: :rejected)

      expect(slides.map { |s| s['id'] }).to include(published.id)
      expect(slides.map { |s| s['id'] }).not_to include(rejected.id)
    end

    it 'returns multiple published slides ordered by response_deadline ascending' do
      later = create_consultation(status: :published, response_deadline: 30.days.from_now)
      sooner = create_consultation(status: :published, response_deadline: 5.days.from_now)
      middle = create_consultation(status: :published, response_deadline: 15.days.from_now)

      ordered_ids = slides.map { |s| s['id'] }
      expect(ordered_ids).to eq([sooner.id, middle.id, later.id])
    end

    it 'returns an empty list when there are no published consultations' do
      create_consultation(status: :submitted)
      create_consultation(status: :expired)

      expect(slides).to eq([])
    end

    it 'returns the fields required by the Home Page' do
      consultation = create_consultation(status: :published, url: 'https://example.com/consultation')

      slide = slides.first
      expect(slide['id']).to eq(consultation.id)
      expect(slide['title']).to eq(consultation.title)
      expect(slide['description']).to be_a(String)
      expect(slide['status']).to eq('published')
      expect(slide['responseDeadline']).to be_present
      expect(slide['cta']).to eq({ 'label' => nil, 'url' => 'https://example.com/consultation' })
    end

    it 'uses the custom cta_label when set' do
      consultation = create_consultation(status: :published, url: 'https://example.com/consultation',
                                         cta_label: 'Have Your Say')

      slide = slides.find { |s| s['id'] == consultation.id }
      expect(slide['cta']).to eq({ 'label' => 'Have Your Say', 'url' => 'https://example.com/consultation' })
    end

    it 'returns null label when cta_label is not set' do
      consultation = create_consultation(status: :published, url: 'https://example.com/consultation', cta_label: nil)

      slide = slides.find { |s| s['id'] == consultation.id }
      expect(slide['cta']['label']).to be_nil
    end

    it 'returns null cta when the consultation has no url' do
      consultation = create_consultation(status: :published, url: nil)

      slide = slides.find { |s| s['id'] == consultation.id }
      expect(slide['cta']).to be_nil
    end

    it 'does not return private consultations' do
      public_consultation = create_consultation(status: :published, visibility: :public_consultation)
      private_consultation = create_consultation(status: :published, visibility: :private_consultation)

      expect(slides.map { |s| s['id'] }).to include(public_consultation.id)
      expect(slides.map { |s| s['id'] }).not_to include(private_consultation.id)
    end

    context 'when a status argument is provided' do
      let(:variables) { { status: 'submitted' } }

      it 'returns consultations matching the requested status' do
        submitted = create_consultation(status: :submitted)
        published = create_consultation(status: :published)

        ids = slides.map { |s| s['id'] }
        expect(ids).to include(submitted.id)
        expect(ids).not_to include(published.id)
      end
    end

    context 'when a limit argument is provided' do
      let(:variables) { { limit: 2 } }

      it 'limits the number of returned slides' do
        3.times do |i|
          create_consultation(status: :published, response_deadline: (i + 1).days.from_now)
        end

        expect(slides.size).to eq(2)
      end
    end
  end
end
