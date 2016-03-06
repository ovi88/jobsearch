class JobsController < ApplicationController
  def index
    @job_name = params[:job_name]
    puts @job_name
  end
end
