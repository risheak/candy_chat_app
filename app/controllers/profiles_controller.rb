class ProfilesController < ApplicationController
  def index
    @q = Profile.ransack(params[:q])
    @profiles = @q.result.page(params[:page]).per(10)
  end
end
