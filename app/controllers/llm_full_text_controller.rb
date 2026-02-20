# frozen_string_literal: true

class LLMFullTextController < ApplicationController
  def index
    content = LLMFullText.generate

    render plain: content, content_type: "text/plain"
  end
end
