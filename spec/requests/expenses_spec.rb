require 'rails_helper'

RSpec.describe "Expenses", type: :request do 
  let(:user){ create(:user) }
  let(:expense){ create(:expense, user: user) }
  let(:valid_params){ attributes_for(:expense) }
  let(:invalid_params){ attributes_for(:expense, title: nil) }

  describe "GET /expenses" do
    context "authenticated" do 
      include_context "authenticated" 
      let!(:expenses) { create_list(:expense, 3, user: user) }
      
      it "returns 200 and list of expenses" do 
        get expenses_path

        expect(response).to have_http_status(:ok)

        expenses.each do |expense| 
          expect(response.body).to include(expense.title)
        end
      end
    end

    context "not authenticated" do
      include_examples "redirects to login", :get, proc { expenses_path }
    end
  end

  describe "GET expenses/:id" do 
    context "authenticated" do 
      include_context "authenticated"

      it "returns show page with params" do 
        get expense_path(expense)
        expect(response).to have_http_status(:ok)

        [
          "Expense #{expense.id}",
          expense.title,
          expense.amount.to_s,
          expense.spent_on.to_s
        ].each do |expected_param|
          expect(response.body).to include(expected_param)
        end
      end
    end

    context "not autheticated" do 
      include_examples "redirects to login", :get, proc { expenses_path }
    end
  end

  describe "POST /expenses" do
    context "with valid params" do
      include_context "authenticated" 

      it "creates expense and redirects" do 
        expect { post expenses_path, params: { expense: valid_params } }.to change(user.expenses, :count).by(1)
        expect(response).to redirect_to(expense_path(Expense.last))
      end
    end

    context "with invalid params" do 
      include_context "authenticated" 

      it "not saves and returns 422" do 
        expect { post expenses_path, params: { expense: invalid_params } }.to_not change(Expense, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
        expect(response.body).to include("Create new expense")
      end
    end
  end

  describe "GET #new" do 
    context "authenticated" do
      include_context "authenticated" 

      it "renders form" do
        get new_expense_path

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:new)
        expect(response.body).to include("expense_title")
      end
    end

    context "not authenticated" do 
      include_examples "redirects to login", :get, proc { expenses_path }
    end
  end

  describe "PATCH /expenses/:id" do 
    let!(:old_expense) { create(:expense, user: user, title: "Old title") }
    let(:updated_expense) { { title: "New title", amount: old_expense.amount, spent_on: old_expense.spent_on } }

    context "authenticated" do 
      context "with valid params" do 
        include_context "authenticated"

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

      context "with invalid params" do 
        include_context "authenticated" 
        let!(:expense){ create(:expense, user: user) }

        it "returns 422 and renders :edit" do 
          expect { patch expense_path(expense), params: { expense: invalid_params } }.to_not change(Expense, :count) 
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(:edit)
        end
      end
    end

    context "not authenticated" do 
      include_examples "redirects to login", :patch, proc { expense_path(expense) }
    end
  end

  describe "DELETE /expenses/:id" do 
    context "authenticated" do 
      include_context "authenticated" 
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
    
    context "not authenticated" do 
      include_examples "redirects to login", :delete, proc { expense_path(expense) }
    end
  end
end