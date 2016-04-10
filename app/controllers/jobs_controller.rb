class JobsController < ApplicationController

  def index
    @hh_result ||= HhGet.call(params).result
    @moikrug_result ||= Moikrug.call(params).result
    @result = @hh_result + @moikrug_result
    company = []
    @result.each do |r|
     company.push r['company']
    end
    repeated = company.select{ |e| company.count(e) > 1 }.uniq
    @result.each do |r|
      if r['company'] == "#{repeated.first}"
        @result.delete(r)
      end
    end
  end

end
