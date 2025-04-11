module ConjecturesHelper
  def status_color(status, refutation_count = nil)
    case status
    when "active"
      if refutation_count.nil? || refutation_count == 0
        "bg-gray-200 text-gray-800"
      else
        "bg-blue-200 text-blue-800"
      end
    when "refuted"
      "bg-red-200 text-red-800"
    else
      "bg-gray-200 text-gray-800"
    end
  end
end
