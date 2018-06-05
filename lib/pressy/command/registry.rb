class Pressy::Command::Registry
  def initialize
    @commands = {}
  end

  def register(type)
    @commands[type.name] = type
  end

  def lookup(name)
    @commands[name]
  end

  def self.default
    @default_registry ||= Pressy::Command::Registry.new
  end
end
