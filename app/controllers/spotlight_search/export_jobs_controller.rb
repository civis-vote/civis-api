module SpotlightSearch
  class ExportJobsController < ApplicationController
    def export_job
      begin
        klass = params[:klass].constantize
        if klass.validate(params[:columns])
          ExportJob.perform_later(params[:email], klass.to_s, params[:columns], params[:filters])
          flash[:success] = 'Successfully queued for export'
        else
          flash[:error] = 'Invalid columns found'
        end
      rescue
        flash[:error] = 'No records to import'
      ensure
        redirect_back fallback_location: root_path
      end
    end
  end
end
