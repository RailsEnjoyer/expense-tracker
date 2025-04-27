require 'rails_helper'

RSpec.describe "Expenses", type: :system do 
  let!(:user) { create(:user) }
  let!(:expense){ create(:expense, user: user) }

  def sign_in_as(user)
    visit login_path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"
  end

  before do
    driven_by(:rack_test)
  end

  context "not logged user" do 
    it "index redirects to login" do 
      visit expenses_path
      expect(page).to have_content("Join us!")
    end

    it "create redirects to login" do 
      visit new_expense_path
      expect(page).to have_content("Join us!")
    end

    it "update redirects to login" do 
      visit edit_expense_path(expense)
      expect(page).to have_content("Join us!")
    end

    it "show redirects to login" do 
      visit expense_path(expense)
      expect(page).to have_content("Join us!")
    end
  end

  context "CRUD operations" do 
    before do
      sign_in_as(user)
    end

    it "creates new expense" do 
      visit new_expense_path

      fill_in "Title", with: "Coffee"
      fill_in "Amount", with: "5"
      fill_in "Date of spent", with: "25.06.2024"
      click_button "Save"

      expect(page).to have_content("Coffee")
      expect(page).to have_content("5")
      expect(page).to have_content("2024-06-25")
    end

    it "has content on expense page" do 
      visit expense_path(expense)

      expect(page).to have_content("Expense #{expense.id}")
      expect(page).to have_content(expense.title)
      expect(page).to have_content(expense.amount)
      expect(page).to have_content(expense.spent_on)

      expect(page).to have_button("Delete")
      expect(page).to have_link("Update")
      expect(page).to have_link("Back")
    end

    it "has updated content" do 
      visit edit_expense_path(expense)

      expect(page).to have_content("Edit expense")

      fill_in "Title", with: "Pizza"
      fill_in "Amount", with: "1"
      fill_in "Date of spent", with: "24.04.2025"
      click_button "Save"

      expect(page).to have_content("Expense #{expense.id}")
      expect(page).to have_content("Pizza")
      expect(page).to have_content("1")
      expect(page).to have_content("2025-04-24")
    end

    it "deletes expense" do 
      visit expense_path(expense)

      expect(page).to have_button("Delete")
      click_button "Delete"

      expect(page).to have_content("All expenses")
      expect(page).to_not have_content(expense.title)
    end
  end

  context "validations" do 
    let!(:existing_expense) do
      create(:expense, user: user, title: "Bread", amount: 1, spent_on: Date.today)
    end

    before do
      sign_in_as(user)
      visit new_expense_path

      fill_in "Title", with: filled_title
      fill_in "Amount", with: filled_amount
      fill_in "Date of spent", with: filled_date
      click_button "Save"
    end

    context "when title is missing" do 
      let(:filled_title) { "" }
      let(:filled_amount) { "100" }
      let(:filled_date) { "24.04.2025" }

      let(:expected_title) { "" }
      let(:expected_amount) { "100" }
      let(:expected_date) { "2025-04-24" }

      include_examples "form with preserved fields"
    end

    context "when amount is missing" do 
      let(:filled_title) { "Pizza" }
      let(:filled_amount) { "" }
      let(:filled_date) { "24.04.2025" }

      let(:expected_title) { "Pizza" }
      let(:expected_amount) { "" }
      let(:expected_date) { "2025-04-24" }

      include_examples "form with preserved fields"
    end

    context "when spen_on is missing" do 
      let(:filled_title) { "Pizza" }
      let(:filled_amount) { "1" }
      let(:filled_date) { "" }

      let(:expected_title) { "Pizza" }
      let(:expected_amount) { "1" }
      let(:expected_date) { nil }
    end

    context "when title < 16 symbols" do 
      let(:filled_title) { "Pizzzzzzzzzzzzzzzzzzzzzza" }
      let(:filled_amount) { "1" }
      let(:filled_date) { "24.04.2025" }

      let(:expected_title) { "Pizzzzzzzzzzzzzzzzzzzzzza" }
      let(:expected_amount) { "1" }
      let(:expected_date) { "2025-04-24" }

      include_examples "form with preserved fields"
    end

    context "when spent_on is in the future" do 
      let(:filled_title) { "Pizza" }
      let(:filled_amount) { "1" }
      let(:filled_date) { Date.today + 1 }

      let(:expected_title) { "Pizza" }
      let(:expected_amount) { "1" }
      let(:expected_date) { Date.today + 1 }

      include_examples "form with preserved fields"
    end

    context "when amount is not greater than 0" do 
      let(:filled_title) { "Pizza" }
      let(:filled_amount) { "-1" }
      let(:filled_date) { "24.04.2025" }

      let(:expected_title) { "Pizza" }
      let(:expected_amount) { "-1" }
      let(:expected_date) { "2025-04-24" }

      include_examples "form with preserved fields"
    end

    context "when title is not unique" do
      let(:filled_title) { existing_expense.title }
      let(:filled_amount) { "1" }
      let(:filled_date) { "24.04.2025" }

      let(:expected_title) { existing_expense.title }
      let(:expected_amount) { "1" }
      let(:expected_date) { "2025-04-24" }

      include_examples "form with preserved fields" 
    end
  end
end
