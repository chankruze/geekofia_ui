module GeekofiaUi
  # Joins Tailwind class lists. When two utilities belong to the same group
  # (and share the same variant prefix), the later one wins.
  module ClassMerge
    # Known limits: padding/margin shorthands (p-, m-) don't remove earlier
    # axis- or side-specific tokens (px-, mt-, ...), and variant order is
    # compared literally ("hover:focus:" differs from "focus:hover:").
    SIDES = %w[x y t r b l s e].freeze
    CORNERS = %w[t r b l s e tl tr br bl ss se es ee].freeze

    GROUPS = [
      [ :px, /\Apx-/ ], [ :py, /\Apy-/ ], [ :pt, /\Apt-/ ], [ :pr, /\Apr-/ ], [ :pb, /\Apb-/ ], [ :pl, /\Apl-/ ], [ :p, /\Ap-/ ],
      [ :mx, /\A-?mx-/ ], [ :my, /\A-?my-/ ], [ :mt, /\A-?mt-/ ], [ :mr, /\A-?mr-/ ], [ :mb, /\A-?mb-/ ], [ :ml, /\A-?ml-/ ], [ :m, /\A-?m-/ ],
      [ :size, /\Asize-/ ], [ :min_w, /\Amin-w-/ ], [ :max_w, /\Amax-w-/ ], [ :w, /\Aw-/ ], [ :h, /\Ah-/ ],
      [ :text_size, /\Atext-(xs|sm|base|lg|[2-9]?xl)(\/\S+)?\z/ ], [ :text_align, /\Atext-(left|center|right|justify|start|end)\z/ ],
      [ :text_color, /\Atext-/ ],
      [ :font_weight, /\Afont-(thin|extralight|light|normal|medium|semibold|bold|extrabold|black)\z/ ],
      [ :font_family, /\Afont-(sans|serif|mono)\z/ ],
      [ :bg_size, /\Abg-(cover|contain|auto)\z/ ],
      [ :bg_position, /\Abg-(center|top|bottom|left|right|left-top|left-bottom|right-top|right-bottom)\z/ ],
      [ :bg_repeat, /\Abg-(no-)?repeat(-x|-y|-round|-space)?\z/ ],
      [ :bg_image, /\Abg-(linear|gradient|radial|conic)-/ ],
      [ :bg_clip, /\Abg-clip-/ ], [ :bg_origin, /\Abg-origin-/ ],
      [ :bg, /\Abg-/ ],
      *SIDES.map { |side| [ :"border_width_#{side}", /\Aborder-#{side}(-\d+)?\z/ ] },
      [ :border_width, /\Aborder(-\d+)?\z/ ], [ :border_color, /\Aborder-/ ],
      *CORNERS.map { |corner| [ :"rounded_#{corner}", /\Arounded-#{corner}(-|\z)/ ] },
      [ :rounded, /\Arounded(-|\z)/ ],
      [ :gap_x, /\Agap-x-/ ], [ :gap_y, /\Agap-y-/ ], [ :gap, /\Agap-/ ],
      [ :shadow, /\Ashadow(-(2xs|xs|sm|md|lg|xl|2xl|none|inner))?\z/ ], [ :opacity, /\Aopacity-/ ],
      [ :justify, /\Ajustify-(start|end|center|between|around|evenly|stretch|normal)\z/ ], [ :items, /\Aitems-/ ],
      [ :display, /\A(block|inline-block|inline|flex|inline-flex|grid|inline-grid|hidden|contents|table)\z/ ]
    ].freeze

    # A later utility in the key group also removes earlier ones in these groups.
    CONFLICTS = { size: %i[w h] }.freeze

    module_function

    def call(*lists)
      tokens = lists.flatten.compact.flat_map { |list| list.to_s.split }
      result = []
      positions = {}
      tokens.each do |token|
        variants, group = parse(token)
        if group
          [ group, *CONFLICTS[group] ].each do |g|
            index = positions.delete("#{variants}:#{g}")
            result[index] = nil if index
          end
          positions["#{variants}:#{group}"] = result.size
        end
        result << token
      end
      result.compact.uniq.join(" ")
    end

    def parse(token)
      variants, _, utility = token.rpartition(":")
      utility = utility.delete_prefix("!").delete_suffix("!")
      [ variants, GROUPS.find { |_, pattern| utility.match?(pattern) }&.first ]
    end
  end
end
