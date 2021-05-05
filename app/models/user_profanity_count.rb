class UserProfanityCount < ApplicationRecord
    include SpotlightSearch
    include Paginator
      
    # validates: user_id, presence:tr
    # ue
    belongs_to :user, foreign_key: "user_id"
    scope :search, lambda { |query|
      return nil  if query.blank?
      terms = query.downcase.split(/\s+/)
      # replace "*" with "%" for wildcard searches,
      # append '%', remove duplicate '%'s
      terms = terms.map { |e|
        (e.gsub("*", "%").prepend("%") + "%").gsub(/%+/, "%")
      }
      # configure number of OR conditions for provision
      # of interpolation arguments. Adjust this if you
      # change the number of OR conditions.
      num_or_conds = 2
      where(
        terms.map { |term|
          "(user_id LIKE ? OR profanity_count LIKE ?)"
        }.join(" OR "),
        *terms.map { |e| [e] * num_or_conds }.flatten,
      )
    }

    scope:search_user_id, lambda { |query|
    return nil  if query.blank?
    terms = query.downcase.split(/\s+/)
    terms = terms.map { |e|
      (e.gsub("*", "%").prepend("%") + "%").gsub(/%+/, "%")
    }
    num_or_conds = 1
    where(
      terms.map { |term|
        "(user_id = ? )"
      }
      # .join(" OR "),
      # *terms.map { |e| [e] * num_or_conds }.flatten,
    )
  }
  
end
