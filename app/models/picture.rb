class Picture < ActiveRecord::Base
  attr_accessible :description, :gallery_id, :image, :crop_x, :crop_y, :crop_w, :crop_h
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  belongs_to :gallery
  
  mount_uploader :image, ImageUploader

  after_update :reprocess_image, :if => :cropping?

  def to_jq_upload
    {
      "name" => read_attribute(:image),
      "size" => image.size,
      "url" => image.url,
      "thumbnail_url" => image.thumb.url,
      "delete_url" => id,
      "picture_id" => id,
      "delete_type" => "DELETE"
    }
  end

  def cropping?
      !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def reprocess_image
    #current_image = Magick::ImageList.new(self.image.current_path)
    #cropped_image = current_image.crop(crop_x, crop_y, crop_h, crop_w)
    #cropped_image.write(self.image.current_path)
    #self.image.recreate_versions!

    image.recreate_versions!
    current_version = self.image.current_path
    large_version = "#{Rails.root}/public" + self.image.versions[:large].to_s

    FileUtils.rm(current_version)
    FileUtils.cp(large_version, current_version)
  end
end
