module Types
	module Objects
		class Paging < BaseObject
			field :current_page, 		Int, "Current page", null: false, hash_key: :current_page
			field :total_items, 		Int, "Total items for the query", null: false, hash_key: :total_items
			field :total_pages, 		Int, "Total pages for the query", null: false, hash_key: :total_pages
		end
	end
end