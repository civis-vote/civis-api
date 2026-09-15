require 'rails_helper'

RSpec.describe Queries::Consultation::ShowcaseSlides, type: :graphql do
  let(:query) do
    <<~GQL
      query GetShowcaseSlides($limit: Int) {
        showcaseSlides(limit: $limit) {
          id
          title
          description
          image { url }
          ctaLabel
          ctaUrl
          videoUrl
          status
          position
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

  let(:slides) { result.dig('data', 'showcaseSlides') }

  def create_slide(status: :published, position: rand(1..100), cta_url: Faker::Internet.url, cta_label: 'Learn More', video_url: nil)
    Fabricate(:showcase_slide, status: status, position: position, cta_url: cta_url, cta_label: cta_label, video_url: video_url)
  end

  describe 'showcaseSlides query' do
    it 'returns only published slides by default' do
      published = create_slide(status: :published)
      draft = create_slide(status: :draft)

      expect(slides.map { |s| s['id'] }).to include(published.id)
      expect(slides.map { |s| s['id'] }).not_to include(draft.id)
    end

    it 'does not return archived slides' do
      published = create_slide(status: :published)
      archived = create_slide(status: :archived)

      expect(slides.map { |s| s['id'] }).to include(published.id)
      expect(slides.map { |s| s['id'] }).not_to include(archived.id)
    end

    it 'returns multiple published slides ordered by position ascending' do
      third = create_slide(status: :published, position: 30)
      first = create_slide(status: :published, position: 5)
      second = create_slide(status: :published, position: 15)

      ordered_ids = slides.map { |s| s['id'] }
      expect(ordered_ids).to eq([first.id, second.id, third.id])
    end

    it 'returns an empty list when there are no published slides' do
      create_slide(status: :draft)
      create_slide(status: :archived)

      expect(slides).to eq([])
    end

    it 'returns the fields required by the Home Page' do
      slide_record = create_slide(status: :published, cta_url: 'https://example.com/consultation')

      slide = slides.first
      expect(slide['id']).to eq(slide_record.id)
      expect(slide['title']).to eq(slide_record.title)
      expect(slide['description']).to be_a(String)
      expect(slide['status']).to eq('published')
      expect(slide['ctaLabel']).to eq('Learn More')
      expect(slide['ctaUrl']).to eq('https://example.com/consultation')
    end

    it 'uses the custom cta_label when set' do
      slide_record = create_slide(status: :published, cta_url: 'https://example.com/consultation',
                                  cta_label: 'Have Your Say')

      slide = slides.find { |s| s['id'] == slide_record.id }
      expect(slide['ctaLabel']).to eq('Have Your Say')
      expect(slide['ctaUrl']).to eq('https://example.com/consultation')
    end

    it 'returns the video_url when set' do
      slide_record = create_slide(status: :published, video_url: 'https://example.com/video.mp4')

      slide = slides.find { |s| s['id'] == slide_record.id }
      expect(slide['videoUrl']).to eq('https://example.com/video.mp4')
    end

    it 'returns null video_url when not set' do
      slide_record = create_slide(status: :published, video_url: nil)

      slide = slides.find { |s| s['id'] == slide_record.id }
      expect(slide['videoUrl']).to be_nil
    end

    context 'when a limit argument is provided' do
      let(:variables) { { limit: 2 } }

      it 'limits the number of returned slides' do
        3.times do |_i|
          create_slide(status: :published)
        end

        expect(slides.size).to eq(2)
      end
    end
  end
end
