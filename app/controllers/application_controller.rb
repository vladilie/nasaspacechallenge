class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def load_image
    position = get_position(params[:place])
  end

  def get_position place
    geocode_api_key = "AIzaSyDvTCP10kLylTivrGSvWDv5BnuACFBESJA"
    params= {address: place, key: geocode_api_key}.to_query
    google_geocode = "https://maps.googleapis.com/maps/api/geocode/json?#{params}"

    whole_result = MultiJson.load(Faraday.get(google_geocode).body, symbolize_keys: true)
    JSON.pretty_generate(whole_result[:results].first[:geometry][:location])
  end

  def picture position
    params = {api_key: nasa_api_key, lat: position[:lat], long: position[:long]}.to_query
    nasa_api = "https://api.nasa.gov/planetary/earth/imagery/?#{params}"
    MultiJson.load(Faraday.get(nasa_api).body, symbolize_keys: true)
  end
end
