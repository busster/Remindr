class RemindersController < ApplicationController
  include ApplicationHelper

  def index
    if logged_in?
      @user = User.find_by(id: current_user.id)
      @reminders = @user.reminders.order(time_to_go_out: :desc)
    end
  end
  
  def new
  	if logged_in?
  		@user = current_user
  	else
  		redirect_to :root
  	end
  end

  def create
    @user = User.find_by(id: params[:user_id])
  	if logged_in?
  		if @user == current_user
        @reminder = Reminder.new(reminder_params)
        @reminder.author = current_user
        params[:reminder][:contact_id].reject!{ |c| c.empty? }
        # p params[:reminder][:group_id].any?
        if params[:reminder][:group_id].length != 0
          @reminder.contacts << Group.find_by(id: params[:reminder][:group_id]).contacts
        elsif params[:reminder][:contact_id].any?
          @reminder.contacts << params[:reminder][:contact_id].map {|c| Contact.find_by(id: c)}
        else
          render :new
        end
        if @reminder.save
          redirect_to @reminder
        else
          render :new
        end
  		else
        render :new
  		end
  	else
      redirect_to :root
  	end

  end

  def edit
    @user = User.find(params[:user_id])
    @reminder = Reminder.find(params[:id])
  end

  def update
    @reminder = Reminder.find(params[:id])
    @reminder.update_attributes(reminder_params)
    redirect_to user_reminder_url(params[:user_id], @reminder)
  end

  def destroy
    @reminder = Reminder.find(params[:id])
    @reminder.destroy
    redirect_to user_reminders_url(params[:user_id])
  end

  
  private
  def reminder_params
  	params.require(:reminder).permit(:body, :time_to_go_out, :number_of_recurrences)
  end

end