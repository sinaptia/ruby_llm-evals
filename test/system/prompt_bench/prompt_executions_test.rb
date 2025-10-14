require "application_system_test_case"

module PromptBench
  class PromptExecutionsTest < ApplicationSystemTestCase
    setup do
      @prompt_execution = prompt_bench_prompt_executions(:one)
    end

    test "visiting the index" do
      visit prompt_executions_url
      assert_selector "h1", text: "Prompt executions"
    end

    test "should create prompt execution" do
      visit prompt_executions_url
      click_on "New prompt execution"

      click_on "Create Prompt execution"

      assert_text "Prompt execution was successfully created"
      click_on "Back"
    end

    test "should update Prompt execution" do
      visit prompt_execution_url(@prompt_execution)
      click_on "Edit this prompt execution", match: :first

      click_on "Update Prompt execution"

      assert_text "Prompt execution was successfully updated"
      click_on "Back"
    end

    test "should destroy Prompt execution" do
      visit prompt_execution_url(@prompt_execution)
      click_on "Destroy this prompt execution", match: :first

      assert_text "Prompt execution was successfully destroyed"
    end
  end
end
