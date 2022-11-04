class UserNotification < ApplicationRecord

    scope :notification_filter, lambda { |user_id, notification_type|
        return all unless user_id.present?
        where(user_id: user_id, notification_type: notification_type, notification_status: false).select(:id, :consultation_id, :consultation_title)
    }

    scope :notification_rank_filter, lambda { |user_id, notification_type|
        return all unless user_id.present?
        where(user_id: user_id, notification_type: notification_type, notification_status: false).select(:id)
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
            
            if !user_data.first.welcome_notification
                #Hello and welcome to Civis! 
                #Your rank is ___ in (City). Participate actively with Consultations and see your rank climb up the Leaderboard!
                main_text =  ::NotificationType.get_main_text('LEADERBOARD_UPDATE_0')
                sub_text =  ::NotificationType.get_sub_text('LEADERBOARD_UPDATE_0')
                sub_text.first['(Local Rank)'] = user_data.first.city_rank.to_s
                sub_text.first['(City)'] = user_data.first.city.name
                notification_string["main_text"] = main_text[0]
                notification_string["sub_text"] = sub_text[0]
            else
                case
                    when user_data.first.rank < 21 
                        #CongratNoulations (First Name)!!!!
                        #You have topped the charts!
                        #Your Rank is (National Rank) in India. We truly appreciate your partcipation!
                        #Everyone draws inspiration from you! View your Rank here https://www.civis.vote/leader-board
                        main_text =  ::NotificationType.get_main_text('LEADERBOARD_UPDATE_4')
                        sub_text =  ::NotificationType.get_sub_text('LEADERBOARD_UPDATE_4')
                        sub_text.first['(First Name)'] = user_data.first.first_name
                        sub_text.first['(National Rank)'] = user_data.first.rank.to_s
                        notification_string["main_text"] = main_text[0]
                        notification_string["sub_text"] = sub_text[0]        
                    when user_data.first.state_rank < 11 && user_data.first.rank > 20    
                        #"You are an inspiration (First Name)! 
                        #You Rank (State Rank) in (State) and (Local Rank) in (City) and that is truly commendable. Keep it up!!"
                        main_text =  ::NotificationType.get_main_text('LEADERBOARD_UPDATE_3')
                        sub_text =  ::NotificationType.get_sub_text('LEADERBOARD_UPDATE_3')        
                        sub_text.first['(First Name)'] = user_data.first.first_name
                        sub_text.first['(State Rank)'] = user_data.first.state_rank.to_s
                        sub_text.first['(State)'] = user_data.first.city.parent.name
                        sub_text.first['(Local Rank)'] = user_data.first.city_rank.to_s
                        sub_text.first['(City)'] = user_data.first.city.name        
                        notification_string["main_text"] = main_text[0]
                        notification_string["sub_text"] = sub_text[0]                       
                    when (user_data.first.city_rank < user_data.first.old_city_rank) && user_data.first.city_rank < 101 &&
                        user_data.first.state_rank > 10 && user_data.first.rank > 20  
                        #"Woohoo!! You now feature in the top 100 Civisens of (city)...the excitement is building up!! 
                        #View the Leaderboard of your city here https://www.civis.vote/leader-board"
                        main_text =  ::NotificationType.get_main_text('LEADERBOARD_UPDATE_2')
                        sub_text =  ::NotificationType.get_sub_text('LEADERBOARD_UPDATE_2')  
                        sub_text.first['(city)'] = user_data.first.city.name    
                        notification_string["main_text"] = main_text[0]
                        notification_string["sub_text"] = sub_text[0]
                    when (user_data.first.city_rank >= user_data.first.old_city_rank) && user_data.first.city_rank < 101 &&
                        user_data.first.state_rank > 10 && user_data.first.rank > 20  
                        #"Your position stands maintained in the top 100 of (city)..
                        #Engage more with Consultations and build up the competition! You are doing great : ) "
                        main_text =  ::NotificationType.get_main_text('LEADERBOARD_UPDATE_5')
                        sub_text =  ::NotificationType.get_sub_text('LEADERBOARD_UPDATE_5')
                        sub_text.first['(city)'] = user_data.first.city.name
                        notification_string["main_text"] = main_text[0]
                        notification_string["sub_text"] = sub_text[0]
                    when (user_data.first.city_rank < user_data.first.old_city_rank) && user_data.first.city_rank > 100 
                        #"Congratulations! Thanks to your active partIcipation, your Rank in (city) has increased by (diff) notches!!
                        # You now stand at (position) position! Keep it up and see your Rank scale up!"
                        main_text =  ::NotificationType.get_main_text('LEADERBOARD_UPDATE_1')
                        sub_text =  ::NotificationType.get_sub_text('LEADERBOARD_UPDATE_1')                            
                        sub_text.first['(city)'] = user_data.first.city.name
                        sub_text.first['(diff)'] = (user_data.first.old_city_rank - user_data.first.city_rank).to_s
                        sub_text.first['(position)'] = user_data.first.city_rank.to_s        
                        notification_string["main_text"] = main_text[0]
                        notification_string["sub_text"] = sub_text[0]
                    else
                        #"The competition is getting intense! Participate more with Consultations and up your Rank!Would you like to see how other Civisens are faring? 
                        #You can view the Leaderboard here https://www.civis.vote/leader-board"
                        main_text =  ::NotificationType.get_main_text('LEADERBOARD_UPDATE_6')
                        sub_text =  ::NotificationType.get_sub_text('LEADERBOARD_UPDATE_6')
                        notification_string["main_text"] = main_text[0]
                        notification_string["sub_text"] = sub_text[0]
                end    
            end
            
            notification_string["consultation_list"] = []
            notification_string["notification_id"] = rank_notification.first.id
            
            return notification_string
        end
    end

    def create_or_update_rank_notification(user_id)
        rank_notification = ::UserNotification.where(user_id: user_id, notification_type: 'LEADERBOARD_UPDATE')
        
        if rank_notification.exists?
            rank_notification.first.notification_status = false
            rank_notification.first.update(notification_status: false)
        elsif
            self.user_id = user_id
            self.notification_status = false
            self.consultation_id = 0
            self.notification_type = 'LEADERBOARD_UPDATE'
            self.save!
        end   
    end

    def create_rank_notification(user_id)
        self.user_id = user_id
        self.notification_status = false
        self.consultation_id = 0
        self.notification_type = 'LEADERBOARD_UPDATE'
        self.save!  
    end

    def check_for_newly_published_consultations(user_id, notification_type)
        notification_string = Hash.new
        user_last_login = ::User.where(id: user_id)
        
        consultation_list = ::Consultation.public_consultation.published_date_filter(user_last_login[0]["last_activity_at"])
        if consultation_list.exists?
            consultation_list.each { |item|

            # check if the user has responded to this consultation. If so, there is no need to create the notificaiton
            consultation_response = item.responses.find_by(user: user_id)
            if consultation_response.nil?

                notification = ::UserNotification.where(user_id: user_id, consultation_id: item["id"], notification_type: notification_type)
                if !notification.exists?                    
                    user_notification = UserNotification.new
                    user_notification.create_notification(user_id, item["id"], notification_type)
                end

            end

            }
        end
    end

end
