class ProtectionProxy

  def self.role(role_name)
    @current_list = []
    yield
    writable_fields[role_name] = @current_list
  end

  def self.find_proxy(object, role)
    new(object, writable_fields[role])
  end

  def self.writable(*names)
    names.each do |name|
      @current_list << name
    end
  end

  def self.writable_fields
    @writable_fields ||= {}
  end

  def initialize(object, writable_fields)
    @object = object
    @writable_fields = writable_fields
  end

  def method_missing(sym, *args, &block)
    method_name = sym.to_s
    if ! method_name.end_with?("=")
      @object.send(sym, *args, &block)
    else
      field_name = method_name[0...-1].to_sym
      if @writable_fields.include?(field_name)
        @object.send(sym, *args, &block)
      end
    end
  end

end
