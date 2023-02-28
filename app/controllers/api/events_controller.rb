class Api::EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [:show, :update, :destroy]

  # GET /events
  def index
    user_id = decode_auth_token(request.headers['Authorization'])
    user = User.find(user_id)
    role = "client"

    if user.role == "client"
      return render json: { 
        response: 'as a client you donot have access to the api',
        filtered_for: role }, status: 200
    end

    if user.role == "event_coordinator"
      role = "event_coordinator"
      @events = Event.joins(:users).where(users: { id: user_id }).includes(:client, :space).paginate(page: params[:page], per_page: 10)
    end

    if user.role == "admin"
      role = "admin"
      @events = Event.includes(:client, :space).paginate(page: params[:page], per_page: 10)
    end
    
    if params[:client_id].present?
      @events = @events.where(client_id: params[:client_id])
    end

    if params[:space_id].present? 
      @events = @events.where(space_id: params[:space_id])
    end

    if params[:event_coordinator_id].present? && user.role == "admin"
      event_coordinator_id = params[:event_coordinator_id]
      @events = @events.joins(:users).where(users: { id: event_coordinator_id })
    end

    if params[:on_date].present? 
      start_at = DateTime.parse(params[:on_date])
      @events = @events.where("date(start_at) > ? and date(start_at) < ?", start_at - 1.days, start_at + 1.days)
    end

    render json: {
      response: @events,
      meta: pagination_dict(@events),
      filtered_for: role
    }

  end

  # GET /events/1
  def show
    render json: @event
  end

  # POST /events
  def create
    user_id = decode_auth_token(request.headers['Authorization'])
    user = User.find(user_id)

    @event = Event.new(event_params)
    @event.users << user

    if @event.save
      render json: @event, status: :created, location: @event
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /events/1
  def update
    if @event.update(event_params)
      render json: @event
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy
  end

  FILE_EXT = [".yaml"]
  require_relative '../../services/event_importer'
  def import

    file = params[:file]


    FileUtils::mkdir_p(Rails.root.join("uploads/files"))
  
    ext = File.extname(params[:file].original_filename)

    # valiate the file
    file_validation(ext)

    file_name = "#{SecureRandom.urlsafe_base64}#{ext}"

    path = Rails.root.join("uploads/files/", file_name)
    
    # Save the file to disk
    File.open(path, "wb") {|f| f.write(params[:file].read)}

    # call the importer function and upload the file
    importer = EventImporter.new(path)
    importer.import
  
    render json: { status: 'ok' }
  end

  

  private

    def file_validation(ext)
      raise "Not allowed" unless FILE_EXT.include?(ext)
    end

    def access_file
      if File.exists?(Rails.root.join("public", "uploads", "files", params[:name]))
      send_data File.read(Rails.root.join("public", "uploads", "files", params[:name])), :disposition => "attachment"
      else
      render :nothing => true
      end
    end


    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def event_params
      params.require(:event).permit(:start_at, :end_at, :name, :description, :client_id, :space_id, :file)
    end


    def decode_auth_token(token)
      JWT.decode(token.split(' ').last, 'DEVISE_JWT_SECRET_KEY_IN+ENV', true, algorithm: 'HS256')[0]['sub']
    rescue JWT::DecodeError
      nil
    end

    def pagination_dict(events)
      {
        current_page: events.current_page,
        next_page: events.next_page,
        prev_page: events.previous_page,
        total_pages: events.total_pages,
        total_count: events.total_entries
      }
    end
end
