require "test_helper"

class BasicTest < RackTimeoutTest
  def test_ok
    self.settings = { service_timeout: 1 }
    get "/"
    assert last_response.ok?
  end

  def test_env_override_timeout
    error = assert_raises(Rack::Timeout::RequestTimeoutError) do
      get "/sleep", "env_timeout=true"
    end
    assert_equal("Request ran for longer than 2000ms ", error.message)
  end

  def test_timeout
    self.settings = { service_timeout: 1 }
    error = assert_raises(Rack::Timeout::RequestTimeoutError) do
      get "/sleep"
    end
    assert_equal("Request ran for longer than 1000ms ", error.message)
  end

  def test_wait_timeout
    self.settings = { service_timeout: 1, wait_timeout: 15 }
    error = assert_raises(Rack::Timeout::RequestExpiryError) do
      get "/", "", 'HTTP_X_REQUEST_START' => time_in_msec(Time.now - 100)
    end
    assert_equal("Request older than 15000ms.", error.message)
  end
end
