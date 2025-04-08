module ConjecturesHelper
  def status_color(status)
    case status
    when "draft"
      "bg-gray-200 text-gray-800"
    when "active"
      "bg-blue-200 text-blue-800"
    when "published"
      "bg-green-200 text-green-800"
    else
      "bg-gray-200 text-gray-800"
    end
  end
end
