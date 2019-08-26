class HoundsController < ApplicationController
  before_action :set_hound, only: [:show, :edit, :update, :destroy]

  # GET /hounds
  # GET /hounds.json
  def index
    @hounds = Hound.all
  end

  # GET /hounds/1
  # GET /hounds/1.json
  def show
  end

  # GET /hounds/new
  def new
    # Place the STT string in the query call
    response = Houndify.new.query("What is the weather in Prosper, TX")
    # Pass the response string to the TTS engine of UneeQ
    puts response 
    @hound = Hound.new
    
  end

  # GET /hounds/1/edit
  def edit
  end

  # POST /hounds
  # POST /hounds.json
  def create
    @hound = Hound.new(hound_params)

    respond_to do |format|
      if @hound.save
        format.html { redirect_to @hound, notice: 'Hound was successfully created.' }
        format.json { render :show, status: :created, location: @hound }
      else
        format.html { render :new }
        format.json { render json: @hound.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /hounds/1
  # PATCH/PUT /hounds/1.json
  def update
    respond_to do |format|
      if @hound.update(hound_params)
        format.html { redirect_to @hound, notice: 'Hound was successfully updated.' }
        format.json { render :show, status: :ok, location: @hound }
      else
        format.html { render :edit }
        format.json { render json: @hound.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hounds/1
  # DELETE /hounds/1.json
  def destroy
    @hound.destroy
    respond_to do |format|
      format.html { redirect_to hounds_url, notice: 'Hound was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hound
      @hound = Hound.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def hound_params
      params.fetch(:hound, {})
    end
end
