class Avatar < ActiveRecord::Base
  belongs_to :user

  has_attachment :content_type => :image,
      :storage => :file_system,
      :max_size => 500.kilobytes,
      :resize_to => '384x256>' ,
      :thumbnails => {
        :large => '100x100>' ,
        :small => '50x50>'
      }

  validates_attachment  :size => I18n.t("filesize_exceeded"), 
                        :content_type => I18n.t("image_type_wrong") 
                       
 end
