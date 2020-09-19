class Place < ApplicationRecord
  validates :number, presence: true,
                               uniqueness: true,
                               numericality: {only_integer: true}
  
  validates :name, presence: true, length: { maximum: 10 }
  
  validates :type_of_place, presence: true
end
