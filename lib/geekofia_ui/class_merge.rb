module GeekofiaUi
  # Joins Tailwind class lists. When two utilities belong to the same group
  # (and share the same variant prefix), the later one wins.
  module ClassMerge
    GROUPS = [
      [ :px, /\Apx-/ ], [ :py, /\Apy-/ ], [ :pt, /\Apt-/ ], [ :pr, /\Apr-/ ], [ :pb, /\Apb-/ ], [ :pl, /\Apl-/ ], [ :p, /\Ap-/ ],
      [ :mx, /\A-?mx-/ ], [ :my, /\A-?my-/ ], [ :mt, /\A-?mt-/ ], [ :mr, /\A-?mr-/ ], [ :mb, /\A-?mb-/ ], [ :ml, /\A-?ml-/ ], [ :m, /\A-?m-/ ],
      [ :size, /\Asize-/ ], [ :min_w, /\Amin-w-/ ], [ :max_w, /\Amax-w-/ ], [ :w, /\Aw-/ ], [ :h, /\Ah-/ ],
      [ :text_size, /\Atext-(xs|sm|base|lg|[2-9]?xl)\z/ ], [ :text_align, /\Atext-(left|center|right|justify|start|end)\z/ ],
      [ :text_color, /\Atext-/ ],
      [ :font_weight, /\Afont-(thin|extralight|light|normal|medium|semibold|bold|extrabold|black)\z/ ],
      [ :font_family, /\Afont-(sans|serif|mono)\z/ ],
      [ :bg, /\Abg-/ ], [ :border_width, /\Aborder(-[xytrbl])?(-\d+)?\z/ ], [ :border_color, /\Aborder-/ ],
      [ :rounded, /\Arounded(-|\z)/ ], [ :gap, /\Agap-/ ], [ :shadow, /\Ashadow(-|\z)/ ], [ :opacity, /\Aopacity-/ ],
      [ :justify, /\Ajustify-/ ], [ :items, /\Aitems-/ ],
      [ :display, /\A(block|inline-block|inline|flex|inline-flex|grid|inline-grid|hidden|contents|table)\z/ ]
    ].freeze

    module_function

    def call(*lists)
      tokens = lists.flatten.compact.flat_map { |list| list.to_s.split }
      result = []
      positions = {}
      tokens.each do |token|
        key = group_key(token)
        if key && positions.key?(key)
          result[positions[key]] = nil
        end
        positions[key] = result.size if key
        result << token
      end
      result.compact.uniq.join(" ")
    end

    def group_key(token)
      variants, _, utility = token.rpartition(":")
      utility = utility.delete_prefix("!")
      group = GROUPS.find { |_, pattern| utility.match?(pattern) }&.first
      "#{variants}:#{group}" if group
    end
  end
end
