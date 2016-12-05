class AdminRightWorker
  include Sidekiq::Worker
  def perform(staff_id, add_or_remove)
    @staff = User.find_by(id: staff_id)
    if(!@staff.blank?)
    	if(add_or_remove == "Add")
    		if(@staff.role.include?("Institute Admin"))
    			return
    		else
    			@staff.update(role: @staff.role + ", Institute Admin")
    		end	
    	elsif(add_or_remove == "Remove")
    		if(!@staff.role.include?("Institute Admin"))
    			return
    		else
    			if(@staff.role.include?(", Institute Admin"))
    				@staff.update(role: @staff.role.gsub(", Institute Admin", ""))	
    			end
    		end
    	end
    end
  end
end