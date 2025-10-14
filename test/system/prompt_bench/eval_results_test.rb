require "application_system_test_case"

module PromptBench
  class EvalResultsTest < ApplicationSystemTestCase
    setup do
      @eval_result = prompt_bench_eval_results(:one)
      @prompt = @eval_result.prompt
    end

    test "visiting the index" do
      visit prompt_eval_results_url(@prompt)
      assert_selector "h1", text: "Eval results"
    end

    test "should create eval result" do
      visit prompt_eval_results_url(@prompt)
      click_on "New eval result"

      fill_in "Ended at", with: @eval_result.ended_at
      fill_in "Prompt", with: @eval_result.prompt_id
      fill_in "Started at", with: @eval_result.started_at
      click_on "Create Eval result"

      assert_text "Eval result was successfully created"
      click_on "Back"
    end

    test "should update Eval result" do
      visit prompt_eval_result_url(@prompt, @eval_result)
      click_on "Edit this eval result", match: :first

      fill_in "Ended at", with: @eval_result.ended_at
      fill_in "Prompt", with: @eval_result.prompt_id
      fill_in "Started at", with: @eval_result.started_at
      click_on "Update Eval result"

      assert_text "Eval result was successfully updated"
      click_on "Back"
    end

    test "should destroy Eval result" do
      visit prompt_eval_result_url(@prompt, @eval_result)
      click_on "Destroy this eval result", match: :first

      assert_text "Eval result was successfully destroyed"
    end
  end
end
