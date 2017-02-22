require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'active_support/inflector'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @route_params = route_params
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
    #Issuing a redirect consists of two parts, setting the 'Location' field of the response header to the redirect url and setting the response status code to 302
  def redirect_to(url)
    if already_built_response?
      raise "Double Render"
    else
      @res.add_header('Location', url)
      @res.status = 302
      @already_built_response = true
      @session.store_session(@res)
    end
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "Double Render" if already_built_response?
    @res['Content-Type'] = content_type
    @res.write(content)
    @already_built_response = true
    @session.store_session(@res)
  end
  ##render_content(content, content_type). This should set the response object's content_type and body. It should also set an instance variable, @already_built_response, so that it can check that content is not rendered twice.

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content

  def render(template_name)
    filepath = "views/#{self.class.to_s.underscore}/#{template_name}.html.erb"
    file = File.read(filepath)
    template = ERB.new(file).result(binding)
    render_content(template, "text/html")
  end

  # method exposing a `Session` object
  def session

    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    # render(name) unless already_built_response?
  end
end
