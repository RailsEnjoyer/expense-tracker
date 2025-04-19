require 'rails_helper'

RSpec.describe "Expenses", type: :request do 
  let(:user){ create(:user) }
  let(:expense){ create(:expense, user: user) }
  let(:valid_params){ attributes_for(:expense) }
  let(:invalid_params){ attributes_for(:expense, title: nil) }

  before do 
    post login_path, params: { email: user.email, password: user.password }
  end

  describe "GET /expenses" do 
    let!(:expenses) { create_list(:expense, 3, user: user) }
    
    it "returns 200 and list of expenses" do 
      get expenses_path

      expect(response).to have_http_status(:ok)

      expenses.each do |expense| 
        expect(response.body).to include(expense.title)
      end
    end
  end

  describe "POST /expenses" do
    context "with valid params" do
      it "creates expense and redirects" do 
        expect { post expenses_path, params: { expense: valid_params } }.to change(user.expenses, :count).by(1)
        expect(response).to redirect_to(expense_path(Expense.last))
      end
    end

    context "with invalid params" do 
      it "not saves and returns 422" do 
        expect { post expenses_path, params: { expense: invalid_params } }.to_not change(Expense, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
        expect(response.body).to include("Create new expense")
      end
    end
  end

  describe "GET #new" do 
    it "renders form" do
      get new_expense_path

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
      expect(response.body).to include("expense_title")
    end
  end

  describe "PATCH /expenses/:id" do 
    let!(:old_expense) { create(:expense, user: user, title: "Old title") }
    let(:updated_expense) { { title: "New title", amount: old_expense.amount, spent_on: old_expense.spent_on } }

    it "renders form" do 
      get edit_expense_path(expense)

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:edit)
      expect(response.body).to include("expense_title")
    end

    it "updates expense" do 
      expect { 
        patch expense_path(old_expense), params: { expense: updated_expense }
        old_expense.reload 
      }.to change{ old_expense.title }.from("Old title").to("New title")

      expect(response).to redirect_to(expense_path(old_expense))
    end
  end

  describe "DELETE /expenses/:id" do 
    before { delete expense_path(expense) }
    
    it "redirects with 302" do 
      expect(response).to have_http_status(:found)
    end

    it "redirects to root path" do
      expect(response).to redirect_to(root_path)
    end

    context "after redirect" do 
      before { follow_redirect! }

      it "returns 200 in root path" do
        expect(response).to have_http_status(:ok)
      end

      it "removes the expense from the list" do 
        expect(response.body).to_not include(expense.title)
      end
    end
  end

  # TODO: not logged user trying to access controllers, tests for show and edit, render to :edit in PATCH
end