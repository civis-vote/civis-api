Rails.application.reloader.to_prepare do
  CmAdmin.configure do |config|
    # Sets the default layout to be used for admin
    config.layout = 'admin'
    # config.authorized_roles = [:super_admin?]
    config.included_models = [Theme, CmRole, CmPermission, User, Wordindex, Profanity, CaseStudy,
                              ConsultationResponse, Department, Organisation, Consultation, GlossaryWordConsultationMapping,
                              ResponseRound, Question, FileImport, FileExport, Respondent]

    config.project_name = Rails.configuration.x.project_settings.name
    config.enable_tracking = true

    config.sidebar = [
      {
        path: :cm_index_user_path
      },
      {
        path: :cm_index_cm_role_path
      },
      {
        path: :cm_index_consultation_path
      },
      {
        path: :cm_index_organisation_path
      },
      {
        path: :cm_index_department_path
      },
      {
        path: :cm_index_case_study_path
      },
      {
        path: :cm_index_theme_path
      },
      {
        display_name: 'Glossary',
        path: :cm_index_wordindex_path
      },
      {
        path: :cm_index_profanity_path
      },
      {
        display_name: 'User Responses',
        path: :cm_index_consultation_response_path
      },
      {
        display_name: 'File Imports',
        path: :cm_index_file_import_path
      },
      {
        display_name: 'File Exports',
        path: :cm_index_file_export_path
      }
    ]
  end
end
