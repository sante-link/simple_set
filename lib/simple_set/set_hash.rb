require 'simple_enum/enum_hash'

module SimpleSet
  class SetHash < ::SimpleEnum::EnumHash
    def initialize(args = [], strings = false)
      super()

      if args.is_a?(Hash) then
        args.each { |k,v| set_value_for_reverse_lookup(k, v) }
      else
        ary = args.send(args.respond_to?(:enum_with_index) ? :enum_with_index : :each_with_index).map { |x,y| [ x, 2**y ] } unless args.first.respond_to?(:map)
        ary = args.map { |e| [e, 2**e.id] } if args.first.respond_to?(:map) && !args.first.is_a?(Array)
        ary ||= args
        ary.each { |e| set_value_for_reverse_lookup(e[0], strings ? e[0].to_s : e[1]) }
      end
    end
  end
end
