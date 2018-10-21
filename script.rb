search_url = 'https://cmr.earthdata.nasa.gov/opensearch/granules/descriptor_document.xml?utf8=%E2%9C%93&clientId=edsc-prod&shortName=Landsat4-8_ARD_US_C1&versionId=1&dataCenter=USGS_EROS&commit=Generate&clientId=edsc-prod&_ga=2.143990652.8397503.1540015988-1322192271.1540015988'

require_relative 'app/controllers/get_image_api_action'
require_relative 'app/controllers/get_astro_api_action'

require 'active_support/all'
# require 'opensearch'
#
# # initialize
# engine = OpenSearch::OpenSearch.new search_url
#
# # get information of  Description Document
# name = engine.short_name
# tags = engine.tags
#
# puts engine.to_s
# # search (retrun value is RSS::Rss)
# feed = engine.search("Romania","application/rss+xml")
#
# puts feed


nasa_api_key = ENV['NASA_API_KEY']

place= "Timisoara, Romania"
geocode_api_key = ENV['GEOCODE_API_KEY']

 action = GetImage::Api::Action.new(place)
puts action.as_tile


# action = GetAstro::Api::Action.new()
# action.events
