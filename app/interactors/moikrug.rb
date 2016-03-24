class Moikrug
  include Interactor
    require 'open-uri'
    require 'nokogiri'
  def call
    get_uri = open("https://api.moikrug.ru/vacancies?q=ruby").read
    doc = Nokogiri::HTML(get_uri)
    #массив из вакансий
    doc.css('div#jobs_list div.job')
    #массив с именами вакансий
    # doc.css('div#jobs_list div.job div.inner div.info div.title')
  end
end
