require 'rails_helper'

RSpec.describe Expense, type: :model do
  context 'With valid params' do
    it "saves with all valid params" do 
      expect(FactoryBot.create(:expense)).to be_valid
    end
  end

  context 'Missing param' do 
    it 'not saves with missing param title' do 
      expect { FactoryBot.create(:expense, :without_title) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'not saves without amount' do
      expect { FactoryBot.create(:expense, :without_amount) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'not saves without spent_on' do 
      expect { FactoryBot.create(:expense, :without_spent_on) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context 'Uniqueness' do
    it 'does not allow duplicate titles' do 
      expense = FactoryBot.create(:expense, title: "Uniq title")
      duplicate_expense = FactoryBot.build(:expense, title: "Uniq title")

      expect(duplicate_expense).to_not be_valid
      expect(duplicate_expense.errors[:title]).to include("has already been taken")
    end
  end

  context 'Amount' do 
    it 'is a number' do 
      expect(FactoryBot.create(:expense).amount).to be_a(Numeric)
    end

    it 'not a number' do
      expense = FactoryBot.build(:expense, amount: 'not a number')

      expect(expense).to_not be_valid
      expect(expense.errors[:amount]).to include("is not a number")
    end

    it 'greater than 0' do
      expect(FactoryBot.create(:expense).amount).to be > 0
    end

    it 'returns error if less or equals 0' do 
      expense = FactoryBot.build(:expense, amount: 0)

      expect(expense).to_not be_valid
      expect(expense.errors[:amount]).to include("must be greater than 0")
    end
  end

  context 'Size' do 
    it 'is valid when title is not longer than 16 symbols' do
      expect(FactoryBot.create(:expense).title.length).to be <= 16
    end

    it 'is invalid when title is longer than 16 symbols' do 
      expense = FactoryBot.build(:expense, title: 'Oh no, i am longer than 16 symbols')

      expect(expense).to_not be_valid
      expect(expense.errors[:title]).to include("is too long (maximum is 16 characters)")
    end
  end

  context 'Format' do 
    it 'is valid with correct format' do 
      expect(FactoryBot.create(:expense).spent_on.strftime('%a, %d %b %Y')).to match(/\A[A-Za-z]{3}, \d{2} [A-Za-z]{3} \d{4}\z/)
    end

    it 'is invalid with incorrect format' do 
      expense = FactoryBot.build(:expense, spent_on: 'i am invalid date')

      expect(expense).to_not be_valid
      expect(expense.errors[:spent_on]).to include("can't be blank")
    end
  end

  context 'Custom validation spent_on_not_in_future' do 
    it 'pass when the date is not in the future' do 
      expect(FactoryBot.create(:expense, spent_on: Date.today)).to be_valid
    end

    it 'fails when the date is in the future' do 
      expense = FactoryBot.build(:expense, spent_on: Date.today + 1)

      expect(expense).to_not be_valid
      expect(expense.errors[:spent_on]).to include("cant't be in the future")
    end
  end
end
