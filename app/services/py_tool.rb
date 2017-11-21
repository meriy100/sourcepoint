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
        args: params_var(nodes.decl.type.args&.params || []).compact, # 引数無しの場合 空
      )
    elsif nodes.type&.type&._nodetype == 'Struct'
      StructDef.new(
        name: nodes.name,
        p: COORD_PARSE.(nodes.coord),
        decls: params_var(nodes.type.type.decls || []).compact
      )
    else
      search_var(nodes)
    end
  end

  def self.type_names(decl)
    if decl.dig('type', '_nodetype') == 'TypeDecl' && (type = decl.dig('type', 'type')) && (names = type['names'])
      names.map do |name|
        Val.new(type: 'TypeName', name: name, p: COORD_PARSE.(type.coord))
      end
    else
      []
    end
  end

  def self.params_var(params)
    params.flat_map do |param|
      case param._nodetype
      when 'Decl'
        [Val.new(type: param._nodetype, name: param.name, p: COORD_PARSE.(param.coord))].concat(type_names(param))
      when 'TypeName'
        {
          typename: param
        }
      end
    end
  end

  def self.vars(ext)
    ext.flat_map { |e| func_var(e) }
  end

  def self.var_stacks(list)
    {
      globals:  list.select(&:decl?),
      structs: list.select(&:struct_def?),
      struct_decls: list.select(&:struct_def?).flat_map(&:decls),
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
    $decl_tokens = DECL_TOKENS.dup.shuffle
    $func_tokens = FUNC_TOKENS.dup.shuffle
    list = vars(ext)
    stacks = var_stacks(list)
    list.map do |item|
      case item.type
      when 'Decl'
        item.set_token!
      when 'StructDef'
        item.set_token!
        item.decls.map(&:set_token!)
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
            dec ||= stacks.func.find{|f|f.name == var.name}.presence || stacks.structs.find{|s| s.name == var.name} || stacks.struct_decls.find{|sd| sd.name == var.name} || stacks.globals.find { |g| g.name == var.name }
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
      nodes.flat_map do |node|
        search_var(node)
      end
    when Hash
      if nodes.keys.include?('name')
        case nodes.name
        when String
          [
            Val.new(type: nodes._nodetype, name: nodes.name, p: coord_parse.(nodes.coord))
          ].concat(
            type_names(nodes)
          )
        else
          nodes.flat_map do |_, node|
            search_var(node)
          end
        end
      else
        nodes.flat_map do |_, node|
          search_var(node)
        end
      end
    when String, NilClass
      nil
    else
      raise ConvertError.new(node.to_s)
    end
  end

  DECL_TOKENS = "xkeEKMaDQSCqVdjAWuzgJyXNsbOwIThorFPtcipnGZBHYUvlmfLR".split('')
  FUNC_TOKENS = "xkeEKMaDQSCqVdjAWuzgJyXNsbOwIThorFPtcipnGZBHYUvlmfLR".split('')

  RESERVE_WORDS = %w{
    void
    char
    short
    int
    long
    float
    double
    auto
    static
    const
    signed
    unsigned
    extern
    volatile
    register
    return
    goto
    if
    else
    switch
    case
    default
    break
    for
    while
    do
    continue
    typedef
    struct
    enum
    union
    sizeof
  }

  class FuncDef
    include ActiveModel::Model
    attr_accessor :body, :name, :p, :args, :token

    def type; 'FuncDef' end

    def decl?
      false
    end

    def func_def?; true end

    def struct_def?; false end

    def set_token!
      unless RESERVE_WORDS.include?(name)
        @token ||= "F#{$func_tokens.pop}"
      end
    end

    def to_sets
      [].concat(args).concat(body).push(self)
    end
  end

  class Val
    include ActiveModel::Model
    attr_accessor :type, :name, :p, :token, :type_names

    def decl?
      type == 'Decl'
    end

    def func_def?; false end

    def struct_def?; false end

    def set_token!
      unless RESERVE_WORDS.include?(name)
        @token ||= "D#{$decl_tokens.pop}"
      end
    end

    def to_sets; self end
  end

  def self.ext(ext)
    ext.map do |e|
      case e._nodetype
      when 'FuncDef'
        FuncDef.new(e)
      end
    end
  end

  class StructDef
    include ActiveModel::Model
    attr_accessor :name, :p, :decls, :token

    def type; 'StructDef' end

    def decl?
      false
    end

    def func_def?; false end

    def struct_def?; true end

    def set_token!
      @token ||= "F#{$decl_tokens.pop}"
    end

    def to_sets
      [].concat(decls).push(self)
    end
  end
end
