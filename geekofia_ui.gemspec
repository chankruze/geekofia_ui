require_relative "lib/geekofia_ui/version"

Gem::Specification.new do |spec|
  spec.name        = "geekofia_ui"
  spec.version     = GeekofiaUi::VERSION
  spec.authors     = [ "Chandan Kumar Mandal" ]
  spec.email       = [ "chankruze@gmail.com" ]
  spec.homepage    = "https://github.com/chankruze/geekofia_ui"
  spec.summary     = "shadcn-style UI components for Rails ERB + Tailwind apps"
  spec.description = "ui_* helpers backed by partials, a form builder, Stimulus controllers, and a " \
                     "Tailwind v4 theme with dark mode and pluggable icon and font providers."
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.3"
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(__dir__) { Dir["{app,config,lib}/**/*", "MIT-LICENSE", "README.md"] }

  spec.add_dependency "rails", ">= 8.0"
  spec.add_dependency "tailwindcss-rails", ">= 4.2"
  spec.add_dependency "importmap-rails", ">= 2.0"
  spec.add_dependency "stimulus-rails", ">= 1.3"
end
