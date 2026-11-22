require "test_helper"

class KitchenSinkTest < ActionDispatch::IntegrationTest
  test "every component renders together in a real request" do
    get "/kitchen_sink"
    assert_response :success
    assert_select "script", /geekofia-ui-theme/
    assert_select "h1", "Kitchen sink"
    assert_select "[data-controller=ui-theme]"
    assert_select "[data-controller=ui-clipboard]", minimum: 2
    assert_select "table thead th", "Name"
    assert_select "[role=progressbar]"
    assert_select "ol > li", 2
    assert_select "form input#thing_name"
  end
end
