FactoryBot.define do
  factory :cm_permission do
    cm_role
    action_name { 'index' }
    ar_model_name { 'Wordindex' }
    scope_name { 'all' }
  end
end
