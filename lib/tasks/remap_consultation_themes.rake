namespace :themes do

  # Maps legacy theme names (pre-Civis list) to the current theme names.
  # Composite legacy themes expand to multiple current themes.
  OLD_TO_NEW_THEME_NAMES = {
    "Education" => ["Education"],
    "Environment, Waste Management" => ["Environment"],
    "Healthcare, Women and Child Development, Sanitation, Accessibility" => ["Health"],
    "Agriculture, Rural Development" => ["Agriculture", "Rural Development"],
    "Telecom, Internet, Media" => ["Telecom", "Internet", "Media"],
    "Finance, Energy, Industry" => ["Finance", "Energy", "Industry"],
    "Urban Settlements" => ["Urban Settlements"],
    "Labour" => ["Labour"]
  }.freeze

  desc "Remap consultation theme_maps from legacy theme names to the current theme list"
  task remap_consultation_themes: :environment do
    unmapped = Hash.new(0)
    orphaned = 0
    remapped = 0

    ::ThemeMap.where(mappable_type: 'Consultation').find_each do |theme_map|
      old_theme = ::Theme.with_deleted.find_by(id: theme_map.theme_id)
      old_name = old_theme&.name || "<missing theme ##{theme_map.theme_id}>"
      new_names = OLD_TO_NEW_THEME_NAMES[old_name] ||
                  (::CIVIS_THEME_NAMES.include?(old_name) ? [old_name] : nil)

      if new_names.nil?
        unmapped[old_name] += 1
        next
      end

      mappable = theme_map.mappable
      if mappable.nil?
        orphaned += 1
        next
      end

      new_themes = new_names.map { |name| ::Theme.find_or_create_by!(name: name) }
      next if new_themes.map(&:id) == [theme_map.theme_id]

      new_themes.each do |theme|
        ::ThemeMap.find_or_create_by!(theme: theme, mappable: mappable)
      end
      theme_map.destroy!
      remapped += 1
    end

    puts "Remapped #{remapped} consultation theme_maps"
    puts "Skipped #{orphaned} theme_maps whose consultation no longer exists"
    if unmapped.any?
      puts "Unmapped themes (reported, not changed):"
      unmapped.each { |name, count| puts "  #{name}: #{count} theme_maps" }
    end
  end

  # Consultations tagged with the legacy "Others" theme, mapped to their
  # assigned theme (chosen from the consultation title, 2026-11-10).
  OTHERS_TO_THEME_NAMES = {
    1791 => "Agriculture",           # Prevention of Cruelty to Animals (lab animals) Rules
    1797 => "Energy",                # Petroleum (Amendment) Bill
    1798 => "Transport",             # CAR-66 Aircraft Maintenance Engineer Licensing
    1799 => "Transport",             # CAR Commercial Air Transport - Aeroplanes
    1801 => "Transport",             # CAR General Aviation Aeroplanes
    1802 => "Industry",              # National Steel Policy
    1804 => "Legal Affairs",         # Uniform Civil Code Committee survey
    1807 => "Transport",             # ISM Circular (maritime safety)
    1809 => "Finance",               # SEBI LODR review
    1810 => "Finance",               # SEBI ICDR review
    1817 => "Public Administration", # Ladakh AHDC delimitation - Zanskar
    1818 => "Public Administration", # Ladakh AHDC delimitation - Sham
    1819 => "Public Administration", # Ladakh AHDC delimitation - Sankoo
    1820 => "Public Administration", # Ladakh AHDC delimitation - Leh
    1821 => "Public Administration", # Ladakh AHDC delimitation - Drass
    1822 => "Public Administration", # Ladakh AHDC delimitation - Changthang
    1823 => "Public Administration", # Ladakh AHDC delimitation - Kargil
    1824 => "Public Administration", # Ladakh AHDC delimitation - Nubra
    1829 => "Transport",             # CMV Amendment BS VII N1
    1830 => "Transport",             # CMV Amendment BS VII heavy-duty
    1831 => "Transport",             # CMV Amendment BS VII M1
    1832 => "Health",                # Lakshadweep Excise Rules (alcohol control)
    1834 => "Transport",             # MV Scrapping Facility Amendment Rules
    1835 => "Legal Affairs",         # AI and Squatting in Trademark Prosecutions
    1836 => "Transport",             # Kerala Inland Vessels Rules
    1837 => "Transport",             # A&N Model Inland Vessel Rules
    1838 => "Public Administration", # A&N Fire and Emergency Service Rules
    1842 => "Transport",             # Aeronautical Tariff Calicut Airport
    1846 => "Energy"                 # Colliery Control (coal) Amendment Rules
  }.freeze

  desc "Assign themes to consultations still tagged with the legacy 'Others' theme"
  task assign_others_themes: :environment do
    changed = 0
    missing = 0

    OTHERS_TO_THEME_NAMES.each do |consultation_id, theme_name|
      consultation = ::Consultation.find_by(id: consultation_id)
      unless consultation
        missing += 1
        puts "  SKIP: consultation #{consultation_id} not found"
        next
      end

      theme = ::Theme.find_or_create_by!(name: theme_name)
      next if consultation.themes.pluck(:id) == [theme.id]

      consultation.theme_maps.destroy_all
      ::ThemeMap.create!(theme: theme, mappable: consultation)
      changed += 1
      puts "  #{consultation_id} -> #{theme_name}"
    end

    puts "Assigned themes to #{changed} consultations (#{OTHERS_TO_THEME_NAMES.size - missing - changed} already correct)"
    remaining = ::ThemeMap.joins(:theme).where(mappable_type: 'Consultation').where.not(themes: { name: ::CIVIS_THEME_NAMES })
    puts "Legacy theme maps remaining: #{remaining.count}"
  end

  # Consultations with NO theme at all (blank/unknown tag in the metadata
  # export), mapped to their assigned theme (chosen from the title, 2026-11-10).
  NO_THEME_TO_THEME_NAMES = {
    1640 => "Energy", # Public Consultation on Draft SHANTI Rules (nuclear energy)
    1641 => "Energy"  # SHANTI Rules and Regulations (nuclear energy)
  }.freeze

  desc "Assign themes to consultations that have no theme at all"
  task assign_no_theme_consultations: :environment do
    changed = 0
    missing = 0

    NO_THEME_TO_THEME_NAMES.each do |consultation_id, theme_name|
      consultation = ::Consultation.find_by(id: consultation_id)
      unless consultation
        missing += 1
        puts "  SKIP: consultation #{consultation_id} not found"
        next
      end

      theme = ::Theme.find_or_create_by!(name: theme_name)
      next if consultation.themes.pluck(:id) == [theme.id]

      consultation.theme_maps.destroy_all
      ::ThemeMap.create!(theme: theme, mappable: consultation)
      changed += 1
      puts "  #{consultation_id} -> #{theme_name}"
    end

    puts "Assigned themes to #{changed} consultations (#{NO_THEME_TO_THEME_NAMES.size - missing - changed} already correct)"
    untagged = ::Consultation.left_joins(:theme_maps).where(theme_maps: { id: nil }).count
    puts "Consultations with no theme at all: #{untagged}"
  end

end
