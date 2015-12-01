require 'spec_helper'

feature 'voting', js: true do
  before do
    s = Statement.create(content: "Is global warming real?")
    Agreement.create(individual: create(:individual), statement: s)
    visit new_path
  end

  scenario "should find an opinion" do
    expect(page).to have_content("Is global warming real?")
  end
  
  scenario "test login" do
    visit "/auth/twitter"
    expect(page).to have_content("Sign Out")
  end

  context "clicking on agree" do
    scenario "should authenticate and vote" do
      first(".vote-icon").click
      click_link "vote-twitter-login"
      expect(page).to have_content("Hector Perez")
    end
  end
end