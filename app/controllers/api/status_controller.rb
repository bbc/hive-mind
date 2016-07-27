class Api::StatusController < ApplicationController

  # System status endpoint used by monitoring
  def show
    head :ok
  end
end