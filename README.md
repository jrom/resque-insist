# Resque::Plugins::Insist
## Give your Resque jobs a second chance

<http://github.com/jrom/resque-insist> by Jordi Romero

If you want to give your jobs a second chance (or more)
extend them with this plugin and let the job fail
some times before considering it failed.

By default a job will be run 3 times before marking it
as failed, but you can configure that with @insist = N
in your job.

## Usage

    require 'resque/plugins/insist'
    class HardJob
      extend Resque::Plugins::Insist
      @queue = :hard_job
      @insist = 5
      def self.perform(something)
        do_work
      end
    end

When your job fails for the first time, it will be queued
again, but will be locked for 8 seconds before the worker
performs it again. If it fails again, the wait time will be
16 seconds, then 32, 64, ... until your job reaches the
maximum number of attempts or just succeeds (not raising an
exception).

## Contributing

If you want to improve resque-insist

1. Fork the repo
2. Create a topic branch `git checkout -b my_feature`
3. Push it! `git push origin my_feature`
4. Open a pull request

Make sure you add specs for your changes and document them.
Any contribution will be appreciated, both fixing some typo or
adding the coolest feature ever.

## Issues

<http://github.com/jrom/resque-insist/issues>
