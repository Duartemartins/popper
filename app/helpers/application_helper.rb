module ApplicationHelper
  def meta_title
    content_for?(:meta_title) ? content_for(:meta_title) : "Popper - Conjectures and Refutations"
  end

  def meta_description
    content_for?(:meta_description) ? content_for(:meta_description) : "Popper is a platform for creating and challenging falsifiable conjectures with bounties for successful refutations."
  end

  def meta_image
    content_for?(:meta_image) ? content_for(:meta_image) : image_url("metaimage.jpeg")
  end

  def canonical_url
    content_for?(:canonical_url) ? content_for(:canonical_url) : request.original_url
  end
  def meta_image_url(options = {})
    defaults = {
      title: "Popper",
      subtitle: "Conjectures and Refutations",
      type: "default"
    }

    options = defaults.merge(options)

    # Use the meta_image_controller URL with parameters
    meta_image_url = url_for(
      controller: "meta_images",
      action: "show",
      title: options[:title],
      subtitle: options[:subtitle],
      type: options[:type],
      only_path: false
    )

    # For a production system, you would want to cache and pre-render these images
    # For now, we'll return the dynamic URL
    meta_image_url
  end
end
