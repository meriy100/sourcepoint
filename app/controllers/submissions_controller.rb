class SubmissionsController < ApplicationController
  def new
    @submission = Submission.new(submitted: Time.zone.now)
  end
end
