module RubyLLM
  module Evals
    class Runs::PinsController < ApplicationController
      before_action :set_run

      def create
        @run.pin!
        redirect_to run_path(@run), notice: "Run was successfully pinned."
      end

      def destroy
        @run.unpin!
        redirect_to run_path(@run), notice: "Run was successfully unpinned."
      end

      private

      def set_run
        @run = Run.find(params[:run_id])
      end
    end
  end
end
