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
end
