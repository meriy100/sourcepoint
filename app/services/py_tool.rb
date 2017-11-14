require 'open3'
module PyTool
  class ConvertError < StandardError; end
  def self.pdggenerator(file)
    py_path = Rails.root.join('vendor', 'python', 'pdggenerator', 'pdg_generator').to_s
    out, err, status = Open3.capture3("cd #{py_path} && python main.py #{file.path}")
    unless status.success?
      raise ConvertError, "Stdout: #{out}\n\nStderr: #{err}"
    end
    return JSON[out]
  end
end
