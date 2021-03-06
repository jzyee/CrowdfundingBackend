class UpdateController < ApplicationController
	
	include UpdateHelpers

	def add_update #Dom
		#verify that front end sent required parameters
		if verify_parameters([:project_id, :name, :description]) && verify_access_rights(@current_user, params[:project_id], true) #also verify user
			
			#create update
			@update = Project.find(params[:project_id]).project_updates.new

			#add user
			@update.user = @current_user
			#add project_name
			@update.name = params[:name]
			#add project_description
			@update.description = params[:description]
			
			#save project, else fail
			if @update.save
				render :json => {:token => @token}
			else
				key_with_error = @update.errors.keys.first
				render :json => {:error => @update.errors.messages[key_with_error].first, :cause => key_with_error}, :status => :bad_request
			end
		end
	end

	def modify_update #Dom
		@update = Update.find(params[:id])
		@project = @update.project
		#verify user has right to modify update
		if verify_access_rights(@current_user, @project.id, true)

			#get attributes for updating
			@attr_to_update = attr_to_update([:name, :description])
			
			if !@update.blank?
				@update.update_attributes(@attr_to_update)
				render :json => {:token => @token}
			else
				render :json => {:error => 'invalid', :cause => '!existent_update'}
			end
		else #user failed to verify
			render :json => {:error => 'denied', :cause => 'id'}, :status => :bad_request
		end
	end

	def delete_update
    	# Variable to store all updates which were successfully deleted
        @deleted_updates = []

    	# Verify that array of ID's was sent
    	if verify_parameters([:id])
    	    # Iterate through each ID
    	    params[:id].each do |id|
        	# Check if this user is allowed to delete the update with the ID provided
        	if verify_delete_rights(@current_user, id, false)
        	  update_to_delete = Update.find(id)
          		if !update_to_delete.blank?
            		@deleted_updates.push(update_to_delete.name)
            		update_to_delete.destroy
          		end
        	end
      	  end
      	  render :json => {:values => @deleted_updates, :type => "deleted_updates", :token => @token}
      	end
  	end

	def view_update
		# Verify that page data was sent
		if verify_parameters([:id])
			@update_to_view = Update.find(params[:id])
			# If update exists, return update back to frontend
			if @update_to_view.approved? || (!@update_to_view.approved? && verify_access_rights(params[:id], true))
				@response = @update_to_view.detailed_info
				@response[:token] = @token
				render :json => @response
			end
		end
	end
end