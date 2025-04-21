shared_examples "redirects to login" do |http_method, path_proc|
  it "redirects unauthenticated to login" do
    path = instance_exec(&path_proc)
    public_send(http_method, path)
    expect(response).to redirect_to(login_path)
    follow_redirect!
    expect(response.body).to include("Join us!")
  end
end