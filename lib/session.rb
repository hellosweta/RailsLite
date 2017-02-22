require 'json'
require 'byebug'
class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    @req = req

    if @req.cookies.keys.include?("_rails_lite_app")
      @cookie_hash = JSON.parse(@req.cookies["_rails_lite_app"])
    else
      @cookie_hash = {}
    end

  end

  def [](key)
    @cookie_hash[key]
  end

  def []=(key, val)
    @cookie_hash[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    @session_cookie = @cookie_hash.to_json
    res.set_cookie("_rails_lite_app", { path: "/", value: @session_cookie})
  end
end
