# Main module
module TryUntil

  # @param [Hash] options - options for retry handling
  # @param [Proc] block
  def with_retry(options = {}, &block)
    raise 'No block passed to `with_retry`' unless block_given?
    options = merge_opts(options)
    attempt_num = 1

    begin
      yield(attempt_num)
    rescue *options[:catch_exceptions] => ex
      raise ex if options[:ignore_exceptions].include? ex

      # On fail proc will pass in the attempt_num, raised exception
      call opts[:on_fail_proc].call attempt_num, ex
    end
  end

  def merge_opts(options)
    {
      num_attempts: 3,
      sleep_seconds: 1,
      catch_exceptions: [StandardError],
      ignore_exceptions: [],
      on_fail_proc: nil
    }.merge(options)
  end
end
