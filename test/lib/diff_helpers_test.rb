require 'test_helper'

class DiffHelpersTest < ActiveSupport::TestCase
  describe DiffHelpers, :get_diffs do
    it "should return an array of diffs with the format [:action, \"affected string\", (before..range), (after..range)]" do
      diffs = DiffHelpers.get_diffs "foo bar buzz", "foo BAR buzz"
      assert_equal [[:equal,  "foo ",  0..4, 0..4],
                    [:delete, "bar",   4..7, 4..7],
                    [:insert, "BAR",   7..10, 4..7],
                    [:equal,  " buzz", 7..12, 7..12]],
                   diffs
    end

    it "should ignore coincidental matches" do
      before = "abc def ghij"
      after = "kl mnop qrstuvw xyz"
      diffs = DiffHelpers.get_diffs(before, after)
      assert_equal [[:delete, before], [:insert, after]],
                   diffs.map { |d| d[0..1] }
    end
  end

  describe DiffHelpers, :get_first_delta_offset do
    it "should return the offset of the first diff that modifies the content (i.e. not :equal)" do
      diffs = DiffHelpers.get_diffs("foo bar", "foo Bar")
      assert_equal 4, DiffHelpers.get_first_delta_offset(diffs)
    end
  end

  describe DiffHelpers, :range_was_deleted? do
    it "should return true if the specified range was a subset of a deleted range of text" do
      diffs = DiffHelpers.get_diffs("foo bar buzz", "foo buzz")
      assert DiffHelpers.range_was_deleted? diffs, 5..6
    end

    it "should return true if the specified range was the exact range of a deleted range of text" do
      diffs = DiffHelpers.get_diffs("foo bar buzz", "foo buzz")
      assert DiffHelpers.range_was_deleted? diffs, 4..7
    end

    it "should return false if any part of the specified range was not part of a deleted range of text" do
      diffs = DiffHelpers.get_diffs("foo bar buzz", "foo buzz")
      refute DiffHelpers.range_was_deleted? diffs, 4..9
    end
  end

  describe DiffHelpers, :adjust_offset do
    it "should shift offset forward when text is prepended" do
      before = "this is the text"
      after = "and this is the text"
      offset = 10
      delta = after.length - before.length
      diffs = DiffHelpers.get_diffs(before, after)
      assert_equal offset + delta, DiffHelpers.adjust_offset(diffs, offset)
    end

    it "should shift offset backward when text is removed" do
      before = "this is the text"
      after = "is the text"
      offset = 10
      delta = after.length - before.length
      diffs = DiffHelpers.get_diffs(before, after)
      assert_equal offset + delta, DiffHelpers.adjust_offset(diffs, offset)
    end

    it "should return identical offset when text is identical" do
      text = "this is the text"
      offset = 10
      diffs = DiffHelpers.get_diffs(text, text)
      assert_equal offset, DiffHelpers.adjust_offset(diffs, offset)
    end

    it "should deal with spaces after word deletion" do
      skip "we may or may not want this"
    end
  end

  describe DiffHelpers, :adjust_range do
    it "should adjust both the start and end of the range" do
      before = "this is the text"
      after = "and this is the text"
      range = 8..11
      delta = after.length - before.length
      diffs = DiffHelpers.get_diffs(before, after)
      assert_equal range.min + delta..range.max + delta,
                   DiffHelpers.adjust_range(diffs, range)
    end

    it "should return a negative range for a range that is deleted" do
      diffs = DiffHelpers.get_diffs("delete that word", "delete word")
      assert_equal -1..-1, DiffHelpers.adjust_range(diffs, 7..11)
    end
  end
end
