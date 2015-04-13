class OldusersController < ApplicationController
  def index
  	@oldusers = Olduser.all
  end

  def show
  	@olduser = Olduser.find(params[:id])
  end

  private

  def olduser_params
  	params.require(:olduser).permit(:name, :name_profile_image_url, :score)
  end
end
