class ExperimentsController < ApplicationController
  before_action :set_experiment_user
  before_action :set_experiment, only: [:show, :edit, :update, :destroy]

  # GET /experiments
  def index
    @experiments = @experiment_user.experiments
  end

  # GET /experiments/1
  def show
    if params[:rpcsr_check].present?
      @rpcsr_check_result = params[:rpcsr_check]
    end
  end

  # GET /experiments/new
  def new
    @experiment = @experiment_user.experiments.new
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
      rh = RpcsHTTPS.new(ENV['RPCSR_PASSWORD'])

      Tempfile.create('sourcepoint-') do |tmp|
        File.write tmp, @experiment.file1.encode('UTF-8', 'UTF-8')
        res = rh.create_attempt(tmp.path, @experiment.current_assignment_id == 441 ? 587: @experiment.current_assignment_id)
        if m = res['location'].match(/(?<id>\d+\z)/)
          redirect_to @experiment, rpcsr_check: rh.get_attempt(m[:id])
        else
          raise
        end
      end
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

    def set_experiment_user
      @experiment_user = ExperimentUser.find(params[:experiment_user_id])
    end

    # Only allow a trusted parameter "white list" through.
    def experiment_params
      params.require(:experiment).permit(:file1, :current_assignment_id, :experiment_user_id, :end_at, :deleted_at)
    end
end
