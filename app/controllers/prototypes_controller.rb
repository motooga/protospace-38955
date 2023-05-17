class PrototypesController < ApplicationController
  before_action :set_prototype, except: [:index, :new, :create]

  def index
    @prototypes = Prototype.all
  end

  def new
    @prototype = Prototype.new
  end

  def create
    @prototype = Prototype.new(prototype_params)
    if @prototype.save
      redirect_to root_path
    else
      render :new
    end  
  end

  private
  
  def prototype_params
    params.require(:prototype).permit(:title, :catch_copy, :concept, :image).merge(user_id: current_user.id)
    
  end

  def set_prototype
    
    @prototype = Prototype.find(params[:id])
  end

end