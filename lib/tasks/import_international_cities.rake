require "csv"
namespace :import_records_from_csv do
  task :international_cities => :environment do
    filepath = Rails.root + "imports/international_cities.csv"
    CSV.foreach(filepath, headers: true) do |csv_city|
      if csv_city["City"].present?
        Location.create(name: csv_city["City"], is_international_city: true, location_type: :city)
      end
    end
  end
end