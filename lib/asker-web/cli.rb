
require_relative '../asker-web'

module CLI
  def self.start(argv)
    AskerWeb.show_help if argv[0] == 'help'
    AskerWeb.show_version if argv[0] == 'version'
    AskerWeb.up
  end
end
