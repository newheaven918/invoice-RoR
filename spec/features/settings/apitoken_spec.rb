require "rails_helper"

feature "Settings:" do
  background do
    Rails.cache.clear
  end

  scenario "User with no API token can generate one", :js => true, :driver => :webkit do
    visit "/settings/api_token"

    expect(page).to have_content("Use the button below to generate an API token.")
    expect(page).not_to have_css("code.active")

    click_link("Generate token")

    expect(page.current_path).to eql settings_api_token_path
    expect(Settings[:api_token]).not_to be_nil
    expect(page).to have_content("Use this token to authenticate your api requests:")
    expect(find("code.active").text).to eq Settings[:api_token]
  end

  scenario "User with an API token can replace it by a new one", :js => true, :driver => :webkit do
    FactoryGirl.create :token

    visit "/settings/api_token"
    expect(page).to have_content("123token")

    accept_confirm do
      click_link("Generate token")
    end

    expect(page.current_path).to eql settings_api_token_path
    expect(Settings[:api_token]).not_to be_nil
    expect(find("code.active").text).not_to eq "123token"
  end
end
