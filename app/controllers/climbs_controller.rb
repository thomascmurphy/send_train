class ClimbsController < ApplicationController
  def index
    @ascents = current_user.climbs
  end
end
