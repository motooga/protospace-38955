class PrototypesController < ApplicationController

  private
  
  def prototype_params
    params.require(:prototype).permit(:content, :image).merge(user_id: current_user.id)
end
