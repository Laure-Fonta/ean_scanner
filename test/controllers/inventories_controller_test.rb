require "test_helper"

class InventoriesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get inventories_show_url
    assert_response :success
  end

  test "should get export_found" do
    get inventories_export_found_url
    assert_response :success
  end

  test "should get export_not_found" do
    get inventories_export_not_found_url
    assert_response :success
  end
end
