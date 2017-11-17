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

  def self.pycparser(file)
    py_path = Rails.root.join('vendor', 'python', 'pycparser', 'examples').to_s
    out, err, status = Open3.capture3("cd #{py_path} && python c_json.py #{file.path}")
    unless status.success?
      raise ConvertError, "Stdout: #{out}\n\nStderr: #{err}"
    end
    return JSON[out]
  end


  def self.func_var(nodes)
    if nodes._nodetype == "FuncDef"
      FuncDef.new(
        body: self.search_var(nodes.body).flatten.compact,
        name: nodes.decl.name,
        p: COORD_PARSE.(nodes.decl.coord),
        args: params_var(nodes.decl.type.args.params).compact,
      )
    else
      search_var(nodes)
    end
  end

  def self.params_var(params)
    params.map do |param|
      case param._nodetype
      when 'Decl'
        Val.new(type: param._nodetype, name: param.name, p: COORD_PARSE.(param.coord))
      when 'TypeName'
        {
          typename: param
        }
      end
    end
  end

  def self.vars(ext)
    ext.map { |e| func_var(e) }
  end

  def self.var_stacks(list)
    {
      globals:  list.select(&:decl?),
      func: list.select(&:func_def?),
      func_body: list.select(&:func_def?).map do |func|
        {
          name: func.name,
          args: func.args,
          body: func.body.select(&:decl?),
        }
      end
    }
  end

  def self.main(ext)
    list = vars(ext)
    stacks = var_stacks(list)
    list.map do |item|
      case item.type
      when 'Decl'
        item.set_token!
      when 'FuncDef'
        item.set_token!
        item.args.map(&:set_token!)
        item.body.each do |var|
          case var.type
          when 'Decl'
            var.set_token!
          else
            if func = stacks.func_body.find{|s| s.name == item.name }
              dec = func.body.find{|d|d.name == var.name}.presence || func.args.find{|a|a.name == var.name}.presence
            end
            dec ||= stacks.func.find{|f|f.name == var.name}.presence || stacks.globals.find { |g| g.name == var.name }
            var.token = dec.token if dec.present?
          end
        end
      end
    end
    list
  end

  COORD_PARSE = ->(coord) { coord&.match(/(\d+):(\d+)\z/)[1..2].map(&:to_i) }
  def self.search_var(nodes, root_type='')
    coord_parse = ->(coord) { coord&.match(/(\d+):(\d+)\z/)[1..2].map(&:to_i) }
    case nodes
    when Array
      nodes.map do |node|
        search_var(node)
      end
    when Hash
      if nodes.keys.include?('name')
        case nodes.name
        when String
          Val.new(type: nodes._nodetype, name: nodes.name, p: coord_parse.(nodes.coord))
        else
          nodes.map do |_, node|
            search_var(node)
          end
        end
      else
        nodes.map do |_, node|
          search_var(node)
        end
      end
    when String, NilClass
      nil
    else
      raise ConvertError.new(node.to_s)
    end
  end

  DECL_TOEKNS = "xkeEKMaDQSCqVdjAWuzgJyXNsbOwIThorFPtcipnGZBHYUvlmfLR".split('')
  FUNC_TOEKNS = "xkeEKMaDQSCqVdjAWuzgJyXNsbOwIThorFPtcipnGZBHYUvlmfLR".split('')

  class FuncDef
    include ActiveModel::Model
    attr_accessor :body, :name, :p, :args, :token

    def type; 'FuncDef' end

    def decl?
      false
    end

    def func_def?; true end

    def set_token!
      @token ||= "F#{FUNC_TOEKNS.pop}"
    end
  end

  class Val
    include ActiveModel::Model
    attr_accessor :type, :name, :p, :token

    def decl?
      type == 'Decl'
    end

    def func_def?; false end

    def set_token!
      @token ||= "D#{DECL_TOEKNS.pop}"
    end
  end

  def self.ext(ext)
    ext.map do |e|
      case e._nodetype
      when 'FuncDef'
        FuncDef.new(e)
      end
    end
  end
end
