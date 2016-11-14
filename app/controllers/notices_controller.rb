class NoticesController < ApplicationController

	before_action :set_notice, only: [:show, :edit, :update, :destroy]

	def index
		@institutes = current_user.institutes
		if(params[:page] and params[:page].to_i > 1)
			@notices = Notice.where(institute_id: @institutes.map(&:id)).order(updated_at: :desc).page(params[:page]).per(10)
			render "index", layout: false
		else
			@notices = Notice.where(institute_id: @institutes.map(&:id)).order(updated_at: :desc).page(1).per(10)
		end
		
	end

	def show
		if(request.format.js?)
			render layout: false
		else
					
		end
	end

	def new

		@institutes = current_user.institutes
		
		if(request.format.js?)
			render partial: "new"
		else
			render "_new"		
		end
	end

	def edit
		if(request.format.js?)
			render partial: "edit"
		else
			render "_edit"		
		end
	end

	def create
		if(!params[:title].blank?)
		    @notice = current_user.created_notices.new(title: params[:title], description: params[:description])

		    @notice.institute_id = params[:institute_id]
		    if(!params[:grade_section_ids].blank?)
		        params[:grade_section_ids].each do |grade_section_id|
		          
		          if @notice.grade_section_ids.blank?
		            @notice.grade_section_ids = "#{grade_section_id}"
		          else
		            @notice.grade_section_ids = @notice.grade_section_ids + ", #{grade_section_id}"
		          end
		        end
		    end

		    if(!params[:recipient_ids].blank?)
		        params[:recipient_ids].each do |recipient_id|
		          
		          if @notice.recipient_ids.blank?
		            @notice.recipient_ids = recipient_id
		          else
		            @notice.recipient_ids = @notice.recipient_ids + ", #{recipient_id}"
		          end
		        end
		    end

		    @notice.save


		    redirect_to notices_path
		else

		end

	end

	def update
		@notice.institute_id = params[:institute_id] if !params[:institute_id].blank?
		@notice.title = params[:title] if !params[:title].blank?
		@notice.description = params[:description] if !params[:description].blank?
		if(!params[:grade_section_ids].blank?)
		  @notice.grade_section_ids = "" if 
		  params[:grade_section_ids].each do |grade_section_id|
		    
		    if @notice.grade_section_ids.blank?
		      @notice.grade_section_ids = "#{grade_section_id}"
		    else
		      @notice.grade_section_ids = @notice.grade_section_ids + ", #{grade_section_id}" if !@notice.grade_section_ids.include?(grade_section_id)
		    end
		  end
		end

		if(!params[:recipient_ids].blank?)
		  @notice.participant_ids = ""
		  params[:recipient_ids].each do |recipient_id|
		    
		    if @notice.participant_ids.blank?
		      @notice.participant_ids = participant_id
		    else
		      @notice.participant_ids = @event.participant_ids + ", #{participant_id}"
		    end
		  end
		end

		@notice.save
	  	redirect_to notices_path
	end

	def destroy
		@notice.destroy
		redirect_to notices_path
	end

	def set_notice
	   	@notice = Notice.find_by(id: params[:id])
	 	@institute = @notice.institute
	 	@grade_section_models = @notice.grade_section_models
	end

end
