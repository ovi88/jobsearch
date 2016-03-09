class JobsController < ApplicationController
  require 'open-uri'
  def index
    @job_name = params[:job_name]
    #puts @job_name
    @hh_result = []
    hh_api = open("https://api.hh.ru/vacancies?text=#{@job_name}&area=2&vacancy_search_fields=name&period=30").read
    #puts responce
    hh_json = JSON.parse(hh_api)
    hh_array = hh_json['items']
    hh_array.each do |h|
      hh_hash = {}
      vacancy = h['name']
      unless vacancy.scan(/(#{@job_name})/i).empty?
        hh_hash['name'] = vacancy
        salary = h['salary']
        unless salary.to_s.empty?
          unless salary['from'].to_s.empty?
            hh_hash['salary_from'] =  salary['from']
          end
          unless salary['to'].to_s.empty?
            hh_hash['salary_to'] = salary['to']
          end
          unless salary['currency'].to_s.empty?
            hh_hash['salary_currency'] = salary['currency']
          end
        end
        hh_hash['url'] = h['alternate_url']
        hh_dop_url = h['url']
        hh_dop_url_result = open(hh_dop_url).read
        hh_dop_url_json = JSON.parse(hh_dop_url_result)
        hh_hash['experience'] = hh_dop_url_json['experience']['name']
        unless hh_dop_url_json.dig('address', 'metro_stations') == nil
          unless hh_dop_url_json['address']['metro_stations'][0] == nil
            hh_hash['metro'] = hh_dop_url_json['address']['metro_stations'][0]['station_name']
          end  
        end
        #hh_hash['description'] = hh_dop_url_json['description']
        unless hh_dop_url_json['key_skills'].empty?
            hh_hash['key_skills'] = hh_dop_url_json['key_skills']
        end
        #unless hh_dop_url_json['key_skills'].to_s.empty?
        #  hh_hash['key_skills'] = hh_dop_url_json['key_skills']
        #end
        @hh_result.push (hh_hash)
      end
    #puts @hh_result
    end
    #puts result_array[0]

  end
end
