require "test_helper"

class GeekofiaUi::ClassMergeTest < ActiveSupport::TestCase
  M = GeekofiaUi::ClassMerge

  test "later utility in the same group replaces the earlier one" do
    assert_equal "rounded-md bg-red-500", M.call("bg-primary rounded-md", "bg-red-500")
    assert_equal "h-9 px-6", M.call("h-9 px-4", "px-6")
    assert_equal "text-sm text-destructive", M.call("text-sm text-foreground", "text-destructive")
  end

  test "different groups and variants are kept apart" do
    assert_equal "text-sm text-muted-foreground", M.call("text-sm", "text-muted-foreground")
    assert_equal "bg-primary hover:bg-red-500", M.call("bg-primary hover:bg-primary/90", "hover:bg-red-500")
    assert_equal "border border-border", M.call("border", "border-border")
  end

  test "padding axes and display" do
    assert_equal "px-4 py-1 p-2", M.call("px-4 py-1", "p-2")
    assert_equal "hidden", M.call("flex", "hidden")
  end

  test "nil, arrays and duplicates" do
    assert_equal "a b", M.call(nil, [ "a", "b" ], "a")
    assert_equal "", M.call(nil, "")
  end
end
