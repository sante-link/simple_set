require 'active_record'

def named_model(class_name, &block)
  begin
    return class_name.constantize
  rescue NameError
    klass = Object.const_set(class_name, Class.new(ActiveRecord::Base))
    klass.module_eval do
      self.table_name = 'dummies'
      instance_eval &block
    end
    klass
  end
end

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Base.connection.create_table :dummies do |t|
  t.integer :values_cd
  t.integer :values_with_default_cd, default: 2
  t.integer :spoken_languages_cd
  t.integer :custom_name
end
