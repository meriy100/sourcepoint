module GDBVariableJSON
  class ConvertError < StandardError; end
  def self.to_gdb_json(file1, assignment_id)
    code = ScopeVariable.new(file1, assignment_id).code
    Tempfile.create(['sourcepoint-', '.c']) do |tmp|
      File.write(tmp, code)
      binding.pry
      out, err, status = Open3.capture3('bin/gdb_variable_json.sh', tmp.path)
      unless status.success?
        raise ConvertError, "Stdout: #{out}\n\nStderr: #{err}"
      end
      json = JSON[out]
    end
  end
end
