class JobsController < ApplicationController

  require 'open-uri'
  require 'dotenv'

  Dotenv.load

  SEARCH_PERIOD = 7
  SEARCH_REGION = 2
  MONDAY = 0
  MORNING_HOUR = 9
  START_ARRAY = 0

  def index
    @job_name = params[:job_name]
    @hh_result = get_data_from_hh
  end

  private

  def get_data_from_hh
    hh_json = get_json("https://api.hh.ru/vacancies?text=#{@job_name}&area=#{SEARCH_REGION}&vacancy_search_fields=name&period=#{SEARCH_PERIOD}")
    hh_array = hh_json['items']
    hh_result = []
    hh_array.each do |h|
      hh_hash = {}
      vacancy = h['name']
      unless vacancy.scan(/(#{@job_name})/i).empty?
        hh_hash['name'] = vacancy
        salary = h['salary']
        unless salary.to_s.empty?
          hh_hash['salary_from'] = check_empty? salary['from']
          hh_hash['salary_to'] = check_empty? salary['to']
          hh_hash['salary_currency'] = check_empty? salary['currency']
        end
        hh_hash['url'] = h['alternate_url']
        hh_dop_url = h['url']
        hh_dop_url_json = get_json(hh_dop_url)
        hh_hash['experience'] = hh_dop_url_json['experience']['name']
        unless hh_dop_url_json.dig('address', 'metro_stations') == nil
          lat = hh_dop_url_json['address']['lat']
          lng = hh_dop_url_json['address']['lng']
          departure_time = next_monday_timestamp
          road_json = get_json("https://maps.googleapis.com/maps/api/distancematrix/json?departure_time=#{departure_time}&traffic_model=pessimistic&origins=#{ENV["HOME_COORDINATE"]}&destinations=#{lat},#{lng}&key=#{ENV["GOOGLE_MAP_KEY"]}")
          unless road_json['rows'][START_ARRAY]['elements'][START_ARRAY]['duration_in_traffic'] == nil
            hh_hash['duration'] = road_json['rows'][START_ARRAY]['elements'][START_ARRAY]['duration_in_traffic']['text']
          end
          unless hh_dop_url_json['address']['metro_stations'][START_ARRAY] == nil
            hh_hash['metro'] = hh_dop_url_json['address']['metro_stations'][START_ARRAY]['station_name']
          end
        end
        hh_hash['key_skills'] = check_empty? hh_dop_url_json['key_skills']
        hh_result.push(hh_hash)
      end
    end
    return hh_result
  end

  def check_empty? value
    unless value.to_s.empty?
      value
    end
  end

  def get_json url
    get_uri = open(url).read
    get_json = JSON.parse(get_uri)
  end

  def next_monday_timestamp
    next_monday = Date.today.next_week.advance(:days=>MONDAY)
    next_monday = next_monday.to_time + MORNING_HOUR.hours
    departure_time = next_monday.to_i
  end

end
