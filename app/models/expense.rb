class Expense < ApplicationRecord
  validates :title, :amount, :spent_on, presence: true
  validates :title, length: { maximum: 16 }
  validate :spent_on_not_in_future
  validates :amount, numericality: { greater_than: 0 }

  private

  def spent_on_not_in_future
    if spent_on > Date.today
      errors.add(:spent_on, "cant't be in the future")
    end
  end
end
