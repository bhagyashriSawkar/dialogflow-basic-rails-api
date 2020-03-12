# frozen_string_literal: true

class ManageBotController < ApplicationController
  # TODO: Add your dialogflow project credentials to the credentials.yml file
  DIALOGFLOW_PROJECT_ID = Rails.application.credentials.dialogflow[:project_id]
  DIALOGFLOW_CLIENT_EMAIL = Rails.application.credentials.dialogflow[:client_email]
  DIALOGFLOW_PRIVATE_KEY = Rails.application.credentials.dialogflow[:private_key]

  def initialize
    @config = {
      "credentials": {
        "private_key": DIALOGFLOW_PRIVATE_KEY,
        "client_email": DIALOGFLOW_CLIENT_EMAIL
      }
    }
  end

  def query
    session_id = request.headers['session-id']
    response = detect_intent_texts session_id: session_id,
                                   text: params[:text],
                                   language_code: 'en-US'

    render json: { bot_response: response }
  end

  def detect_intent_texts(session_id:, text:, language_code:)
    session_client = Google::Cloud::Dialogflow::Sessions.new(@config)
    session = session_client.class.session_path DIALOGFLOW_PROJECT_ID, session_id

    query_input = { text: { text: text, language_code: language_code } }
    response = session_client.detect_intent session, query_input
    query_result = response.query_result
    query_result.fulfillment_text
  end
end
