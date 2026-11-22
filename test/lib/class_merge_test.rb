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

  test "border sides are separate groups" do
    assert_equal "border-b border-t", M.call("border-b", "border-t")
    assert_equal "border border-x-2", M.call("border", "border-x-2")
    assert_equal "border-2", M.call("border", "border-2")
    assert_equal "border-t-2", M.call("border-t", "border-t-2")
    assert_equal "border border-destructive", M.call("border border-input", "border-destructive")
    assert_equal "border-s border-e", M.call("border-s", "border-e")
    assert_equal "border-s border-e border-red-500", M.call("border-s border-e", "border-red-500")
  end

  test "text size with line height and important suffix" do
    assert_equal "text-sm/6 text-destructive", M.call("text-sm/6 text-foreground", "text-destructive")
    assert_equal "text-xs!", M.call("text-sm", "text-xs!")
    assert_equal "text-xs!", M.call("!text-sm", "text-xs!")
  end

  test "gap axes are separate groups" do
    assert_equal "gap-x-2 gap-y-4", M.call("gap-x-2", "gap-y-4")
    assert_equal "gap-4", M.call("gap-2", "gap-4")
  end

  test "rounded corners" do
    assert_equal "rounded-l-md rounded-r-md", M.call("rounded-l-md", "rounded-r-md")
    assert_equal "rounded-md rounded-t-lg", M.call("rounded-md", "rounded-t-lg")
    assert_equal "rounded-full", M.call("rounded-md", "rounded-full")
    assert_equal "rounded-ss-md rounded-s-lg", M.call("rounded-ss-md", "rounded-s-lg")
  end

  test "size overrides width and height" do
    assert_equal "size-8", M.call("h-9 w-9", "size-8")
    assert_equal "size-9 h-8", M.call("size-9", "h-8")
    assert_equal "hover:h-9 size-8", M.call("hover:h-9 h-9", "size-8")
  end

  test "non-color background utilities are separate from color" do
    assert_equal "bg-red-500 bg-cover bg-center", M.call("bg-red-500", "bg-cover", "bg-center")
    assert_equal "bg-red-500", M.call("bg-primary", "bg-red-500")
    assert_equal "bg-no-repeat bg-linear-to-r bg-clip-text bg-origin-border", M.call("bg-no-repeat bg-linear-to-r", "bg-clip-text bg-origin-border")
    assert_equal "bg-contain", M.call("bg-cover", "bg-contain")
  end

  test "shadow and justify are tight" do
    assert_equal "shadow-lg", M.call("shadow-sm", "shadow-lg")
    assert_equal "shadow-lg shadow-red-500", M.call("shadow-lg", "shadow-red-500")
    assert_equal "justify-center justify-items-center", M.call("justify-center", "justify-items-center")
    assert_equal "justify-end", M.call("justify-center", "justify-end")
  end

  test "arbitrary variants, negatives, auto and other variants" do
    assert_equal "[&_tr:last-child]:border-0 p-2", M.call("[&_tr:last-child]:border-0", "p-2")
    assert_equal "group-data-[copied=true]:hidden flex", M.call("group-data-[copied=true]:hidden", "flex")
    assert_equal "mt-4", M.call("-mt-2", "mt-4")
    assert_equal "h-auto", M.call("h-9", "h-auto")
    assert_equal "p-6 not-first:pt-0", M.call("p-6", "not-first:pt-0")
  end
end
