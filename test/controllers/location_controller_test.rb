require 'test_helper'

class LocationControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get location_home_url
    assert_response :success
  end

  test "should get place" do
    get location_place_url
    assert_response :success
  end

end
