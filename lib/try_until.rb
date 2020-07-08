# try_until source
module TryUntil

  # @param [Hash] options - options for retry handling
  # @param [Proc] _block
  def self.with_retry(options = {}, &_block)
    raise 'No block passed to `with_retry`' unless block_given?
    options = merge_opts(options)
    attempt_num = 1

    begin
      yield attempt_num
    rescue *options[:catch_exceptions] => ex
      raise ex if options[:ignore_exceptions].include? ex

      # On fail proc will pass in the attempt_num, raised exception
      options[:on_fail_proc]&.call(attempt_num, ex)
      sleep(options[:sleep_seconds]) && retry if
          (attempt_num += 1) <= options[:max_attempts]

      raise options[:override_exception]&.new(ex.message) || ex
    end
  end

  def self.merge_opts(options)
    {
      max_attempts: 1,
      sleep_seconds: 1,
      catch_exceptions: [StandardError],
      ignore_exceptions: [],
      override_exception: nil,
      on_fail_proc: nil
    }.merge(options)
  end

end
