require 'test_helper'

class LogTest < ActiveSupport::TestCase
  test 'should create log' do
    assert_difference 'Chaltron::Log.count' do
      create(:chaltron_log)
    end
  end

  test 'message should be present' do
    record = build(:chaltron_log, message: nil)
    assert_not record.valid?
    assert_not_empty record.errors[:message]
  end

  test 'message should be truncated' do
    too_long_message = 'x' * 1500
    record = build(:chaltron_log, message: too_long_message)
    assert record.valid?
    assert_equal 1000, record.message.length
  end

  test 'severity should be present' do
    record = build(:chaltron_log, severity: nil)
    assert_not record.valid?
    assert_not_empty record.errors[:severity]
  end

  test 'severity should be included in syslog standard severities' do
    record = build(:chaltron_log, severity: 'something')
    assert_not record.valid?
    assert_not_empty record.errors[:severity]
  end

  test 'severity should be standarized' do
    record = build(:chaltron_log, severity: 'error')
    assert record.valid?
    assert_equal 'err', record.severity
  end
end
