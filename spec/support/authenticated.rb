RSpec.shared_context "authenticated" do
  before do 
    post login_path, params: { email: user.email, password: user.password }
  end
end
