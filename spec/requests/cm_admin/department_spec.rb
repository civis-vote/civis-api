require "rails_helper"

RSpec.describe "Department admin", type: :request do
  let!(:departments) { %w[Engineering Design Sales].map { |name| create(:department, name:) } }
  let(:department) { departments.first }

  before { cm_admin_sign_in }

  describe "index" do
    it "lists every department" do
      expect(cm_admin_index(Department)).to list_records(*departments)
    end

    it "finds a department by name" do
      expect(cm_admin_index(Department, search: department.name)).to list_records(department)
    end

    it "sorts by response count" do
      engineering, design, sales = departments
      engineering_consultation = create(:consultation, department: engineering, status: :published)
      design_consultation = create(:consultation, department: design, status: :published)
      2.times { create(:consultation_response, consultation: engineering_consultation) }
      create(:consultation_response, consultation: design_consultation)

      expect(cm_admin_index(Department, sort: { consultations_consultation_responses_count: :desc }))
        .to list_records(engineering, design, sales).in_order
    end
  end

  it "shows a department" do
    expect(cm_admin_show(department)).to have_field(:name).with_value(department.name)
  end

  it "creates a department with a primary contact" do
    result = cm_admin_create(Department, name: "Finance", level: "national",
                                         department_contacts: [{ contact_type: "primary", name: "Finance Officer",
                                                                 email: "finance@example.com" }])

    expect(result).to create_record(Department).with(name: "Finance")
  end

  it "renames a department" do
    expect(cm_admin_update(department, name: "New Name")).to succeed
    expect(department.reload.name).to eq("New Name")
  end

  it "deletes a department" do
    delete cm_admin_path(Department, :destroy, department)

    expect(response).to have_http_status(:found)
    expect(Department.exists?(department.id)).to be(false)
  end
end
