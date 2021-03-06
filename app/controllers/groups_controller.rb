class GroupsController < ApplicationController

  def index
    @user = User.find_by(id: current_user.id)
    if current_user
      @groups = @user.groups
    end
  end

  def show
    @user = current_user
    @group = @user.groups.find_by(id: params[:id])
  end

  def new
    @user = User.find_by(id: current_user.id)
  end

  def create
    if current_user
      @group = Group.new(group_params)
      current_user.groups << @group

      contact_ids = params[:group][:contact_id]
      contact_ids.reject!{ |c| c.empty? }
      if contact_ids.length != 0
        contact_ids.each {|contact_id| @group.contacts << Contact.find_by(id: contact_id)} 
      end

      if @group.save
        redirect_to user_group_path(@group.user, @group)
      else
        render :new
      end
    end
  end

  def edit
    @user = User.find(params[:user_id])
    @group = Group.find(params[:id])
  end

  def update
    contact_ids = params[:group][:contact_ids]
    contact_ids.reject!{ |c| c.empty? }
    @group = Group.find(params[:id])
    @group.update_attributes(group_params)

    if !contact_ids.empty?
      @group.contacts = []
      contact_ids.each {|id| @group.contacts << Contact.find_by(id: id)}
    end
    redirect_to user_group_url(params[:user_id], @group)
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    redirect_to user_groups_url(params[:user_id])
  end


  private
  def group_params
    params.require(:group).permit(:name, :contacts)
  end

end