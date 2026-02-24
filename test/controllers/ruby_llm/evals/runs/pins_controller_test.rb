require "test_helper"

module RubyLLM::Evals
  class Runs::PinsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @run = ruby_llm_evals_runs(:one)
    end

    test "should pin run" do
      post run_pin_url(@run)
      assert_redirected_to run_url(@run)
      assert @run.reload.pinned?
    end

    test "should unpin run" do
      @run.pin!

      delete run_pin_url(@run)
      assert_redirected_to run_url(@run)
      assert_not @run.reload.pinned?
    end
  end
end
