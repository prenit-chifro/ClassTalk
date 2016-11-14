class EventsController < ApplicationController

  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def index
    @events = current_user.created_events
  end

  def show

  end

  def new

    @institutes = current_user.institutes

  end

  def edit

  end

  def create
    if(!params[:title].blank? and !params[:start_time].blank? and !params[:end_time].blank? and !params[:is_official].blank?)
        @event = current_user.created_events.new(title: params[:title], description: params[:description], start_time: DateTime.parse(params[:start_time]), end_time: DateTime.parse(params[:end_time]), is_official: params[:is_official], is_all_day_event: params[:is_all_day_event])

        @event.institute_id = params[:institute_id]
        if(!params[:grade_section_ids].blank?)
            params[:grade_section_ids].each do |grade_section_id|
              
              if @event.grade_section_ids.blank?
                @event.grade_section_ids = "#{grade_section_id}"
              else
                @event.grade_section_ids = @event.grade_section_ids + ", #{grade_section_id}"
              end
            end
        end

        if(!params[:participant_ids].blank?)
            params[:participant_ids].each do |participant_id|
              
              if @event.participant_ids.blank?
                @event.participant_ids = participant_id
              else
                @event.participant_ids = @event.participant_ids + ", #{participant_id}"
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
      @event.start_time = DateTime.parse(params[:start_time]) if !params[:start_time].blank?
      @event.end_time = DateTime.parse(params[:end_time]) if !params[:end_time].blank?
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

      if(!params[:participant_ids].blank?)
          @event.participant_ids = ""
          params[:participant_ids].each do |participant_id|
            
            if @event.participant_ids.blank?
              @event.participant_ids = participant_id
            else
              @event.participant_ids = @event.participant_ids + ", #{participant_id}" if !@event.participant_ids.include?(participant_id)
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
