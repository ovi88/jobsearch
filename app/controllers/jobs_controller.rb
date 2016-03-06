class JobsController < ApplicationController
  require 'open-uri'
  def index
    @job_name = params[:job_name]
    #puts @job_name
    result_str = open("https://api.hh.ru/vacancies?text=#{@job_name}&area=2&vacancy_search_fields=name&period=7").read
    #puts responce
    result_json = JSON.parse(result_str)
    @result_array = result_json['items']
    #puts result_array[0]

  end
end
