require 'rails_helper'

RSpec.describe Department, type: :model do
  let(:admin) { create(:user, role: :admin) }

  # set_created_by stamps created_by from Current.user, and approving awards the
  # creator points — both need a signed-in user.
  before { Current.user = admin }
  after { Current.reset }

  def create_department(attrs = {})
    Department.create!({
      name: "Dept #{SecureRandom.hex(4)}", level: :national, is_approved: true,
      department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }]
    }.merge(attrs))
  end

  describe 'validations' do
    it 'needs a name and a level' do
      expect(Department.new).not_to be_valid
    end

    it 'needs a primary contact' do
      expect(Department.new(name: 'No contact', level: :national)).not_to be_valid
    end
  end

  describe 'contacts' do
    it 'finds the primary and secondary contacts' do
      department = create_department(department_contacts_attributes: [
                                       { contact_type: :primary, email: 'primary@test.com' },
                                       { contact_type: :secondary, email: 'secondary@test.com' }
                                     ])

      expect(department.primary_contact.email).to eq('primary@test.com')
      expect(department.secondary_contact.email).to eq('secondary@test.com')
    end
  end

  describe 'scopes' do
    it 'filters approved departments' do
      approved = create_department
      create_department(is_approved: false)

      expect(Department.approved).to include(approved)
    end

    it 'searches by name' do
      department = create_department(name: 'Ministry of Health')

      expect(Department.search('health')).to include(department)
    end
  end

  describe '#approve and #reject' do
    it 'stamps the approver and approval time' do
      department = create_department(is_approved: false)

      department.approve

      expect(department.reload).to be_is_approved
      expect(department.approved_by_id).to eq(admin.id)
      expect(department.approved_at).to be_present
    end

    it 'stamps the rejecter and rejection time' do
      department = create_department

      department.reject

      expect(department.reload.is_approved).to be(false)
      expect(department.rejected_by_id).to eq(admin.id)
      expect(department.rejected_at).to be_present
    end
  end

  describe '#status' do
    it 'reflects the approval flag' do
      expect(create_department.status).to eq('approved')
      expect(create_department(is_approved: false).status).to eq('not_approved')
    end
  end
end
