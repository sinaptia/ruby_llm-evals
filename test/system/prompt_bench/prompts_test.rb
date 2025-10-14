require "application_system_test_case"

module PromptBench
  class PromptsTest < ApplicationSystemTestCase
    setup do
      @prompt = prompt_bench_prompts(:one)
    end

    test "visiting the index" do
      visit prompts_url
      assert_selector "h1", text: "Prompts"
    end

    test "should create prompt" do
      visit prompts_url
      click_on "New prompt"

      fill_in "Instructions", with: @prompt.instructions
      fill_in "Message", with: @prompt.message
      fill_in "Model", with: @prompt.model
      fill_in "Name", with: @prompt.name
      fill_in "Provider", with: @prompt.provider
      fill_in "Slug", with: @prompt.slug
      click_on "Create Prompt"

      assert_text "Prompt was successfully created"
      click_on "Back"
    end

    test "should update Prompt" do
      visit prompt_url(@prompt)
      click_on "Edit this prompt", match: :first

      fill_in "Instructions", with: @prompt.instructions
      fill_in "Message", with: @prompt.message
      fill_in "Model", with: @prompt.model
      fill_in "Name", with: @prompt.name
      fill_in "Provider", with: @prompt.provider
      fill_in "Slug", with: @prompt.slug
      click_on "Update Prompt"

      assert_text "Prompt was successfully updated"
      click_on "Back"
    end

    test "should destroy Prompt" do
      visit prompt_url(@prompt)
      click_on "Destroy this prompt", match: :first

      assert_text "Prompt was successfully destroyed"
    end
  end
end
