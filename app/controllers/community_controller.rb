class CommunityController < ApplicationController
	include CommunityHelpers
	#skip_before_action :check_token, :only => [:login, :register]

	def add_comment
		if verify_parameters([:subject_id, :content, :type])
			puts @current_user
			@comment = @current_user.comments.new

			#setup new comment
			@comment.content = params[:content]
			@comment.comment_type = CommentType.where(:name => params[:type]).first
			if @comment.comment_type.name == "PROJECT"
				@comment.project = Project.find(params[:subject_id])
			elsif @comment.comment_type.name == "UPDATE"
				@comment.update = Update.find(params[:subject_id])
			end

			if @comment.save
				render :json =>{:token => @token}
			else
				key_error = @comment.keys.first
				render :json => {:error => @comment.errors.messages[key_error].first, :cause=> key_error}, :status => :bad_request	
			end
		end
	end


	def delete_comment
		
		if verify_parameters([:id])
				@d_id = params[:id]
				#if verify_access_rights(@current_user, @d_id, false)
					@comment_to_delete = Comment.where(:id => @d_id)
					if verify_access_rights(@current_user, @comment_to_delete.user_id, false)
						if !@comment_to_delete.blank?
							@comment_to_delete.destroy
							render :json => {:token => @token}
						else
							render :json => {:error => 'invalid', :cause => 'id'}, :status => :bad_request	
						end	
					end
			
		end
	end

	def view_comment
		if verify_parameters([:id])
			@comment_to_view = Comment.where(:id => params[:id])

			#if commment exists,return user to frontend
			unless @comment_to_view.blank?
				#where to write .info?
				@response = @comment_to_view.info
				@response[:token] =	@token
				render :json => @response
			else
				render :json => {:error => 'invalid', :cause => 'id'}, :status => :bad_request
			end
			
		end
	end

	def vote
		if verify_parameters([:project_id, :value, :v_type])
			@vote = Vote.new
			@vote.project_id = params[:project_id]
			@vote.value = params[:value]
			@vote.vote_type_id = params[:v_type]
			

			if @vote.save
				render :json =>{:token => @token}
			else
				key_error = @vote.keys.first
				render :json => {:error => @comment.errors.messages[key_error].first, :cause=> key_error}, :status => :bad_request	
			end

		end
	end


end