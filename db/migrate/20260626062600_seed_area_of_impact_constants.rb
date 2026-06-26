class SeedAreaOfImpactConstants < ActiveRecord::Migration[8.1]
  AREA_OF_IMPACT_VALUES = [
    'National',
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal'
  ].freeze

  def up
    AREA_OF_IMPACT_VALUES.each do |name|
      Constant.find_or_create_by!(name: name, constant_type: :area_of_impact)
    end
  end

  def down
    Constant.where(constant_type: :area_of_impact).destroy_all
  end
end
