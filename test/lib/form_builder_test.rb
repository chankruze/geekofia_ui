require "test_helper"

class GeekofiaUi::FormBuilderTest < ActionView::TestCase
  class Thing
    include ActiveModel::Model
    attr_accessor :name, :kind, :notes, :secret
    validates :name, presence: true
  end

  setup do
    @previous_proc = ActionView::Base.field_error_proc
    ActionView::Base.field_error_proc = proc { |html, _| html }
  end

  teardown { ActionView::Base.field_error_proc = @previous_proc }

  def form_for_thing(thing, &block)
    form_with(model: thing, url: "/things", scope: :thing, builder: GeekofiaUi::FormBuilder, &block)
  end

  test "field with label, hint and error wiring" do
    thing = Thing.new.tap(&:validate)
    doc = fragment(form_for_thing(thing) { |f| f.ui_text_field(:name, hint: "Shown in lists") })
    input = doc.at("input#thing_name")
    assert_equal "Name", doc.at("label[for=thing_name]").text.strip
    assert_equal "true", input["aria-invalid"]
    assert_equal "thing_name_hint thing_name_error", input["aria-describedby"]
    assert_includes input["class"], "rounded-md"
    assert_equal "Name can't be blank", doc.at("#thing_name_error").text.strip
  end

  test "select, text area, password and submit" do
    doc = fragment(form_for_thing(Thing.new) do |f|
      safe_join([ f.ui_select(:kind, [ [ "A", "a" ] ], { label: "Kind" }), f.ui_text_area(:notes, rows: 3),
                  f.ui_password_field(:secret, label: "Secret"), f.ui_submit("Save") ])
    end)
    assert doc.at("select#thing_kind option[value=a]")
    assert_equal "Kind", doc.at("label[for=thing_kind]").text.strip
    assert_equal "3", doc.at("textarea#thing_notes")["rows"]
    assert doc.at("input[type=password]#thing_secret")
    assert_equal "Save", doc.at("button[type=submit]").text.strip
    assert_nil doc.at("[aria-invalid]")
  end

  test "works with form_with url: and no model" do
    html = form_with(url: "/session", builder: GeekofiaUi::FormBuilder) do |f|
      f.ui_email_field(:email_address, label: "Email", value: "a@b.c")
    end
    doc = fragment(html)
    input = doc.at("input#email_address")
    assert_equal "email", input["type"]
    assert_equal "a@b.c", input["value"]
    assert_equal "Email", doc.at("label[for=email_address]").text.strip
    assert_nil doc.at("[aria-invalid]")
    assert_nil input["aria-describedby"]
    assert_nil doc.at("#email_address_error")
  end

  class Persisted < Thing
    def persisted? = true
  end

  def one_field(thing = Thing.new, &block)
    fragment(form_for_thing(thing, &block))
  end

  test "custom id drives label, hint and describedby" do
    doc = one_field { |f| f.ui_text_field(:name, id: "custom", hint: "x") }
    assert doc.at("input#custom")
    assert doc.at("label[for=custom]")
    assert_equal "custom_hint", doc.at("input#custom")["aria-describedby"]
    assert doc.at("#custom_hint")
  end

  test "blank hints render nothing" do
    [ nil, "" ].each do |hint|
      doc = one_field { |f| f.ui_text_field(:name, hint: hint) }
      assert_nil doc.at("#thing_name_hint")
      assert_nil doc.at("input")["aria-describedby"]
    end
  end

  test "caller describedby is kept and joined" do
    doc = one_field { |f| f.ui_text_field(:name, hint: "x", aria: { describedby: "mine" }) }
    assert_equal "mine thing_name_hint", doc.at("input")["aria-describedby"]
    doc = one_field { |f| f.ui_text_field(:name, aria: { describedby: "mine" }) }
    assert_equal "mine", doc.at("input")["aria-describedby"]
  end

  test "label false renders a screen-reader-only label" do
    doc = one_field { |f| f.ui_text_field(:name, label: false) }
    label = doc.at("label[for=thing_name]")
    assert_equal "Name", label.text.strip
    assert_includes label["class"].split, "sr-only"
  end

  test "input classes are iOS-safe, dark aware and overridable" do
    doc = one_field { |f| f.ui_text_field(:name) }
    classes = doc.at("input")["class"].split
    assert_includes classes, "text-base"
    assert_includes classes, "md:text-sm"
    assert_includes classes, "dark:bg-input/30"
    assert_includes classes, "dark:aria-invalid:ring-destructive/40"
    doc = one_field { |f| f.ui_text_field(:name, class: "text-xs") }
    classes = doc.at("input")["class"].split
    assert_includes classes, "text-xs"
    assert_not_includes classes, "text-base"
    # ClassMerge treats variants as separate groups, so the base md:text-sm survives a plain
    # text-xs (intended: responsive base stays). Callers wanting it everywhere pass "text-xs md:text-xs".
    assert_includes classes, "md:text-sm"
    doc = one_field { |f| f.ui_text_field(:name, class: "text-xs md:text-xs") }
    classes = doc.at("input")["class"].split
    assert_includes classes, "md:text-xs"
    assert_not_includes classes, "md:text-sm"
  end

  test "text area keeps caller classes and drops base text size" do
    doc = one_field { |f| f.ui_text_area(:notes, class: "font-mono text-xs") }
    classes = doc.at("textarea")["class"].split
    assert_includes classes, "font-mono"
    assert_includes classes, "text-xs"
    assert_not_includes classes, "text-base"
  end

  test "select uses its own classes and merges html_options class" do
    doc = one_field { |f| f.ui_select(:kind, [ [ "A", "a" ] ], {}, { class: "w-40" }) }
    classes = doc.at("select")["class"].split
    assert_includes classes, "pr-8"
    assert_includes classes, "w-40"
    assert_not_includes classes, "w-full"
    assert(classes.none? { |c| c.start_with?("placeholder:") })
  end

  test "submit default value follows persistence" do
    assert_equal "Create Thing", one_field { |f| f.ui_submit }.at("button[type=submit]").text.strip
    assert_equal "Update Persisted", one_field(Persisted.new) { |f| f.ui_submit }.at("button[type=submit]").text.strip
  end

  test "nil value renders no value attribute or content" do
    doc = one_field do |f|
      safe_join([ f.ui_password_field(:secret, value: nil), f.ui_text_area(:notes, value: nil) ])
    end
    assert_nil doc.at("input[type=password]")["value"]
    assert_equal "", doc.at("textarea").text.strip
  end

  test "works under the default field_error_proc" do
    ActionView::Base.field_error_proc = @previous_proc
    thing = Thing.new.tap(&:validate)
    doc = one_field(thing) { |f| f.ui_text_field(:name) }
    assert_equal "true", doc.at("input#thing_name")["aria-invalid"]
    assert_equal "Name can't be blank", doc.at("p#thing_name_error").text.strip
  end

  test "error messages are escaped" do
    thing = Thing.new
    thing.errors.add(:name, "<script>alert(1)</script>")
    doc = one_field(thing) { |f| f.ui_text_field(:name) }
    assert_nil doc.at("script")
    assert_includes doc.at("#thing_name_error").text, "<script>"
  end

  test "number field passes min and max" do
    doc = one_field { |f| f.ui_number_field(:name, min: 1, max: 65_535) }
    input = doc.at("input[type=number]")
    assert_equal "1", input["min"]
    assert_equal "65535", input["max"]
  end
end
