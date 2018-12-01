def obtain_class
  class_name = ENV['CLASS'] || ENV['class']
  raise "Must specify CLASS" unless class_name
  @klass = Object.const_get(class_name)
end

def obtain_attachments
  name = ENV['ATTACHMENT'] || ENV['attachment']
  raise "Class #{@klass.name} has no attachments specified" unless @klass.respond_to?(:attachment_definitions)
  if !name.blank? && @klass.attachment_definitions.keys.include?(name)
    [ name ]
  else
    @klass.attachment_definitions.keys
  end
end

def for_all_attachments
  klass = obtain_class
  names = obtain_attachments
  ids   = klass.connection.select_values(klass.send(:construct_finder_sql, :select => 'id'))

  ids.each do |id|
    instance = klass.find(id)
    names.each do |name|
      result = if instance.send("#{ name }?")
                 yield(instance, name)
               else
                 true
               end
      print result ? "." : "x"; $stdout.flush
    end
  end
  puts " Done."
end
