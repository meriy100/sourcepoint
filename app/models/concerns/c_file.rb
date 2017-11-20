module Concerns::CFile
  extend ActiveSupport::Concern

  included do
    def remove_include
      self.file1.encode('UTF-8', 'UTF-8').gsub(/\r[^$]/, "\n").gsub(/^(\s*)#include .*$/, '\1')
    end
  end
end
