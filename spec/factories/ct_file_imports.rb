FactoryBot.define do
  factory :ct_file_import do
    associated_model_name { 'Wordindex' }
    added_by { association :user, role: :admin }
    import_type { :default_importer }
  end

  factory :ct_file_export do
    associated_model_name { 'Wordindex' }
    exported_by { association :user, role: :admin }
    expires_at { 1.day.from_now }
    export_type { :default_export }
  end
end
