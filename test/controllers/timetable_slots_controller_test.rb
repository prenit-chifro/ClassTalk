require 'test_helper'

class TimetableSlotsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get timetable_slots_index_url
    assert_response :success
  end

  test "should get new" do
    get timetable_slots_new_url
    assert_response :success
  end

  test "should get create" do
    get timetable_slots_create_url
    assert_response :success
  end

  test "should get show" do
    get timetable_slots_show_url
    assert_response :success
  end

  test "should get edit" do
    get timetable_slots_edit_url
    assert_response :success
  end

  test "should get update" do
    get timetable_slots_update_url
    assert_response :success
  end

  test "should get destroy" do
    get timetable_slots_destroy_url
    assert_response :success
  end

end
