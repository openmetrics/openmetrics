module Api::V1
  class ServicesController < ApiController

    # GET /v1/services
    def index
      respond_to do |format|
        format.csv  { render text: System.all.to_csv }
        format.json { render json: System.all.to_json }
        format.xml { render xml: System.all.to_xml }
      end
    end

  end
end
