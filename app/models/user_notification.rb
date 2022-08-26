class UserNotification < ApplicationRecord
    # include SpotlightSearch
    # include Paginator

    scope :notification_filter, lambda { |user_id, notification_type|
        return all unless user_id.present?
        where(user_id: user_id, notification_type: notification_type, notification_status: false).select(:id, :consultation_id, :consultation_title)
    }

    scope :notification_rank_filter, lambda { |user_id, notification_type|
        return all unless user_id.present?
        where(user_id: user_id, notification_type: notification_type).select(:id, :city_rank, :state_rank, :national_rank)
    }

    scope :consultation_id_filter, lambda { |consultation_id, user_id|
        return all unless user_id.present?
        where(oldrank: consultation_id, user_id: user_id)
    }

    scope :notification_exists, lambda { |user_id, consultation_id, type|
        return all unless user_id.present?
        where(user_id: user_id, consultation_id: consultation_id, notification_type: type)
    }
    
    def create_notification(user_id, consultation_id, type)
        self.user_id = user_id
        self.consultation_id = consultation_id
        self.consultation_title = ::Consultation.where(id: consultation_id).pluck("title")[0]
        self.notification_type = type
        self.notification_status = false
        self.save!
    end

    def delete_notification(user_id,consultation_id,type)
        user_notification = ::UserNotification.notification_exists(user_id,consultation_id,type)
        if user_notification.exists?
            user_notification.destroy(user_notification.ids[0])
        end
    end

    def check_notification(user_id, notification_type)
        notification_string = Hash.new
        consultation_list = ::UserNotification.notification_filter(user_id, notification_type)
        if consultation_list.exists?
            main_text =  ::NotificationType.get_main_text(notification_type)
		    sub_text =  ::NotificationType.get_sub_text(notification_type)
            notification_string["type"] = notification_type
            notification_string["main_text"] = main_text[0]
            notification_string["sub_text"] = sub_text[0]
            notification_string["consultation_list"] = JSON.parse(consultation_list.to_json)
            return notification_string
        end
    end

    def check_rank_notification(user_id)
        notification_string = Hash.new
        rank_notification = ::UserNotification.notification_rank_filter(user_id, 'LEADERBOARD_UPDATE')
        user_data = ::User.where(id: user_id) 
        
        if rank_notification.exists?
            
            notification_string["type"] = 'LEADERBOARD_UPDATE'
            if user_data.first.city_rank < rank_notification.first.city_rank && 
                user_data.first.city_rank > 100 &&
                user_data.first.state_rank > 10 &&
                user_data.first.rank > 20
                #"Congratulations! Thanks to your active partIcipation, your Rank in (city) has increased by (diff) notches!!
                 # You now stand at (position) position! Keep it up and see your Rank scale up!"
                main_text =  ::NotificationType.get_main_text('LEADERBOARD_UPDATE_1')
                sub_text =  ::NotificationType.get_sub_text('LEADERBOARD_UPDATE_1')
                
                sub_text.first['(city)'] = user_data.first.city.name
                sub_text.first['(diff)'] = (rank_notification.first.city_rank - user_data.first.city_rank).to_s
                sub_text.first['(position)'] = user_data.first.city_rank.to_s

                notification_string["main_text"] = main_text[0]
                notification_string["sub_text"] = sub_text[0]
            elsif user_data.first.city_rank < 101 &&
                    user_data.first.state_rank > 10 &&
                    user_data.first.rank > 20
                #"Woohoo!! You now feature in the top 100 Civisens of (city)...the excitement is building up!! 
                #View the Leaderboard of your city here https://www.civis.vote/leader-board"
                main_text =  ::NotificationType.get_main_text('LEADERBOARD_UPDATE_2')
                sub_text =  ::NotificationType.get_sub_text('LEADERBOARD_UPDATE_2')  
                sub_text.first['(city)'] = user_data.first.city.name    
                notification_string["main_text"] = main_text[0]
                notification_string["sub_text"] = sub_text[0] 
            elsif user_data.first.state_rank < 11 &&
                    user_data.first.rank > 20
                #    "You are an inspiration (First Name)! 
                #    You Rank (State Rank) in (State) and (Local Rank) in (City) and that is truly commendable. Keep it up!!"
                main_text =  ::NotificationType.get_main_text('LEADERBOARD_UPDATE_3')
                sub_text =  ::NotificationType.get_sub_text('LEADERBOARD_UPDATE_3')

                sub_text.first['(First Name)'] = user_data.first.first_name
                sub_text.first['(State Rank)'] = user_data.first.state_rank.to_s
                sub_text.first['(State)'] = user_data.first.city.parent.name
                sub_text.first['(Local Rank)'] = user_data.first.city_rank.to_s
                sub_text.first['(City)'] = user_data.first.city.name

                notification_string["main_text"] = main_text[0]
                notification_string["sub_text"] = sub_text[0]
            elsif user_data.first.rank < 21
                #Congratulations (First Name)!!!!
                #You have topped the charts!
                #Your Rank is (National Rank) in India. We truly appreciate your partcipation!
                #Everyone draws inspiration from you! View your Rank here https://www.civis.vote/leader-board
                main_text =  ::NotificationType.get_main_text('LEADERBOARD_UPDATE_4')
                sub_text =  ::NotificationType.get_sub_text('LEADERBOARD_UPDATE_4')
                sub_text.first['(First Name)'] = user_data.first.first_name
                sub_text.first['(National Rank)'] = user_data.first.rank.to_s
                notification_string["main_text"] = main_text[0]
                notification_string["sub_text"] = sub_text[0]
            elsif user_data.first.city_rank <= rank_notification.first.city_rank &&
                    user_data.first.state_rank < 11 &&
                        user_data.first.rank < 21
                #"Your position stands maintained in the top 10 of (city)..
                #Engage more with Consultations and build up the competition! You are doing great : ) "
                main_text =  ::NotificationType.get_main_text('LEADERBOARD_UPDATE_5')
                sub_text =  ::NotificationType.get_sub_text('LEADERBOARD_UPDATE_5')
                sub_text.first['(city)'] = user_data.first.city.name
                notification_string["main_text"] = main_text[0]
                notification_string["sub_text"] = sub_text[0]
            elsif ( 
                    user_data.first.city_rank <= rank_notification.first.city_rank || 
                    user_data.first.state_rank <= rank_notification.first.state_rank ||
                    user_data.first.rank <= rank_notification.first.national_rank
                ) &&
                    user_data.first.state_rank > 10
                    #"The competition is getting intense! Participate more with Consultations and up your Rank!Would you like to see how other Civisens are faring? 
                    #You can view the Leaderboard here https://www.civis.vote/leader-board"
                main_text =  ::NotificationType.get_main_text('LEADERBOARD_UPDATE_6')
                sub_text =  ::NotificationType.get_sub_text('LEADERBOARD_UPDATE_6')
                notification_string["main_text"] = main_text[0]
                notification_string["sub_text"] = sub_text[0]
            
            end
            
            return notification_string
        end
    end

    def create_rank_notification(user_id,city_rank,state_rank, national_rank)
        rank_notification = ::UserNotification.where(user_id: user_id, notification_type: 'LEADERBOARD_UPDATE')
        
        if rank_notification.exists?
            rank_notification.first.city_rank = city_rank
            rank_notification.first.state_rank = state_rank
            rank_notification.first.national_rank = national_rank
            rank_notification.first.notification_status = false
            rank_notification.first.update(city_rank: city_rank, state_rank: state_rank, national_rank: national_rank, notification_status: false)
        elsif
            self.user_id = user_id
            self.notification_status = false
            self.city_rank = city_rank
            self.state_rank = state_rank
            self.national_rank = national_rank
            self.notification_type = 'LEADERBOARD_UPDATE'
            self.save!
        end   
    end

    def create_newly_created_consultation_notification(user_id, notification_type)
        notification_string = Hash.new
        user_last_login = ::User.where(id: user_id)
        
        consultation_list = ::Consultation.public_consultation.published_date_filter(user_last_login[0]["last_activity_at"])
        if consultation_list.exists?
            consultation_list.each { |item|
                notification = ::UserNotification.where(user_id: user_id, consultation_id: item["id"], notification_type: notification_type)
                if !notification.exists?                    
                    user_notification = UserNotification.new
                    user_notification.create_notification(user_id, item["id"], notification_type)
                end
            }
        end
    end

end
