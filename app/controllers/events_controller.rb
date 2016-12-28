class EventsController < ApplicationController

  before_action :set_timezone
  def set_timezone
      Time.zone = "New Delhi"
  end

  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def index
    @events = @institute.events
    @personal_events = current_user.created_events.where(is_official: false)
    @events = @events + @personal_events
  end

  def show

  end

  def new
    if(current_user.role == "Student" or current_user.role == "Parent")
      head :ok
      return 
    end
    @institutes = current_user.institutes

  end

  def edit
    if(!current_user.role.include?("Principal") and !current_user.role.include?("Institute Admin"))
      head :ok
      return 
    end
  end

  def create
    if(!params[:title].blank? and !params[:start_time].blank? and !params[:end_time].blank? and !params[:is_official].blank?)
        @event = current_user.created_events.new(title: params[:title], description: params[:description], start_time: Time.parse(params[:start_time]), end_time: Time.parse(params[:end_time]), is_official: params[:is_official], is_all_day_event: params[:is_all_day_event])

        @event.institute_id = params[:institute_id]
        @grade_section_models = @institute.institutes_grades_sections_models
        if(!@grade_section_models.blank?)
            @grade_section_models.each do |grade_section_model|
              
              if @event.grade_section_ids.blank?
                @event.grade_section_ids = "#{grade_section_model.id}"
              else
                @event.grade_section_ids = @event.grade_section_ids + ", #{grade_section_model.id}"
              end
            end
        end

        @event.save
    else

    end
  
  end

  def update
      @event.institute_id = params[:institute_id] if !params[:institute_id].blank?
      @event.title = params[:title] if !params[:title].blank?
      @event.description = params[:description] if !params[:description].blank?
      @event.start_time = Time.parse(params[:start_time]) if !params[:start_time].blank?
      @event.end_time = Time.parse(params[:end_time]) if !params[:end_time].blank?
      @event.is_official = params[:is_official] if !params[:is_official].blank?
      @event.is_all_day_event = params[:is_all_day_event] if !params[:is_all_day_event].blank?
      if(!params[:grade_section_ids].blank?)
          @event.grade_section_ids = "" 
          params[:grade_section_ids].each do |grade_section_id|
            
            if @event.grade_section_ids.blank?
              @event.grade_section_ids = "#{grade_section_id}"
            else
              @event.grade_section_ids = @event.grade_section_ids + ", #{grade_section_id}" if !@event.grade_section_ids.include?(grade_section_id)
            end
          end
      end

      @event.save
      
  end

  def destroy
    @event.destroy
  end

  def set_event
	   @event = Event.find_by(id: params[:id])
     @institute = @event.institute
     @grade_section_models = @event.grade_section_models
  end

end
