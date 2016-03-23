class JobsController < ApplicationController

  def index
    @hh_result = HhGet.call(params).result
  end

end
