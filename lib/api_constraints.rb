# http://andrewberls.com/blog/post/api-versioning-with-rails-4
class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    @default || req.headers['Accept'].include?("application/vnd.om.v#{@version}")
  end
end
