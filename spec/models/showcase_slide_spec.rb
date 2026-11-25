require 'rails_helper'

RSpec.describe ShowcaseSlide, type: :model do
  let(:admin) { create(:user, role: :admin) }

  before { Current.user = admin }
  after { Current.reset }

  def create_slide(attrs = {})
    ShowcaseSlide.create!({
      title: "Slide #{SecureRandom.hex(4)}", description: 'A showcase slide',
      cta_label: 'Learn more', cta_url: 'https://example.com', position: 1
    }.merge(attrs))
  end

  describe 'validations' do
    it 'needs a title, description, cta and position' do
      expect(ShowcaseSlide.new).not_to be_valid
    end
  end

  describe '#publish and #archive' do
    it 'publishes with a timestamp' do
      slide = create_slide

      slide.publish

      expect(slide.reload).to be_published
      expect(slide.published_at).to be_present
    end

    it 'archives with a timestamp' do
      slide = create_slide

      slide.archive

      expect(slide.reload).to be_archived
      expect(slide.archived_at).to be_present
    end
  end

  describe '.ordered_by_position' do
    it 'orders slides by position' do
      second = create_slide(position: 2)
      first = create_slide(position: 1)

      expect(ShowcaseSlide.ordered_by_position).to eq([first, second])
    end
  end
end
