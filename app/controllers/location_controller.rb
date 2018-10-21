require_relative 'get_image_api_action'

class LocationController < ApplicationController

  def home
  end

  def place
    action = GetImage::Api::Action.new(params[:place].gsub('+', ', '))
    @tile = action.as_tile(5)
  end
end
