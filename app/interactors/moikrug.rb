class Moikrug
  include Interactor
    require 'open-uri'
    require 'nokogiri'
    URL = 'https://moikrug.ru'

  def call
    moi_result = []
    job_name = context.job_name
    get_uri = open("#{URL}/vacancies?q=#{job_name}").read
    doc = Nokogiri::HTML(get_uri)
    #массив из вакансий
    doc.css('div#jobs_list div.job div.inner').each do |job|
      moi_hash = {}
      moi_hash['name'] = job.at_css('div.info div.title')['title']
      moi_hash['company'] = job.at_css('div.info div.company_name a').inner_text
      salary = job.at_css('div.salary').inner_text.delete('От').delete('до').delete('Д').split(' ')
      if salary.size == 3
        moi_hash['salary_from'] = salary[0]+salary[1]
        moi_hash['salary_currency'] = salary[2]
      elsif salary.size == 5
        moi_hash['salary_from'] = salary[0]+salary[1]
        moi_hash['salary_to'] = salary[2]+salary[3]
        moi_hash['salary_currency'] = salary[4]
      end
      if job.at_css('div.info div.meta span.location a') != nil
        moi_hash['city'] = job.at_css('div.info div.meta span.location a').inner_text
      end
      moi_hash['mode'] = job.at_css('div.info div.meta span.occupation').inner_text
      moi_hash['url'] =  URL + job.at_css('a.job_icon')['href']
      moi_result.push(moi_hash)
    end
    #puts moi_result
    context.result = moi_result
  end
end
