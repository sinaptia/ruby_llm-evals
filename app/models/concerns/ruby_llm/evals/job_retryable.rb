module RubyLLM
  module Evals
    module JobRetryable
      extend ActiveSupport::Concern

      def retry_job
        queue_adapter_name = ActiveJob::Base.queue_adapter_name
        meth = :"retry_#{queue_adapter_name}_job"

        if respond_to?(meth, true)
          send(meth)
        else
          raise "Retry not supported for #{queue_adapter_name}"
        end
      end

      private

      def retry_delayed_job_job
        job = Delayed::Job.where("handler LIKE ?", "%job_id: #{active_job_id}%").first
        raise "Job not found in queue" if job.blank?
        job.update!(attempts: 0, locked_at: nil, locked_by: nil, run_at: Time.current, failed_at: nil)
      end

      def retry_good_job_job
        job = GoodJob::Job.find_by(active_job_id: active_job_id)
        raise "Job not found in queue" if job.blank?
        job.retry_job
      end

      def retry_sidekiq_job
        require "sidekiq/api"

        job = [ Sidekiq::RetrySet.new, Sidekiq::DeadSet.new, Sidekiq::ScheduledSet.new ].map do |set|
          set.find { |j| j.args.first.is_a?(Hash) && j.args.first["job_id"] == active_job_id }
        end.compact.first

        raise "Job not found in queue" if job.blank?
        job.retry
      end

      def retry_solid_queue_job
        job = SolidQueue::Job.find_by(active_job_id: active_job_id)
        raise "Job not found in queue" if job.blank?
        job.retry
      end
    end
  end
end
