class TemplatesController < ApplicationController
  before_action :set_template, only: [:show, :edit, :update, :destroy, :rpcsr_check]

  # GET /templates
  def index
    @current_assignment_ids = Template.pluck(:current_assignment_id).uniq
    @templates = Template.where(status: ['internal_error', 'executed'], current_assignment_id: params[:current_assignment_id])
      .order(is_check: :desc)
      .includes(:template_lines, submission: :lines)
  end

  # GET /templates/1
  def show
    if params[:rpcsr_check].present?
      @rpcsr_check_result = params[:rpcsr_check]
    end
    @rpcsr_attempt = params[:rpcsr_attempt].present? ? Template.new(params.require(:rpcsr_attempt).permit(:file1, :current_assignment_id)).tap{|t|t.file1 = Base64.decode64(t.file1).encode('UTF-8', 'UTF-8')} : @template.dup
    @template_lines = @template.template_lines
    @submission = Submission.new(
      @template.attributes.select{ |key, _|
        [:file1, :messages, :status, :mark, :comment, :user_id].include?(key.to_sym)
      }.merge(template_id: @template.id, assignment_id: @template.current_assignment_id)
    )
  end

  # GET /templates/new
  def new
    @template = Template.new
  end

  # GET /templates/1/edit
  def edit
  end

  # POST /templates
  def create
    @template = Template.new(template_params)

    if @template.save
      redirect_to @template, notice: 'Template was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /templates/1
  def update
    if @template.update(template_params)
      redirect_to @template, notice: 'Template was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /templates/1
  def destroy
    @template.destroy
    redirect_to templates_url, notice: 'Template was successfully destroyed.'
  end


  def rpcsr_check
    rh = RpcsHTTPS.new(ENV['RPCSR_PASSWORD'])
    check_template = params[:template].present? ? Template.new(template_params) : @template

    Tempfile.create('sourcepoint-') do |tmp|
      File.write tmp, check_template.file1.encode('UTF-8', 'UTF-8')
      res = rh.create_attempt(tmp.path, check_template.current_assignment_id == 441 ? 587: check_template.current_assignment_id)
      if m = res['location'].match(/(?<id>\d+\z)/)
        redirect_to template_path(@template, rpcsr_check: rh.get_attempt(m[:id]), rpcsr_attempt: { file1: Base64.encode64(check_template.file1), current_assignment_id: check_template.current_assignment_id })
      else
        raise
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_template
      @template = Template.find(params[:id])
      @template.file1 = @template.file1.encode('UTF-8', 'UTF-8')
      @template
    end

    # Only allow a trusted parameter "white list" through.
    def template_params
      params.require(:template).permit(:file1, :status, :user_id, :encode_code, :current_assignment_id, :assignment_id, :is_check)
    end
end
