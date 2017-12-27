class ExperimentsController < ApplicationController
  before_action :set_experiment, only: [:show, :edit, :update, :destroy]

  # GET /experiments
  def index
    @experiments = Experiment.all
  end

  # GET /experiments/1
  def show
  end

  # GET /experiments/new
  def new
    @experiment = Experiment.new
  end

  # GET /experiments/1/edit
  def edit
  end

  # POST /experiments
  def create
    @experiment = Experiment.new(experiment_params)

    if @experiment.save
      redirect_to @experiment, notice: 'Experiment was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /experiments/1
  def update
    if @experiment.update(experiment_params)
      redirect_to @experiment, notice: 'Experiment was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /experiments/1
  def destroy
    @experiment.destroy
    redirect_to experiments_url, notice: 'Experiment was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_experiment
      @experiment = Experiment.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def experiment_params
      params.require(:experiment).permit(:file1, :assignment_id, :experiment_user_id, :end_at, :deleted_at)
    end
end
