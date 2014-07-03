module SimpleSet
  class SetHash < ::ActiveSupport::OrderedHash
    def initialize(args = [])
      super()

      args = if args.is_a?(Hash) then
        args.each { |k,v| set_value_for_reverse_lookup(k, v) }
      elsif args.is_a?(Array) && !args.first.is_a?(Array) then
        args.each_with_index.map { |x,y| [x, 2**y] }
      else
        raise Exception.new()
      end
      args.each { |e| set_value_for_reverse_lookup(e[0], e[1]) }

      freeze
    end

  private
    def set_value_for_reverse_lookup(key, value)
      self[key.to_sym] = value
    end
  end
end
