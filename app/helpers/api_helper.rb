module ApiHelper
  def render_partial_if_exists(json, partial_name, *args)
    if lookup_context.exists?(partial_name, [], true, [], formats: [:json], handlers: [:jbuilder])
      json.partial! partial_name, *args
    else
      logger.debug "attempted to render #{partial_name}, which doesn't exists"
    end
  end
end
