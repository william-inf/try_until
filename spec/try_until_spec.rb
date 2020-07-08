RSpec.describe TryUntil do
  it 'should merge options and override default' do
    opts = TryUntil.merge_opts(max_attempts: 3)
    expect(opts[:max_attempts]).to eq(3)
  end

  it 'should run to max attempts requested before raising an exception' do
    max_attempts, last = 5, 0
    begin
      TryUntil.with_retry(max_attempts: max_attempts) do |attempt|
        last = attempt
        raise 'A planned error!'
      end
    rescue StandardError => ex; end

    expect(max_attempts).to eq(last)
  end

  it 'should override the raised exception to the specified class' do
    raised_exception = nil
    begin
      TryUntil.with_retry(
        max_attempts: 5,
        override_exception: TryUntilSpecException
      ) do |attempt|
        raise "A planned error on attempt #{attempt}!"
      end
    rescue StandardError => ex
      raised_exception = ex
    end

    expect(raised_exception.class).to eq(TryUntilSpecException)
    expect(raised_exception.message).to eq('A planned error on attempt 5!')
  end

  it 'should run the exception proc' do
    run_proc = proc do |attempts|
      if attempts <= 2
        puts 'Failed call'
        raise('Hit max attempts')
      end

      puts 'Success!'
    end

    TryUntil.with_retry(max_attempts: 3) do |attempt|
      puts "Running attempt #{attempt} .."
      run_proc.call(attempt)
    end

  end

end

class TryUntilSpecException < StandardError; end