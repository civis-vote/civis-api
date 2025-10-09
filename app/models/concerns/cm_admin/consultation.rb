module CmAdmin
  module Consultation
    extend ActiveSupport::Concern

    STATUS_TAG_COLORS = { submitted: 'bg-info', published: 'bg-success', rejected: 'bg-danger', expired: 'bg-dark' }.freeze

    included do
      cm_admin do
        actions only: []
        set_icon 'fas fa-clipboard-list'
        set_policy_scopes [{ scope_name: 'organisation_only', display_name: 'Organisation Only' }]

        cm_index do
          page_title 'Consultations'

          filter %i[title title_hindi title_odia title_marathi], :search, placeholder: 'Search'
          filter :status, :multi_select, helper_method: :select_options_for_consultation_status
          filter :review_type, :single_select, helper_method: :select_options_for_consultation_review_type
          filter :visibility, :single_select, helper_method: :select_options_for_consultation_visibility

          custom_action name: 'publish', route_type: 'member', verb: 'patch', path: ':id/publish',
                        icon_name: 'fa-solid fa-check', display_type: :button,
                        display_if: ->(consultation) { consultation.submitted? || consultation.rejected? } do
            consultation = ::Consultation.find(params[:id])
            consultation.publish
            consultation
          end

          custom_action name: 'reject', route_type: 'member', verb: 'patch', path: ':id/reject',
                        icon_name: 'fa-solid fa-ban', display_type: :button,
                        display_if: ->(consultation) { consultation.published? } do
            consultation = ::Consultation.find(params[:id])
            consultation.reject
            consultation
          end

          custom_action name: 'mark_featured', route_type: 'member', verb: 'patch', path: ':id/feature',
                        icon_name: 'fa-solid fa-star', display_type: :button,
                        display_if: ->(consultation) { !consultation.is_featured && consultation.public_consultation? } do
            consultation = ::Consultation.find(params[:id])
            consultation.update!(is_featured: true)
            consultation
          end

          custom_action name: 'un_feature', route_type: 'member', verb: 'patch', path: ':id/unfeature',
                        icon_name: 'fa-solid fa-ban', display_type: :button,
                        display_if: ->(consultation) { consultation.is_featured && consultation.public_consultation? } do
            consultation = ::Consultation.find(params[:id])
            consultation.update!(is_featured: false)
            consultation
          end

          custom_action name: 'create_response_round', route_type: 'member', verb: 'patch', path: ':id/create_response_round',
                        icon_name: 'fa-solid fa-timer', display_type: :button,
                        display_if: ->(obj) { obj.can_extend_deadline_or_create_response_round? } do
            consultation = ::Consultation.find(params[:id])
            consultation.create_response_round
            consultation
          end

          column :id
          column :title
          column :ministry_name, header: 'Ministry'
          column :status, field_type: :tag, tag_class: STATUS_TAG_COLORS
          column :response_deadline, field_type: :date, format: '%d %b, %Y'
          column :created_at, field_type: :date, format: '%d %b, %Y'
          column :created_by_full_name, header: 'Created By'
          column :responses_count
        end

        cm_show page_title: :title do
          custom_action name: 'extend_deadline', route_type: 'member', verb: 'patch', icon_name: 'fa-solid fa-timer',
                        path: ':id/extend_deadline', display_type: :form_modal,
                        display_if: ->(obj) { obj.can_extend_deadline_or_create_response_round? } do
            form do
              cm_section '' do
                form_field :response_deadline, input_type: :date
              end
            end
            on_submit do
              consultation = ::Consultation.find(params[:id])
              consultation.update!(response_deadline: params.dig(:consultation, :response_deadline))
              consultation.publish
              consultation
            end
          end

          custom_action name: 'invite_respondent', route_type: 'member', verb: 'patch', icon_name: 'fa-solid fa-envelope',
                        modal_configuration: { title: 'Invite Respondent', confirmation_text: 'Invite' },
                        path: ':id/invite_respondent', display_type: :form_modal,
                        display_if: ->(obj) { obj.private_consultation? } do
            form do
              cm_section '' do
                form_field :respondent_emails, input_type: :string,
                                               helper_text: 'Enter email addresses separated by commas, e.g. email1@example.com,email2@example.com'
              end
            end
            on_submit do
              consultation = ::Consultation.find(params[:id])
              organisation = consultation.organisation
              emails = params.dig(:consultation, :respondent_emails).split(",").map(&:strip)
              respondent_ids = ::Respondent.joins(:user).where(user: { email: emails }).pluck(:id)
              ::Respondent.invite_respondent(consultation, organisation, respondent_ids, emails, Current.user)
              consultation
            end
          end

          tab :profile, '' do
            cm_section 'Consultation details' do
              field :id, label: 'Consultation ID'
              field :title
              field :title_hindi, label: 'Title in Hindi'
              field :title_odia, label: 'Title in Odia'
              field :title_marathi, label: 'Title in Marathi'
              field :consultation_feedback_email
              field :officer_name, display_if: ->(_) { !Current.user&.role?('organisation_employee') }
              field :officer_designation, display_if: ->(_) { !Current.user&.role?('organisation_employee') }
              field :url, label: 'URL of Consultation PDF'
              field :ministry_name, label: 'Ministry'
              field :review_type, field_type: :enum, display_if: ->(_) { !Current.user&.role?('organisation_employee') }
              field :visibility, field_type: :enum, display_if: ->(_) { !Current.user&.role?('organisation_employee') }
              field :response_deadline, field_type: :datetime
              field :show_discuss_section, field_type: :custom, helper_method: :format_boolean_value
              field :status, field_type: :tag, tag_class: STATUS_TAG_COLORS
              field :feedback_url, label: 'Consultation Page', field_type: :link
              field :response_url, label: 'Consultation Summary', field_type: :link, display_if: ->(_) { !Current.user&.role?('organisation_employee') }
              field :consultation_logo, field_type: :image, display_if: ->(_) { !Current.user&.role?('organisation_employee') }
              field :is_satisfaction_rating_optional, field_type: :custom, helper_method: :format_boolean_value,
                                                      display_if: ->(_) { !Current.user&.role?('organisation_employee') }
              field :show_satisfaction_rating, field_type: :custom, helper_method: :format_boolean_value, label: 'Show Satisfaction Rating Question?'
              field :question_flow, field_type: :enum
              field :created_by_full_name, label: 'Created By'
            end
            cm_section 'Summary' do
              field :english_summary, field_type: :rich_text
              field :hindi_summary, field_type: :rich_text
              field :odia_summary, field_type: :rich_text
              field :marathi_summary, field_type: :rich_text
            end
            cm_section 'Thank You Message', display_if: ->(_) { !Current.user&.role?('organisation_employee') } do
              field :response_submission_message, field_type: :rich_text
            end
            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end
          tab :response_rounds, 'response_rounds', associated_model: 'response_rounds',
                                                   layout_type: 'cm_association_index' do
            column :id
            column :created_at, field_type: :date, format: '%d %b, %Y'
          end
          tab :responses, 'responses', associated_model: 'responses', layout_type: 'cm_association_index' do
            column :id
            column :user_response
            column :user_full_name, header: 'Given by'
            column :response_status, header: 'Status', field_type: :enum
            column :submitted_by, display_if: ->(_) { false }
            column :responder_email, display_if: ->(_) { false }
            column :city, display_if: ->(_) { false }
            column :phone_number, display_if: ->(_) { false }
            column :satisfaction_rating, display_if: ->(_) { false }
            column :visibility, display_if: ->(_) { false }
            column :submitted_at, display_if: ->(_) { false }
            column :is_verified, display_if: ->(_) { false }
            column :source, display_if: ->(_) { false }
            column :organisation, display_if: ->(_) { false }
            column :designation, display_if: ->(_) { false }
            column :user_answers, display_if: ->(_) { false }
          end
          tab :respondents, 'respondents', associated_model: 'respondents', layout_type: 'cm_association_index' do
            column :id
            column :email, field_type: :association, association_name: :user, association_type: 'belongs_to',
                           header: 'User'
            column :created_at, field_type: :date, format: '%d %b, %Y'
          end
        end

        cm_new page_title: 'Add Consultation', page_description: 'Enter all details to add Consultation' do
          cm_section 'Details' do
            form_field :title, input_type: :string
            form_field :title_hindi, input_type: :string
            form_field :title_odia, input_type: :string
            form_field :title_marathi, input_type: :string
            form_field :visibility, input_type: :single_select, display_if: ->(_) { !Current.user&.role?('organisation_employee') }
            form_field :private_response, input_type: :switch
            form_field :is_satisfaction_rating_optional, input_type: :switch, display_if: ->(_) { !Current.user&.role?('organisation_employee') }
            form_field :show_satisfaction_rating, input_type: :switch, label: 'Show Satisfaction Rating Question?',
                                                  helper_text: 'Enable this option to show the satisfaction rating section on the consultation form.'
            form_field :show_discuss_section, input_type: :switch, display_if: ->(_) { !Current.user&.role?('organisation_employee') }
            form_field :consultation_feedback_email, input_type: :string
            form_field :consultation_logo, input_type: :single_file_upload, display_if: ->(_) { !Current.user&.role?('organisation_employee') }
            form_field :officer_name, input_type: :string, display_if: ->(_) { !Current.user&.role?('organisation_employee') }
            form_field :officer_designation, input_type: :string, display_if: ->(_) { !Current.user&.role?('organisation_employee') }
            form_field :ministry_id, input_type: :single_select, helper_method: :select_options_for_ministry
            form_field :url, input_type: :string
            alert_box header: 'Time Zone Notice', type: :warning,
                      body: 'Times shown are in UTC (Coordinated Universal Time). Remember to convert to your local time when making selections.'
            form_field :response_deadline, input_type: :date_time
            form_field :review_type, input_type: :single_select, display_if: ->(_) { !Current.user&.role?('organisation_employee') }
            form_field :question_flow, input_type: :single_select
          end
          cm_section 'Summary' do
            form_field :english_summary, input_type: :rich_text
          end
        end

        cm_edit page_title: 'Edit Consultation', page_description: 'Enter all details to edit Consultation' do
          cm_section 'Details' do
            form_field :title, input_type: :string
            form_field :title_hindi, input_type: :string
            form_field :title_odia, input_type: :string
            form_field :title_marathi, input_type: :string
            form_field :visibility, input_type: :single_select, display_if: ->(_) { !Current.user&.role?('organisation_employee') }
            form_field :private_response, input_type: :switch
            form_field :is_satisfaction_rating_optional, input_type: :switch, display_if: ->(_) { !Current.user&.role?('organisation_employee') }
            form_field :show_satisfaction_rating, input_type: :switch, label: 'Show Satisfaction Rating Question?',
                                                  helper_text: 'Enable this option to show the satisfaction rating section on the consultation form.'
            form_field :show_discuss_section, input_type: :switch, display_if: ->(_) { !Current.user&.role?('organisation_employee') }
            form_field :consultation_feedback_email, input_type: :string
            form_field :consultation_logo, input_type: :single_file_upload, display_if: ->(_) { !Current.user&.role?('organisation_employee') }
            form_field :officer_name, input_type: :string, display_if: ->(_) { !Current.user&.role?('organisation_employee') }
            form_field :officer_designation, input_type: :string, display_if: ->(_) { !Current.user&.role?('organisation_employee') }
            form_field :ministry_id, input_type: :single_select, helper_method: :select_options_for_ministry
            form_field :url, input_type: :string
            alert_box header: 'Time Zone Notice', type: :warning,
                      body: 'Times shown are in UTC (Coordinated Universal Time). Remember to convert to your local time when making selections.'
            form_field :response_deadline, input_type: :date_time
            form_field :review_type, input_type: :single_select, display_if: ->(_) { !Current.user&.role?('organisation_employee') }
            form_field :question_flow, input_type: :single_select
          end
          cm_section 'Summary' do
            form_field :english_summary, input_type: :rich_text
            form_field :hindi_summary, input_type: :rich_text
            form_field :odia_summary, input_type: :rich_text
            form_field :marathi_summary, input_type: :rich_text
          end
          cm_section 'Thank You Message', display_if: ->(_) { !Current.user&.role?('organisation_employee') } do
            form_field :response_submission_message, input_type: :rich_text
          end
        end
      end
    end
  end
end
