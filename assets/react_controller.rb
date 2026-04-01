class ReactController < ApplicationController
  include ActionView::Helpers::AssetUrlHelper
  include ViteRails::TagHelpers

  layout "react"

  def index
    if Rails.env.development?
      redirect_to request.original_url.sub(/:\d+/, ":8080")
    else
      render file: Rails.public_path.join("react/index.html")
    end
  end
end