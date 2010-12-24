require 'test_helper'

class InfoMailerTest < ActionMailer::TestCase
  test "register" do
    @expected.subject = 'InfoMailer#register'
    @expected.body    = read_fixture('register')
    @expected.date    = Time.now

    assert_equal @expected.encoded, InfoMailer.create_register(@expected.date).encoded
  end

end
