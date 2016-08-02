class InspectionsController < ApplicationController
  before_action :set_inspection, only: [:show, :edit, :update, :destroy]
  before_action :allow_iframing, only: [:confirmation, :new]

  def print
    @inspections = Inspection.where("date_trunc('day', requested_for_date) = ?", params[:date])
    render layout: 'print'
  end

  def show
  end

  def confirmation
    @inspections = Inspection.where(id: params[:inspection_ids].split(',')) # 1,2 => [1,2]

    if params[:express] == 'true'
      render :confirmation_express
    else
      render :confirmation
    end
  end

  # GET /inspections/new
  def new
    @inspection = Inspection.new
    @inspection.build_address
  end

  def new_express
    @inspection = Inspection.new
    @inspection.build_address
  end

  # POST /inspections
  def create
    # create one Inspection for each `inspection_type_id` submitted
    form = InspectionForm.new(inspection_params)

    if form.save
      if URI(request.referer).path == '/inspections/new_express'
        redirect_to inspections_confirmation_path(inspection_ids: form.inspections.map(&:id).join(','), express: true), notice: 'Inspection was successfully created.'
      else
        redirect_to inspections_confirmation_path(inspection_ids: form.inspections.map(&:id).join(',')), notice: 'Inspection was successfully created.'
      end
    else
      render :new
    end
  end

  # GET /inspections/1/edit
  def edit
  end

  # PATCH/PUT /inspections/1
  def update
    if @inspection.update(inspection_params)
      redirect_to @inspection, notice: 'Inspection was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /inspections/1
  def destroy
    @inspection.destroy
    redirect_to :back, notice: 'Inspection was successfully destroyed.'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_inspection
    @inspection = Inspection.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def inspection_params
    params.require(:inspection).permit(
      :id,
      :permit_number,
      :contact_name,
      :contact_phone,
      :contact_phone_can_text,
      :contact_email,
      :inspection_type_id,
      :inspection_notes,
      :requested_for_date,
      :requested_for_time,
      :address_notes,
      address_attributes: [:street_number, :route, :city, :state, :zip]
    ).tap do |whitelisted|
      whitelisted[:requested_for_date] = Date.strptime(params['inspection']['requested_for_date'], '%m/%d/%Y')
    end
  end

  def allow_iframing
    response.headers.delete 'X-Frame-Options'
  end
end
