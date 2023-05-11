class Prototype < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  varidates :title,      presence: true
  varidates :catch_copy, presence: true
  varidates :concept,    presence: true
  varidates :image,      presence: true
end
