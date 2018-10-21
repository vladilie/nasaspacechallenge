require "faraday"
require 'multi_json'
require 'json'

module GetImage
  module Api

    class Action
      NASA_API_KEY = ENV['NASA_API_KEY']
      GEOCODE_API_KEY = ENV['GEOCODE_API_KEY']
      PLACES_API_KEY = ENV['PLACES_API_KEY']
      π = 3.14

      attr_accessor :place
      def initialize(place)
        @place = place
      end

      def images
        a_position = position(place)
        assets = asset(a_position)
        place_dir = place.gsub(',', '_').gsub(' ', '_')
        assets[:results].inject [] do |acc, asset|
          picture = picture(a_position, asset[:date][0..9])
          picture_response = Faraday.get(picture[:url])
          picture_path = "#{place_dir}/#{asset[:id].gsub('/', '_')}.png"
          Dir.mkdir(place_dir) unless Dir.exist?(place_dir)
          File.write(picture_path, picture_response.body) if picture_response.status.to_s == '200'
          code = picture_response.status
          picture = picture.merge(code: code, local: picture_path)
          acc << picture; acc
        end
      end

      def assets
        asset(position(place))
      end

      def position place
        params= {address: place, key: GEOCODE_API_KEY}
        params = params.to_query
        google_geocode = "https://maps.googleapis.com/maps/api/geocode/json?#{params}"
        whole_result = MultiJson.load(Faraday.get(google_geocode).body, symbolize_keys: true)
        puts whole_result
        whole_result[:results].first[:geometry][:location]
      end

      def picture position, date = nil
        params = {api_key: NASA_API_KEY, lat: position[:lat], lon: position[:lng]}
        params[:date] = date if date
        params = params.to_query
        nasa_imagery = "https://api.nasa.gov/planetary/earth/imagery/?#{params}"
        MultiJson.load(Faraday.get(nasa_imagery).body, symbolize_keys: true)
      end

      def asset position
        params = {api_key: NASA_API_KEY, lat: position[:lat], lon: position[:lng]}.to_query
        nasa_asset = "https://api.nasa.gov/planetary/earth/assets?#{params}"
        MultiJson.load(Faraday.get(nasa_asset).body, symbolize_keys: true)
      end

      def as_tile(zoom = 5)
        a_position = position(place)
        get_tile_number(a_position[:lat], a_position[:lng], zoom)
      end

      def get_tile_number(lat_deg, lng_deg, zoom)
        lat_rad = lat_deg/180 * Math::PI
        n = 2.0 ** zoom
        x = ((lng_deg + 180.0) / 360.0 * n) + 0.5
        y = ((1.0 - Math::log(Math::tan(lat_rad) + (1 / Math::cos(lat_rad))) / Math::PI) / 2.0 * n) + 0.5

        {:x => x.to_i, :y => y.to_i}
      end

      def tiles
        a_position = position(place)
        zoom = 3
        a_tile = get_tile_number(a_position[:lat], a_position[:lng], zoom)
        tile_url = "https://gibs.earthdata.nasa.gov/wmts/epsg4326/best/AIRS_Carbon_Dioxide_AIRS_AMSU_Monthly/default/{Time}/{TileMatrixSet}/{TileMatrix}/{TileRow}/{TileCol}.png"
        tile_matrixset = "GoogleMapsCompatible_Level6"
        tile_with_matrixset = tile_url.gsub('{TileMatrixSet}', tile_matrixset).gsub('{TileMatrix}', zoom.to_s)

        assets[:results].inject [] do |acc, asset|
          tile_with_date = tile_with_matrixset.gsub('{Time}', asset[:date][0..9])
          tile_with_y = tile_with_date.gsub('{TileRow}', a_tile[:y].to_s)
          tile_with_x = tile_with_y.gsub('{TileCol}', a_tile[:x].to_s)
          acc << tile_with_x; acc
        end
      end
    end
  end
end