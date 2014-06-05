class ValidationProxy
  include Hancock::Validations
  attr_accessor :favorite_cake, :legs, :tail, :num_of_feet, :nose_hair_color, :is_mermaid

  validates :favorite_cake, :presence => true
  validates :legs, :presence => true, :unless => :is_mermaid
  validates :tail, :presence => true, :if => :is_mermaid
  validates :num_of_feet, :type => :fixnum, :allow_nil => true
  validates :nose_hair_color, :inclusion_of => [:white, :green]
end