require "csv"
namespace :import_records_from_array do

  task :clause_types => :environment do 
    [
      "New Provision",
      "Amendment",
      "Deletion",
      "Clarification",
      "Procedural",
      "Compliance",
      "Enforcement",
      "Definition"
    ].each do |clause_type_name|
      Constant.create(constant_type: :clause_type, name: clause_type_name)
    end
  end

end
