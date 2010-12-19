require File.dirname(__FILE__) + '/spec_helper'

class Job
  extend Resque::Plugins::Insist
  @queue = :job
  @insist = 2
  def self.perform(success)
    raise 'Not gonna work' unless success
  end
end

describe Resque::Plugins::Insist do
  describe "compliance of Resque Plugins guidelines" do
    it "should be valid" do
      lambda{ Resque::Plugin.lint(Resque::Plugins::Insist) }.should_not raise_error
    end
  end

  describe "config" do
    it "should take the insist_times value from the @insist ivar" do
      Job.insist_times.should == 2
    end

    it "shoult default insist_times to 3" do
      class JobWithoutCustomInsist
        extend Resque::Plugins::Insist
        @queue = :job
        def self.perform; end
      end
      JobWithoutCustomInsist.insist_times.should == 3
    end
  end

  describe "a succeeding Job" do
    it "should be executed on the first attempt and not be enqueued again" do
      Resque.enqueue Job, true
      pending.should == 1
      processed.should == 0
      failed.should == 0
      work_jobs
      pending.should == 0
      processed.should == 1
      failed.should == 0
    end
  end

  describe "a failing Job" do
    it "should should quietly die and be enqueued back the first time it's executed" do
      Resque.enqueue Job, false # enqueue a failing job
      work_job # try to work it for the first time
      pending.should == 1
      failed.should == 0
      time_before = Time.now
      work_jobs # try to work it for the second and last time
      elapsed_time = Time.now - time_before
      elapsed_time.should > 7 # We wait aprox 8 seconds
      elapsed_time.should < 9
      pending.should == 0
      failed.should == 1 # the job is marked as failed after 2 attempts
      Resque::Failure.all['error'].should == 'Not gonna work' # we get the original error
    end
  end

  # Defines pending, failed, processed, queues, environment, workers and servers
  Resque.info.keys.each do |key|
    define_method(key) { Resque.info[key] }
  end

  # Starts a worker to work off queue
  def work_jobs(queue = :job)
    Resque::Worker.new(queue).work(0)
  end

  # Performs the first job available from queue
  def work_job(queue = :job)
    worker = Resque::Worker.new(queue)
    worker.perform(worker.reserve)
  end
end
