class Constant < ApplicationRecord
  # Canonical CIVIS segment names (stored as constants of type :segment).
  SEGMENT_NAMES = [
    "Adventure tourism",
    "Advertising regulation",
    "Affordable housing",
    "Agricultural inputs",
    "Agricultural markets and MSP",
    "Animal health and livestock",
    "Aviation safety",
    "Banking and credit",
    "Broadcasting and TV",
    "Capital markets",
    "Child labour and trafficking",
    "Child rights and justice",
    "Circular economy",
    "City master plans and land use",
    "Climate change and net zero",
    "Climate finance",
    "Consumer grievance redressal",
    "Courts and judicial reforms",
    "Criminal law and procedure",
    "Cultural heritage",
    "Cybersecurity",
    "Data governance and surveillance",
    "Data protection and privacy",
    "Digital accessibility",
    "Digital governance",
    "Digital health and health data",
    "Digital identity and KYC",
    "Digital public infrastructure",
    "Disability rights",
    "Drugs and medical devices",
    "E-commerce and platforms",
    "Electric vehicles",
    "Electricity tariffs and markets",
    "Environmental impact assessment",
    "Farmer producer organisations",
    "Fintech and digital payments",
    "Fisheries and blue economy",
    "Food safety in schools",
    "Food standards and labelling",
    "Forests and wildlife",
    "Gender equality and safety",
    "Government service delivery",
    "Green buildings",
    "Health systems",
    "Higher education",
    "Industrial relations and strikes",
    "Informal and gig workers",
    "Insurance and market conduct",
    "Irrigation and water use",
    "Labour codes and wages",
    "Local government and panchayats",
    "Mediation and arbitration",
    "Mental health",
    "Migration and overseas workers",
    "MSMEs and industrial policy",
    "Occupational safety and health",
    "Oil and gas",
    "Organic and climate-resilient farming",
    "OTT and online content",
    "Outdoor advertising",
    "Physical accessibility",
    "Pollution control",
    "Power grid and storage",
    "Print and press",
    "Product standards and quality",
    "Public finance and taxation",
    "Public health emergencies",
    "Public transport",
    "Rare diseases",
    "Renewable energy",
    "Road safety and traffic",
    "Rural land rights",
    "School education",
    "Shipping and ports",
    "Skills and vocational training",
    "Social security and pensions",
    "Solid waste management",
    "Sports governance",
    "Startups and innovation",
    "Telecom regulation",
    "Tobacco and alcohol control",
    "Tourism development",
    "Urban biodiversity and open spaces",
    "Urban climate resilience",
    "Urban mobility and parking",
    "Waste and hazardous materials",
    "Women's economic empowerment",
    "Youth participation"
  ].freeze

  include CmAdmin::Constant
  include Paginator

  has_many :children, class_name: "Constant", foreign_key: "parent_id"
  belongs_to :parent, class_name: "Constant", optional: true

  enum :constant_type, ::CONSTANT_TYPES

  scope :constant_type_filter, lambda { |constant_type|
    return all unless constant_type.present?

    where(constant_type: constant_type)
  }

  scope :sort_records, lambda { |sort, sort_direction = "asc"|
    return nil if sort.blank?

    order("#{sort} #{sort_direction}")
  }
end
