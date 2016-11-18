class TimetableSlotsController < ApplicationController
  
    def index
      
        if(current_user.role == "Institute Admin")
            render "admin_timetable"
        end

        if(current_user.role == "Teacher")
            render "teacher_timetable"
        end

        if(current_user.role == "Student")
            render "student_timetable"
        end 

        if(current_user.role == "Parent")
            render "student_timetable"
        end

    end

    def new
      
    end

    def create
    
    end

    def show
    
    end

    def edit
    
    end

    def update
    
    end

    def destroy
    
    end

end
