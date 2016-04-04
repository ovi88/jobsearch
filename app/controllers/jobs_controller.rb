class JobsController < ApplicationController

  def index
    @hh_result = HhGet.call(params).result
    @moikrug_result = Moikrug.call(params).result
    @result = @hh_result + @moikrug_result
  end

end
