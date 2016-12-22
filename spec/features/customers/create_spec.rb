require "rails_helper"

feature "Customers:" do

  scenario "User can create a customer", :js => true, :driver => :webkit do
    visit "/customers/new"

    fill_in "Name", with: "Test Customer"

    click_on "Save"

    expect(page.current_path).to eql customers_path
    expect(page).to have_content("Customer was successfully created.")
    expect(page).to have_content("Test Customer")
  end

  scenario "User can't create a customer without name nor identification", :js => true, :driver => :webkit do
    visit "/customers/new"
    click_on "Save"

    expect(page.current_path).to eql customers_path
    expect(page).to have_content("1 error prohibited this customer from being saved:")
    expect(page).to have_content("Name or identification is required.")
  end

end
