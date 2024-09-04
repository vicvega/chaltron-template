module Chaltron
  class Login < ApplicationRecord
    belongs_to :user

    validates :ip_address, presence: true
    validates :device_id, presence: true, uniqueness: true
  end
end
