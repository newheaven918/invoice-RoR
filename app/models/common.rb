class Common < ActiveRecord::Base
  has_many :items, dependent: :delete_all
  belongs_to :customer
  belongs_to :serie

  accepts_nested_attributes_for :items, :reject_if => :all_blank, :allow_destroy => true

  def set_amounts
    self.base_amount = 0
    self.discount_amount = 0
    self.tax_amount = 0

    items.each do |item|
      self.base_amount += item.get_base_amount()
      self.discount_amount += item.get_discount_amount()
      self.tax_amount += item.get_tax_amount()
    end

    self.net_amount = self.base_amount - self.discount_amount
    self.gross_amount = self.net_amount + self.tax_amount
  end

  def set_amounts!
    self.set_amounts()
    self.save()
  end
end
