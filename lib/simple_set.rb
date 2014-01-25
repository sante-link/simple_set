require 'active_support'

require 'simple_set/version'
require 'simple_set/set_hash'

require 'active_support/deprecation'

module SimpleSet
  class << self
    def default_options
      @default_options ||= {
        whiny: true,
      }
    end

    def included(base)
      base.send :class_attribute, :simple_set_definitions, instance_writer: false, instance_reader: false
      base.send :extend, ClassMethods
    end
  end

  module ClassMethods
    # Provides ability to create simple sets based on hashes or arrays, backed
    # by integer columns (but not limited to integer columns).
    #
    # Columns are supposed to be suffixed by <tt>_cd</tt>, if not, use
    # <tt>:column => 'the_column_name'</tt>, so some example migrations:
    #
    #   add_column :users, :roles_cd, :integer
    #   add_column :users, :permissions, :integer # and a custom column...
    #
    # and then in your model:
    #
    #   class User
    #     as_set :roles, [:management, :accounting]
    #   end
    #
    #   # or use a hash:
    #
    #   class User
    #     as_set :user_permissions, { create_invoice: 1, send_invoice: 2, create_user: 4, all: 7 }, column: 'permissions'
    #   end
    #
    # Now it's possible to access the set and the internally stored value like:
    #
    #   john_doe = User.new
    #   john_doe.roles                         #=> []
    #   john_doe.roles = [:accounting]
    #   john_doe.roles                         #=> [:accounting]
    #   john_doe.roles_cd                      #=> 2
    #
    # And to make life a tad easier: a few shortcut methods to work with the set are also created.
    #
    #   john_doe.accounting?                  #=> true
    #   john_doe.accounting = false
    #   john_doe.accounting?                  #=> false
    #
    # === Configuration options:
    # * <tt>:column</tt> - Specifies a custom column name, instead of the
    #   default suffixed <tt>_cd</tt> column.
    # * <tt>:prefix</tt> - Define a prefix, which is prefixed to the shortcut
    #   methods (e.g. <tt><symbol>=</tt> and <tt><symbol>?</tt>), if it's set
    #   to <tt>true</tt> the enumeration name is used as a prefix, else a
    #   custom prefix (symbol or string) (default is <tt>nil</tt> => no prefix)
    # * <tt>:slim</tt> - If set to <tt>true</tt> no shortcut methods for all
    #   enumeration values are being generated, if set to <tt>:class</tt> only
    #   class-level shortcut methods are disabled (default is <tt>nil</tt> =>
    #   they are generated)
    # * <tt>:whiny</tt> - Boolean value which if set to <tt>true</tt> will
    #   throw an <tt>ArgumentError</tt> if an invalid value is passed to the
    #   setter (e.g. a value for which no enumeration exists). if set to
    #   <tt>false</tt> no exception is thrown and the internal value is left
    #   untouched (default is <tt>true</tt>)
    def as_set(set_cd, values, options = {})
      options = SimpleSet.default_options.merge({column: "#{set_cd}_cd"}).merge(options)
      options.assert_valid_keys(:column, :prefix, :slim, :whiny)

      metaclass = (class << self; self; end)

      values = SimpleSet::SetHash.new(values)

      define_method("#{set_cd}") do
        current = send(options[:column])
        return nil if current.nil?
        values.select { |k,v| v == current & v }.keys
      end

      define_method("#{set_cd}=") do |new_values|
        real = nil
        real = new_values.collect do |k|
          if values.has_key?(k) then
            values[k]
          else
            raise(ArgumentError, "Invalid set value : #{k}") if options[:whiny]
            0
          end
        end.inject(:|) unless new_values.nil?
        send("#{options[:column]}=", real)
      end

      if options[:slim] != true then
        prefix = options[:prefix] && "#{options[:prefix] == true ? set_cd : options[:prefix]}_"
        values.each do |k,code|
          sym = SetHash.symbolize(k)

          define_method("#{prefix}#{sym}?") do
            current = send(options[:column]) || 0
            code == (code & current)
          end

          define_method("#{prefix}#{sym}=") do |value|
            current = send(options[:column]) || 0
            if value then
              current |= code
            else
              current &= ~code
            end
            send("#{options[:column]}=", current)
            code == (current & code)
          end

          unless options[:slim] == :class then
            metaclass.send(:define_method, "#{prefix}#{sym}", Proc.new { |*args| args.first ? k : code })
          end
        end
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:include, SimpleSet)
end
