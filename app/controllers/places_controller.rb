class PlacesController < ApplicationController
  before_action :set_place, only: [:destroy, :edit, :update]
  
  def new
    @place = Place.new
  end
  
  def create
    @place = Place.new(place_params)
    if @place.save
      flash[:success] = "#{@place.name}を登録しました。"
      redirect_to places_url
    else
      render :new
    end
  end
  
  def index
    @places = Place.all
  end
  
  def edit
  end
  
  def update
    if @place.update_attributes(place_params)
      flash[:success] = "#{@place.name}を編集しました。"
      redirect_to places_url
    else
      render :edit
    end
  end
  
  def destroy
    @place.destroy
    flash[:success] = "#{@place.name}を削除しました。"
    redirect_to places_url
  end
  
  private
  
    def place_params
      params.require(:place).permit(:name, :number, :type_of_place)
    end
    
    def set_place
      @place = Place.find(params[:id])
    end
end
