module Api::V1
  class SystemsController < ApiController

    # GET /v1/systems
    def index
      respond_to do |format|
        format.csv  { render text: System.all.to_csv }
        format.json { render json: System.all.to_json }
        format.xml { render xml: System.all.to_xml }
      end
    end

  end
end