# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161109100225) do

  create_table "android_devices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "gcm_registration_id"
    t.integer  "android_device_user_id"
    t.boolean  "is_android_device_user_signed_in", default: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.index ["android_device_user_id"], name: "index_android_devices_on_android_device_user_id", using: :btree
    t.index ["gcm_registration_id"], name: "index_android_devices_on_gcm_registration_id", using: :btree
  end

  create_table "android_notifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.string   "message"
    t.string   "target_url"
    t.string   "image_url"
    t.text     "big_image_url", limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "apple_web_notification_subscriptions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "device_token"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["device_token"], name: "index_apple_web_notification_subscriptions_on_device_token", using: :btree
    t.index ["user_id"], name: "index_apple_web_notification_subscriptions_on_user_id", using: :btree
  end

  create_table "attachments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "category"
    t.string   "attachable_type"
    t.integer  "attachable_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "media_file_name"
    t.string   "media_content_type"
    t.integer  "media_file_size"
    t.datetime "media_updated_at"
    t.index ["attachable_type", "attachable_id"], name: "index_attachments_on_attachable_type_and_attachable_id", using: :btree
    t.index ["category"], name: "index_attachments_on_category", using: :btree
  end

  create_table "attendance_records", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "institute_id"
    t.integer  "grade_id"
    t.integer  "section_id"
    t.string   "present_student_ids", default: ""
    t.date     "date"
    t.integer  "creator_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["date"], name: "index_attendance_records_on_date", using: :btree
    t.index ["grade_id"], name: "index_attendance_records_on_grade_id", using: :btree
    t.index ["institute_id"], name: "index_attendance_records_on_institute_id", using: :btree
    t.index ["section_id"], name: "index_attendance_records_on_section_id", using: :btree
  end

  create_table "conversation_participants", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "conversation_id"
    t.integer  "participant_id"
    t.integer  "participant_adder_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["conversation_id"], name: "index_conversation_participants_on_conversation_id", using: :btree
    t.index ["participant_id"], name: "index_conversation_participants_on_participant_id", using: :btree
  end

  create_table "conversations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "conversation_name",  default: ""
    t.integer  "creator_id"
    t.integer  "institute_id"
    t.integer  "grade_id"
    t.integer  "section_id"
    t.integer  "subject_id"
    t.string   "message_categories", default: ""
    t.integer  "last_message_id"
    t.boolean  "is_custom_group",    default: true
    t.string   "requestor_ids",      default: ""
    t.string   "blocked_ids",        default: ""
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.index ["blocked_ids"], name: "index_conversations_on_blocked_ids", using: :btree
    t.index ["conversation_name"], name: "index_conversations_on_conversation_name", using: :btree
    t.index ["creator_id"], name: "index_conversations_on_creator_id", using: :btree
    t.index ["grade_id"], name: "index_conversations_on_grade_id", using: :btree
    t.index ["institute_id"], name: "index_conversations_on_institute_id", using: :btree
    t.index ["last_message_id"], name: "index_conversations_on_last_message_id", using: :btree
    t.index ["message_categories"], name: "index_conversations_on_message_categories", using: :btree
    t.index ["requestor_ids"], name: "index_conversations_on_requestor_ids", using: :btree
    t.index ["section_id"], name: "index_conversations_on_section_id", using: :btree
    t.index ["subject_id"], name: "index_conversations_on_subject_id", using: :btree
  end

  create_table "events", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "is_all_day_event"
    t.integer  "creator_id"
    t.string   "participant_ids"
    t.boolean  "is_official"
    t.integer  "institute_id"
    t.string   "grade_section_ids"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["creator_id"], name: "index_events_on_creator_id", using: :btree
    t.index ["end_time"], name: "index_events_on_end_time", using: :btree
    t.index ["grade_section_ids"], name: "index_events_on_grade_section_ids", using: :btree
    t.index ["institute_id"], name: "index_events_on_institute_id", using: :btree
    t.index ["participant_ids"], name: "index_events_on_participant_ids", using: :btree
    t.index ["start_time"], name: "index_events_on_start_time", using: :btree
  end

  create_table "grade_sections", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "institute_id"
    t.integer  "grade_id"
    t.integer  "section_id"
    t.integer  "classteacher_id"
    t.integer  "creator_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["classteacher_id"], name: "index_grade_sections_on_classteacher_id", using: :btree
    t.index ["creator_id"], name: "index_grade_sections_on_creator_id", using: :btree
    t.index ["grade_id"], name: "index_grade_sections_on_grade_id", using: :btree
    t.index ["institute_id"], name: "index_grade_sections_on_institute_id", using: :btree
    t.index ["section_id"], name: "index_grade_sections_on_section_id", using: :btree
  end

  create_table "grades", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "grade_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grade_name"], name: "index_grades_on_grade_name", using: :btree
  end

  create_table "institute_grades", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "institute_id"
    t.integer  "grade_id"
    t.integer  "creator_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["creator_id"], name: "index_institute_grades_on_creator_id", using: :btree
    t.index ["grade_id"], name: "index_institute_grades_on_grade_id", using: :btree
    t.index ["institute_id"], name: "index_institute_grades_on_institute_id", using: :btree
  end

  create_table "institute_members", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "institute_id"
    t.integer  "member_id"
    t.string   "role_in_institute"
    t.string   "child_ids"
    t.integer  "father_id"
    t.integer  "mother_id"
    t.integer  "creator_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["child_ids"], name: "index_institute_members_on_child_ids", using: :btree
    t.index ["creator_id"], name: "index_institute_members_on_creator_id", using: :btree
    t.index ["father_id"], name: "index_institute_members_on_father_id", using: :btree
    t.index ["institute_id"], name: "index_institute_members_on_institute_id", using: :btree
    t.index ["member_id"], name: "index_institute_members_on_member_id", using: :btree
    t.index ["mother_id"], name: "index_institute_members_on_mother_id", using: :btree
    t.index ["role_in_institute"], name: "index_institute_members_on_role_in_institute", using: :btree
  end

  create_table "institutes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "institute_name"
    t.integer  "creator_id"
    t.string   "unique_institute_code"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["creator_id"], name: "index_institutes_on_creator_id", using: :btree
    t.index ["institute_name"], name: "index_institutes_on_institute_name", using: :btree
    t.index ["unique_institute_code"], name: "index_institutes_on_unique_institute_code", using: :btree
  end

  create_table "ios_devices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "ios_device_token"
    t.integer  "ios_device_user_id"
    t.boolean  "is_ios_device_user_signed_in"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "locations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.float    "latitude",       limit: 24
    t.float    "longitude",      limit: 24
    t.string   "address"
    t.string   "locatable_type"
    t.integer  "locatable_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["latitude"], name: "index_locations_on_latitude", using: :btree
    t.index ["locatable_type", "locatable_id"], name: "index_locations_on_locatable_type_and_locatable_id", using: :btree
    t.index ["longitude"], name: "index_locations_on_longitude", using: :btree
  end

  create_table "messages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text     "content",                     limit: 65535
    t.integer  "creator_id"
    t.integer  "conversation_id"
    t.string   "seen_user_ids",                             default: ""
    t.boolean  "is_seen_by_all_participants",               default: false
    t.string   "category",                                  default: "Messages"
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.index ["category"], name: "index_messages_on_category", using: :btree
    t.index ["conversation_id"], name: "index_messages_on_conversation_id", using: :btree
    t.index ["creator_id"], name: "index_messages_on_creator_id", using: :btree
    t.index ["seen_user_ids"], name: "index_messages_on_seen_user_ids", using: :btree
  end

  create_table "notices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "creator_id"
    t.integer  "institute_id"
    t.string   "grade_section_ids"
    t.string   "recipient_ids"
    t.string   "seen_user_ids",             default: ""
    t.boolean  "is_seen_by_all_recipients", default: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.index ["creator_id"], name: "index_notices_on_creator_id", using: :btree
    t.index ["grade_section_ids"], name: "index_notices_on_grade_section_ids", using: :btree
    t.index ["institute_id"], name: "index_notices_on_institute_id", using: :btree
    t.index ["recipient_ids"], name: "index_notices_on_recipient_ids", using: :btree
    t.index ["seen_user_ids"], name: "index_notices_on_seen_user_ids", using: :btree
  end

  create_table "rpush_apps", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                                              null: false
    t.string   "environment"
    t.text     "certificate",             limit: 65535
    t.string   "password"
    t.integer  "connections",                           default: 1, null: false
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "type",                                              null: false
    t.string   "auth_key"
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "access_token"
    t.datetime "access_token_expiration"
  end

  create_table "rpush_feedback", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "device_token", limit: 64, null: false
    t.datetime "failed_at",               null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "app_id"
    t.index ["device_token"], name: "index_rpush_feedback_on_device_token", using: :btree
  end

  create_table "rpush_notifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "badge"
    t.string   "device_token",      limit: 64
    t.string   "sound",                              default: "default"
    t.text     "alert",             limit: 65535
    t.text     "data",              limit: 65535
    t.integer  "expiry",                             default: 86400
    t.boolean  "delivered",                          default: false,     null: false
    t.datetime "delivered_at"
    t.boolean  "failed",                             default: false,     null: false
    t.datetime "failed_at"
    t.integer  "error_code"
    t.text     "error_description", limit: 65535
    t.datetime "deliver_after"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.boolean  "alert_is_json",                      default: false
    t.string   "type",                                                   null: false
    t.string   "collapse_key"
    t.boolean  "delay_while_idle",                   default: false,     null: false
    t.text     "registration_ids",  limit: 16777215
    t.integer  "app_id",                                                 null: false
    t.integer  "retries",                            default: 0
    t.string   "uri"
    t.datetime "fail_after"
    t.boolean  "processing",                         default: false,     null: false
    t.integer  "priority"
    t.text     "url_args",          limit: 65535
    t.string   "category"
    t.boolean  "content_available",                  default: false
    t.text     "notification",      limit: 65535
    t.index ["app_id", "delivered", "failed", "deliver_after"], name: "index_rapns_notifications_multi", using: :btree
    t.index ["delivered", "failed"], name: "index_rpush_notifications_multi", using: :btree
  end

  create_table "section_members", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "institute_id"
    t.integer  "grade_id"
    t.integer  "section_id"
    t.integer  "member_id"
    t.integer  "creator_id"
    t.string   "member_role"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["creator_id"], name: "index_section_members_on_creator_id", using: :btree
    t.index ["grade_id"], name: "index_section_members_on_grade_id", using: :btree
    t.index ["institute_id"], name: "index_section_members_on_institute_id", using: :btree
    t.index ["member_id"], name: "index_section_members_on_member_id", using: :btree
    t.index ["member_role"], name: "index_section_members_on_member_role", using: :btree
    t.index ["section_id"], name: "index_section_members_on_section_id", using: :btree
  end

  create_table "section_subjects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "institute_id"
    t.integer  "grade_id"
    t.integer  "section_id"
    t.integer  "subject_id"
    t.integer  "subject_teacher_id"
    t.integer  "creator_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["creator_id"], name: "index_section_subjects_on_creator_id", using: :btree
    t.index ["grade_id"], name: "index_section_subjects_on_grade_id", using: :btree
    t.index ["institute_id"], name: "index_section_subjects_on_institute_id", using: :btree
    t.index ["section_id"], name: "index_section_subjects_on_section_id", using: :btree
    t.index ["subject_id"], name: "index_section_subjects_on_subject_id", using: :btree
    t.index ["subject_teacher_id"], name: "index_section_subjects_on_subject_teacher_id", using: :btree
  end

  create_table "sections", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "section_name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["section_name"], name: "index_sections_on_section_name", using: :btree
  end

  create_table "subjects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "subject_name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["subject_name"], name: "index_subjects_on_subject_name", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email"
    t.string   "mobile_no"
    t.string   "isd_code"
    t.string   "encrypted_password"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "oauth_provider"
    t.string   "oauth_uid"
    t.boolean  "email_verified",                               default: false
    t.boolean  "mobile_no_verified",                           default: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "gender"
    t.string   "role"
    t.string   "system_encrypted_password"
    t.string   "system_password_encryption_key"
    t.string   "system_password_encryption_iv"
    t.string   "send_account_password_on_android_device_flag", default: "0"
    t.string   "unique_user_code"
    t.boolean  "is_online",                                    default: false
    t.boolean  "is_registration_complete",                     default: false
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.index ["email"], name: "index_users_on_email", using: :btree
    t.index ["first_name"], name: "index_users_on_first_name", using: :btree
    t.index ["is_registration_complete"], name: "index_users_on_is_registration_complete", using: :btree
    t.index ["last_name"], name: "index_users_on_last_name", using: :btree
    t.index ["mobile_no"], name: "index_users_on_mobile_no", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", using: :btree
    t.index ["role"], name: "index_users_on_role", using: :btree
  end

  create_table "web_notification_subscriptions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.text     "endpoint",   limit: 65535
    t.string   "auth"
    t.string   "p256dh"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["auth"], name: "index_web_notification_subscriptions_on_auth", using: :btree
    t.index ["p256dh"], name: "index_web_notification_subscriptions_on_p256dh", using: :btree
    t.index ["user_id"], name: "index_web_notification_subscriptions_on_user_id", using: :btree
  end

end
