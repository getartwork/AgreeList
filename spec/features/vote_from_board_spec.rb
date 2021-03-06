require 'spec_helper'

feature 'voting', js: true do
  attr_reader :statement

  before do
    seed_data
  end

  context 'logged user' do
    before do
      login
      visit brexit_board_path
    end

    scenario "agree" do
      expect{
        click_link("Agree")
      }.to change{Agreement.count}.by(1)
      click_button "Save"
      expect(page).to have_content("Yes, I agree (100% of 2 opinions)")
    end

    scenario "disagree" do
      expect{
        click_link("Disagree")
      }.to change{Agreement.count}.by(1)
      click_button "Save"
      expect(page).to have_content("No, I disagree (50% of 2 opinions)")
    end

    scenario 'add someone who disagrees' do
      fill_in 'name', with: 'Hector Perez'

      click_button "She/he disagree"
      expect(Agreement.last.disagree?).to eq(true)
    end

    scenario 'should create two users when adding someone else' do
      fill_in 'name', with: 'Hector Perez'
      fill_in 'source', with: 'http://...'

      expect{ click_button "She/he agrees" }.to change{ Individual.count }.by(1)
    end

    scenario 'add someone who disagrees with its twitter' do
      fill_in 'name', with: "@arpahector"
      click_button "She/he disagree"
      expect(Individual.last.twitter).to eq "arpahector"
    end

    scenario 'add two times the same @user' do
      fill_in 'name', with: "@arpahector"
      click_button "She/he agrees"
      fill_in 'name', with: "@arpahector"
      click_button "She/he agrees"
      expect(Individual.all.order(:twitter).map(&:twitter)).to eq %w(arpahector seed)
    end
  end

  context 'non logged user' do
    before do
      visit brexit_board_path
    end

    scenario "agree" do
      expect{
        click_link("Agree")
        click_link "vote-twitter-login"
      }.to change{Agreement.count}.by(1)
      click_button "Save"
      expect(page).to have_content("Yes, I agree (100% of 2 opinions)")
    end

    scenario "disagree" do
      expect{
        click_link("Disagree")
        click_link "vote-twitter-login"
      }.to change{Agreement.count}.by(1)
      click_button "Save"
      expect(page).to have_content("No, I disagree (50% of 2 opinions)")
    end

    scenario 'add someone who disagrees' do
      fill_in 'name', with: 'Hector Perez'

      click_button "She/he disagree"
      expect(Agreement.last.disagree?).to eq(true)
    end

    scenario 'should create two users when adding someone else' do
      fill_in 'name', with: 'Hector Perez'
      fill_in 'source', with: 'http://...'
      fill_in 'email', with: 'hhh@jjj.com'

      expect{ click_button "She/he agrees" }.to change{ Individual.count }.by(2)
    end

    scenario 'should set added_by_id' do
      fill_in 'name', with: 'Hector Perez'
      fill_in 'source', with: 'http://...'
      fill_in 'email', with: 'hhh@jjj.com'

      click_button "She/he agrees"
      expect(Agreement.last.added_by_id).to eq Individual.find_by_email("hhh@jjj.com").id
    end

    scenario 'should not create another user if the email exists - add supporter' do
      fill_in 'name', with: 'Hector Perez'
      fill_in 'source', with: 'http://...'
      fill_in 'email', with: 'same@jjj.com'

      expect{ click_button "She/he agrees" }.to change{ Individual.count }.by(2)

      fill_in 'name', with: 'Other user'
      fill_in 'source', with: 'http://...'
      fill_in 'email', with: 'same@jjj.com'

      expect{ click_button "She/he agrees" }.to change{ Individual.count }.by(1)
      agreements = Individual.find_by_email("same@jjj.com").agreements_added_from_others
      expect(agreements.size).to eq 2
      expect(agreements.map{|a| a.added_by_id}).to eq [Individual.find_by_email("same@jjj.com").id] * 2
    end

    scenario 'add someone who disagrees with its twitter' do
      fill_in 'name', with: "@arpahector"
      click_button "She/he disagree"
      expect(Individual.last.twitter).to eq "arpahector"
    end

    scenario 'add two times the same @user' do
      fill_in 'name', with: "@arpahector"
      click_button "She/he agrees"
      fill_in 'name', with: "@arpahector"
      click_button "She/he agrees"
      expect(Individual.all.order(:twitter).map(&:twitter)).to eq %w(arpahector seed)
    end
  end

  private

  def seed_data
    @statement = create(:statement)
    create(:agreement, statement: @statement, individual: create(:individual, twitter: "seed"), extent: 100)
  end

  def login
    visit "/auth/twitter"
  end
end

