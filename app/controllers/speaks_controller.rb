class SpeaksController < ApplicationController
  before_action :set_speak, only: [:show, :edit, :update, :destroy]

  # GET /speaks
  # GET /speaks.json
  def index
    @speaks = Speak.all
  end

  # GET /speaks/1
  # GET /speaks/1.json
  def show
  end

  # GET /speaks/new
  def new
    @speak = Speak.new
  end

  # GET /speaks/1/edit
  def edit
  end

  # POST /speaks
  # POST /speaks.json
  def create
    Speak.new(params).send_unsolicited_response
    render :index
  end

  # PATCH/PUT /speaks/1
  # PATCH/PUT /speaks/1.json
  def update
    respond_to do |format|
      if @speak.update(speak_params)
        format.html { redirect_to @speak, notice: 'Speak was successfully updated.' }
        format.json { render :show, status: :ok, location: @speak }
      else
        format.html { render :edit }
        format.json { render json: @speak.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /speaks/1
  # DELETE /speaks/1.json
  def destroy
    @speak.destroy
    respond_to do |format|
      format.html { redirect_to speaks_url, notice: 'Speak was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_speak
      @speak = Speak.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def speak_params
      params.fetch(:speak, {})
    end
end
