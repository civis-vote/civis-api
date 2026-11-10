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

end
