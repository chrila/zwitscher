# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if user.present? && user.user_type == 'personal'
      can :destroy, Tweet, user_id: user.id
    end
  end
end
