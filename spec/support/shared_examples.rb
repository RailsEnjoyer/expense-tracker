shared_examples "redirects to login" do |http_method, path_proc|
  it "redirects unauthenticated to login" do
    path = instance_exec(&path_proc)
    public_send(http_method, path)
    expect(response).to redirect_to(login_path)
    follow_redirect!
    expect(response.body).to include("Join us!")
  end
end

shared_examples "form with preserved fields" do
  it "re-renders form with preserved fields" do
    expect(page).to have_content("Create new expense")

    expect(page).to have_field('Title', with: expected_title)
    expect(page).to have_field('Amount', with: expected_amount)

    if expected_date.present?
      expect(page).to have_field('Date of spent', with: expected_date)
    else
      expect(page).to have_field('Date of spent')
      expect(find('input[name="expense[spent_on]"]').value).to be_nil
    end
  end
end