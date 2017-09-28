class TemplateLinesController < ApplicationController

  # GET /template_lines
  def index
    @template_lines = find_template.template_lines
  end

  # GET /template_lines/1
  def show
    find_template_line
  end

  # GET /template_lines/new
  def new
    @template_line = find_template.template_lines.new
  end

  # GET /template_lines/1/edit
  def edit
    find_template_line
  end

  # POST /template_lines
  def create
    find_template.template_lines.create!(template_line_params)

    redirect_to find_template, notice: 'Template line was successfully created.'
  end

  # PATCH/PUT /template_lines/1
  def update
    if find_template_line.update(template_line_params)
      redirect_to find_template, notice: 'Template line was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /template_lines/1
  def destroy
    find_template_line.destroy!
    redirect_to find_template, notice: 'Template line was successfully destroyed.'
  end

  private
    def find_template_line
      @template_line ||= find_template.template_lines.find(params[:id])
    end

    def find_template
      @template ||= Template.find(params[:template_id])
    end

    # Only allow a trusted parameter "white list" through.
    def template_line_params
      params.require(:template_line).permit(:number, :deleted_line)
    end
end
