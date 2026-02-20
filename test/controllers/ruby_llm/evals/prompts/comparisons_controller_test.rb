require "test_helper"

module RubyLLM
  module Evals
    module Prompts
      class ComparisonsControllerTest < ActionDispatch::IntegrationTest
        include Engine.routes.url_helpers

        setup do
          @routes = Engine.routes
          @prompt = ruby_llm_evals_prompts(:one)
        end

        test "should get show" do
          get prompt_comparison_url(@prompt)
          assert_response :success
        end
      end
    end
  end
end
