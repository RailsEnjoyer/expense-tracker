require 'rails_helper'

RSpec.describe "Expenses", type: :request do 
  let(:user){ create(:user) }
  let(:valid_params){ attributes_for(:expense) }
  let(:invalid_params){ attributes_for(:expense, title: nil) }

  before do 
    post login_path, params: { email: user.email, password: user.password }
  end

  describe "GET /expenses" do 
    let!(:expenses) { create_list(:expense, 3, user: user) }
    #TODO complete test logic
  end
end