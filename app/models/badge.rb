class Badge < ActiveRecord::Base
  belongs_to :user

  BADGE_LIST = {"Setup": [{type: 'completed_profile', description: "Complete your user profile."},
                  {type: 'connected_mountain_project', description: "Connect your Mountain Project account."}],

                "First Timers": [{type: 'created_first_exercise', title: "", description: "You created your first exercise."},
                  {type: 'created_first_workout', title: "", description: "You created your first workout."},
                  {type: 'created_first_macrocycle', title: "", description: "You created your first training plan."},
                  {type: 'created_first_goal', title: "", description: "You created your first goal."},
                  {type: 'created_first_like', title: "", description: "You liked your first item."},
                  {type: 'created_first_message', title: "", description: "You sent your first message."},
                  {type: 'created_first_discussion', title: "", description: "You started your first forum discussion."},
                  {type: 'first_follower', title: "", description: "You followed your first user."},
                  {type: 'first_followed', title: "", description: "You got your first follower."},
                  {type: 'first_self_assessment', title: "", description: "You completed your first self-assessment."},
                  {type: 'first_copy', title: "Plagiarist", description: "You copied your first item."}],

                "Popularity Contest": [{type: 'ten_likes', title: "", description: "Something of yours received 10 likes."},
                  {type: 'ten_messages', title: "Hot Topic", description: "Something of yours started 10 messages."},
                  {type: 'first_copied', title: "", description: "Someone copied one of your items."},
                  {type: 'admin_like', title: "", description: "The site admin likes one of your items."}],

                "Achievements": [{type: 'achieved_first_goal', title: "Achiever", description: "You achieved your first goal!"},
                  {type: 'climbing_level_up', title: "Super Saiyan", description: "You broke through to a new climbing grade!"},
                  {type: 'completed_first_macrocycle', title: "Dedicated", description: "You completed your first training plan."},
                  {type: 'improved_self_assessment', title: "Self Improvement", description: "You improved on your last self-assessment!"},
                  {type: 'achieved_five_goals', title: "Over-Achiever", description: "You achieved five of your goals!"},
                  {type: 'climbing_five_level_ups', title: "Over 9000!", description: "You broke through to a new climbing grade!"},
                  {type: 'completed_five_macrocycles', title: "Monastic", description: "You completed your five training plans."},
                  {type: 'improved_five_self_assessments', title: "Limitless", description: "You improved on five of your self-assessments!"}],

                "Achievements": [{type: 'achieved_first_goal', title: "Achiever", description: "You achieved your first goal!"},
                  {type: 'climbing_level_up', title: "Over 9000!", description: "You broke through to a new climbing grade!"},
                  {type: 'completed_first_macrocycle', title: "Dedicated", description: "You completed your first training plan."},
                  {type: 'improved_self_assessment', title: "Self Improvement", description: "You improved on your last self-assessment!"}],
              }

  def self.check_badge_completion(item, acting_user)
    user = item.respond_to?(:user) ? item.user : acting_user

    case item.class.name
    when "Exercise"
      check_exercise_badges(user)

    when "Workout"
      check_workout_badges(user)

    when "Macrocycle"
      check_macrocycle_badges(user)

    when "Goal"
      check_goal_badges(user)

    when "User"
      #Completed profile

      #added mountain project

    when "Message"
      #first message

      #10 messages on item

    when "Vote"
      #first like

      #10 likes

      #liked by site admin

    when "UserFollower"
      #first follower

      #first followed

    when "Event"
      #first self-assessment

      #improve on self-assessment

      #complete first plan

    when "Attempt"
      #climbing level up

    else
      #copied first thing

      #first thing gets copied

    end
  end


  def self.check_exercise_badges(user)
    #First new exercise
    user_exercises = user.exercises
    user_badges = user.badges
    if user_exercises.where.not(reference_id: Exercise::SEEDED_REFERENCE_IDS).count >= 1 &&
       user_badges.where(badge_type: "created_first_exercise").blank?
      user_badges.create(badge_type: "created_first_exercise")
    end
  end

  def self.check_workout_badges(user)
    #First new workout
    user_workouts = user.workouts
    user_badges = user.badges
    if user_workouts.where.not(reference_id: Workout::SEEDED_REFERENCE_IDS).count >= 1 &&
       user_badges.where(badge_type: "created_first_workout").blank?
      user_badges.create(badge_type: "created_first_workout")
    end
  end

  def self.check_macrocycle_badges(user)
    #First new macrocycle
    user_macrocycles = user.macrocycles
    user_badges = user.badges
    if user_macrocycles.where.not(reference_id: Macrocycle::SEEDED_REFERENCE_IDS).count >= 1 &&
       user_badges.where(badge_type: "created_first_macrocycle").blank?
      user_badges.create(badge_type: "created_first_macrocycle")
    end
  end

  def self.check_goal_badges(user)
    #First new goal
    user_goals = user.goals
    user_badges = user.badges
    if user_goals.count >= 1 &&
       user_badges.where(badge_type: "created_first_goal").blank?
      user_badges.create(badge_type: "created_first_goal")
    end

    #Achieved first goal
    if user_goals.where(parent_goal_id: nil, compeleted: true).count >=1 &&
       user_badges.where(badge_type: "achieved_first_goal").blank?
      user_badges.create(badge_type: "achieved_first_goal")
    end
  end

  def self.check_all_badges(user)
    check_exercise_badges(user)
    check_workout_badges(user)
    check_macrocycle_badges(user)
    check_goal_badges(user)
  end
end
