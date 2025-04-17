require 'rails_helper'

RSpec.describe Expense, type: :model do
  describe 'expense#create' do 
    context 'With valid params' do
      let(:expense) { create(:expense) }

      it "saves with all valid params" do 
        expect(expense).to be_valid
      end
    end
  
    context 'Missing param' do 
      let(:expense) { create(:expense, :without_title) }

      it 'not saves with missing param title' do 
        expect { expense }.to raise_error(ActiveRecord::RecordInvalid)
      end
  
      it 'not saves without amount' do
        expect { expense }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end 

    context 'Without spent_on' do
      let(:expense) { create(:expense, :without_spent_on) }

      it 'not saves without spent_on' do 
        expect { expense }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
    
    context ':amount' do 
      let(:expense) { create(:expense) }
      let(:invalid_expense) { build(:expense, amount: 'not a number') }

      it 'is a number' do 
        expect(expense.amount).to be_a(Numeric)
      end
  
      it 'not a number' do
        expect(invalid_expense).to_not be_valid
        expect(invalid_expense.errors[:amount]).to include("is not a number")
      end
    end
  end

  describe 'Validations' do 
    context 'Uniqueness' do
      let!(:uniq_expense) { create(:expense, title: 'Uniq title') }
      let(:duplicate_expense) { build(:expense, title: 'Uniq title') }

      it 'does not allow duplicate titles' do 
        expect(duplicate_expense).to_not be_valid
        expect(duplicate_expense.errors[:title]).to include("has already been taken")
      end
    end

    context 'Numericality' do
      let(:expense) { create(:expense) }
      let(:expense_wrong_amount) { build(:expense, amount: 0) }

      it 'greater than 0' do
        expect(expense.amount).to be > 0
      end
  
      it 'returns error if less or equals 0' do 
        expect(expense_wrong_amount).to_not be_valid
        expect(expense_wrong_amount.errors[:amount]).to include("must be greater than 0")
      end
    end

    context 'Length' do 
      let(:expense) { create(:expense) }
      let(:expense_long_title) { build(:expense, title: 'Oh no, i am longer than 16 symbols') }

      it 'is valid when title is not longer than 16 symbols' do
        expect(expense.title.length).to be <= 16
      end
  
      it 'is invalid when title is longer than 16 symbols' do 
        expect(expense_long_title).to_not be_valid
        expect(expense_long_title.errors[:title]).to include("is too long (maximum is 16 characters)")
      end
    end

    context 'Format' do 
      let(:expense) { create(:expense) }
      let(:expense_wrong_format) { build(:expense, spent_on: 'wrong date') }

      it 'is valid with correct format' do 
        expect(expense.spent_on.strftime('%a, %d %b %Y')).to match(/\A[A-Za-z]{3}, \d{2} [A-Za-z]{3} \d{4}\z/)
      end
  
      it 'is invalid with incorrect format' do 
        expect(expense_wrong_format).to_not be_valid
        expect(expense_wrong_format.errors[:spent_on]).to include("can't be blank")
      end
    end

    context 'spent_on_not_in_future' do 
      let(:expense) { create(:expense, spent_on: Date.today) }
      let(:expense_in_future) { build(:expense, spent_on: Date.today + 1) }

      it 'pass when the date is not in the future' do 
        expect(expense).to be_valid
      end
  
      it 'fails when the date is in the future' do 
        expect(expense_in_future).to_not be_valid
        expect(expense_in_future.errors[:spent_on]).to include("cant't be in the future")
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:user) }

    # it 'belongs to user' do
    #   association = described_class.reflect_on_association(:user)
    #   expect(association.macro).to eq :belongs_to
    #   expect(association.class_name).to eq 'User'
    # end  

    context 'creates only with user' do 
      let(:expense) { create(:expense) }
      let(:expense_no_user) { build(:expense, :without_user) }
      
      it 'creates expense with existing user' do
        expect(expense).to be_valid
      end
  
      it 'fails if user not presented' do
        expect(expense_no_user).to_not be_valid
      end
    end
  end
end
