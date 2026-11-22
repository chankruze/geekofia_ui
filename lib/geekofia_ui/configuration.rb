module GeekofiaUi
  class Configuration
    attr_reader :icon_provider, :icon_set, :icon_aliases, :font_awesome_kit, :font_awesome_style,
                :font_provider, :font_sans, :font_mono, :font_weights

    def initialize
      @icon_provider = :lucide
      @icon_set = "lucide"
      @icon_aliases = {}.freeze
      @font_awesome_kit = nil
      @font_awesome_style = "solid"
      @font_provider = :system
      @font_sans = nil
      @font_mono = nil
      @font_weights = [ 400, 500, 600, 700 ].freeze
    end

    %i[icon_provider icon_set icon_aliases font_awesome_kit font_awesome_style].each do |name|
      define_method(:"#{name}=") { |value| @icons = nil; instance_variable_set(:"@#{name}", value) }
    end

    %i[font_provider font_sans font_mono font_weights].each do |name|
      define_method(:"#{name}=") { |value| @fonts = nil; instance_variable_set(:"@#{name}", value) }
    end

    def icons = @icons ||= Icons.resolve(icon_provider, self)
    def fonts = @fonts ||= Fonts.resolve(font_provider, self)
  end
end
