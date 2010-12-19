module Resque # :nodoc:
  module Plugins # :nodoc:
    # If you want to give your jobs a second chance (or more)
    # extend them with this plugin and let the job fail
    # some times before considering it failed.
    #
    # By default a job will be run 3 times before marking it
    # as failed, but you can configure that with @insist = N
    # in your job.
    #
    # Example:
    #
    #   require 'resque/plugins/insist'
    #   class HardJob
    #     extend Resque::Plugins::Insist
    #     @queue = :hard_job
    #     @insist = 5
    #     def self.perform(something)
    #       do_work
    #     end
    #   end
    #
    # When your job fails for the first time, it will be queued
    # again, but will be locked for 8 seconds before the worker
    # performs it again. If it fails again, the wait time will be
    # 16 seconds, then 32, 64, ... until your job reaches the
    # maximum number of attempts or just succeeds (not raising an
    # exception).
    module Insist
      include Resque::Helpers
      # Intercept the execution of a job to add the extra security
      # layer.
      def around_perform_insist(*args)
        if redis.get "plugin:insist:wait:#{insist_key(args)}"
          Resque.enqueue constantize(self.to_s), *args
        else
          begin
            yield
            redis.del "plugin:insist:attempts:#{insist_key(args)}"
          rescue => e
            attempts = redis.incr "plugin:insist:attempts:#{insist_key(args)}"
            if attempts.to_i >= insist_times
              redis.del "plugin:insist:wait:#{insist_key(args)}"
              redis.del "plugin:insist:attempts:#{insist_key(args)}"
              raise e
            else
              redis.set "plugin:insist:wait:#{insist_key(args)}", 1
              redis.expire "plugin:insist:wait:#{insist_key(args)}", wait_time(attempts)
              Resque.enqueue constantize(self.to_s), *args
            end
          end
        end
      end

      # Number of times a job will be executed before considering
      # it failed. By default it's 3. To specify it, set the ivar
      # @insist to an integer. Any value under 1 will make the job
      # perform just once as if the plugin was never there.
      def insist_times
        @insist || 3
      end

      # Calculates the amount of seconds a job is locked between
      # the last failure and the next attempt.
      def wait_time(attempts)
        2 ** (attempts.to_i + 2)
      end

      private
      # Calculates a key to identify the job according to
      # its arguments.
      def insist_key(*args)
        self.to_s + ':' + Digest::SHA1.hexdigest(args.join(','))
      end
    end
  end
end
