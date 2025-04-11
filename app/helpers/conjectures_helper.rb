module ConjecturesHelper
  def status_color(status)
    case status
    when "active"
      "bg-blue-200 text-blue-800"
    when "refuted"
      "bg-red-200 text-red-800"
    else
      "bg-gray-200 text-gray-800"
    end
  end
end
