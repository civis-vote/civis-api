require "rails_helper"

RSpec.describe "cm-admin bulk actions", type: :request do
  include Warden::Test::Helpers

  # Scorable concerns award points on user/department creation and read PointScale,
  # which the point_scale.csv seed provides in development.
  before do
    PointScale.actions.keys.each do |action|
      PointScale.find_or_create_by!(action:, upper_limit: 1_000_000) { |scale| scale.points = 1.0 }
    end
    Location.find_or_create_by!(name: 'Chennai', location_type: :city) unless Location.cities.exists?
  end

  after { Warden.test_reset! }

  def sign_in_admin
    role = CmRole.find_or_create_by!(name: 'Admin')
    CmPermission.find_or_create_by!(cm_role: role, ar_model_name: 'Consultation', action_name: 'delete', scope_name: 'all')
    Current.user = Fabricate(:user, role: :admin, cm_role: role)
    login_as(Current.user, scope: :user)
  end

  it "runs the consultation delete bulk action without a 500" do
    sign_in_admin
    department = Fabricate(:department)
    consultations = 2.times.map { Fabricate(:consultation, department:) }

    post '/cm_admin/consultations/delete', params: { selected_ids: consultations.map(&:id).join(',') },
                                           headers: { 'Referer' => '/cm_admin/consultations' }

    expect(response).not_to have_http_status(:error), response.body
    expect(consultations.map(&:reload).map(&:deleted?)).to all(be(true))
  end
end
