require 'rails_helper'

RSpec.describe DepartmentContact, type: :model do
  let(:department) { create(:department) }

  it 'belongs to a department with a contact type' do
    contact = DepartmentContact.create!(department:, contact_type: :primary, email: 'primary@test.com')

    expect(contact.department).to eq(department)
    expect(contact.contact_type).to eq('primary')
  end

  it 'needs an email' do
    expect(DepartmentContact.new(department:, contact_type: :primary)).not_to be_valid
  end

  it 'rejects a malformed email' do
    contact = DepartmentContact.new(department:, contact_type: :primary, email: 'not-an-email')

    expect(contact).not_to be_valid
    expect(contact.errors[:email]).to include('is invalid')
  end
end
