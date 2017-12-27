class ExperimentUsersController < ApplicationController
  before_action :set_experiment_user, only: [:show, :edit, :update, :destroy]

  # GET /experiment_users
  def index
    @experiment_users = ExperimentUser.all
  end

  # GET /experiment_users/1
  def show
  end

  # GET /experiment_users/new
  def new
    @experiment_user = ExperimentUser.new
  end

  # GET /experiment_users/1/edit
  def edit
  end

  # POST /experiment_users
  def create
    @experiment_user = ExperimentUser.new(experiment_user_params)

    if @experiment_user.save
      redirect_to @experiment_user, notice: 'Experiment user was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /experiment_users/1
  def update
    if @experiment_user.update(experiment_user_params)
      redirect_to @experiment_user, notice: 'Experiment user was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /experiment_users/1
  def destroy
    @experiment_user.destroy
    redirect_to experiment_users_url, notice: 'Experiment user was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_experiment_user
      @experiment_user = ExperimentUser.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def experiment_user_params
      params.require(:experiment_user).permit(:name, :deleted_at)
    end
end
