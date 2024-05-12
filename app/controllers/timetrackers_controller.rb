class TimetrackersController < ApplicationController
  before_action :set_timetracker, only: %i[ show update destroy ]

  # GET /timetrackers
  def index
    @timetrackers = Timetracker.all

    render json: @timetrackers
  end

  # GET /timetrackers/1

  def details
    request_body = request.body.read
    # Parse the JSON request body if needed
    data = JSON.parse(request_body)

    # Get the email field from the parsed data
    email = data["email"]

    # Find the user by email
    user = User.find_by(email: email)

    if user.nil?
      # Handle the case where the user with the provided email is not found
      Rails.logger.error "User not found for email: #{email}"
    else
      # Get the user ID
      user_id = user.id
      Rails.logger.info "User found. user_id: #{user_id}"
       # Iterate over each entry in the data array
       data.each do |key, entries|
        # Skip the "email" key
        next if key == "email"

        # Iterate over each entry in the array
        entries.each do |entry|
          url = entry["url"]
          Rails.logger.info "url: #{url}"
          tracked_seconds = entry["trackedSeconds"]
          minutes = tracked_seconds / 60.0 # Convert trackedSeconds to minutes

          # Check if there is existing data for the current user and domain
          tracker = Timetracker.find_by(user_id: user_id, domain: url)
          if tracker.nil?
            # If no existing data, create a new record
            Timetracker.create(user_id: user_id, domain: url, tracked_minute: minutes, tracked_seconds: tracked_seconds)
          else
            # If existing data, update the record by adding the new minutes and trackedSeconds to the existing ones
            tracker.update(tracked_minute: tracker.tracked_minute + minutes, tracked_seconds: tracker.tracked_seconds + tracked_seconds)
          end
        end
      end
    end
  end
  

  def user_web_details
    # Get the email from the query parameters
    email = params[:email]
  
    # Find the user by email
    user = User.find_by(email: email)
  
    if user.nil?
      # Handle the case where the user with the provided email is not found
      render json: { error: "User not found for email: #{email}" }, status: :not_found
    else
      # Get the user ID
      user_id = user.id
      Rails.logger.info "User found. user_id: #{user_id}"
  
      # Find all tracking data associated with the user ID
      user_tracks = Timetracker.where(user_id: user_id)
  
      if user_tracks.empty?
        render json: { error: "No tracking data found for user with email: #{email}" }, status: :not_found
      else
        # Create a new array to store user details
        user_details = []
  
        # Loop over each track and extract details
        user_tracks.each do |track|
          user_details << {
            track_id: track.id,
            domain: track.domain,
            tracked_minutes: track.tracked_minute,
            tracked_seconds: track.tracked_seconds
          }
        end
  
        # Return the new array as the response body
        render json: user_details, status: :ok
      end
    end
  end

  # POST /timetrackers
  def create
    @timetracker = Timetracker.new(timetracker_params)

    if @timetracker.save
      render json: @timetracker, status: :created, location: @timetracker
    else
      render json: @timetracker.errors, status: :unprocessable_entity
    end
  end

  def show
    render json: @timetracker
  end

  # PATCH/PUT /timetrackers/1
  def update
    if @timetracker.update(timetracker_params)
      render json: @timetracker
    else
      render json: @timetracker.errors, status: :unprocessable_entity
    end
  end

  # DELETE /timetrackers/1
  def destroy
    @timetracker.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_timetracker
      @timetracker = Timetracker.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def timetracker_params
      params.require(:timetracker).permit(:user_id, :domain, :tracked_minute, :tracked_seconds)
    end
end
