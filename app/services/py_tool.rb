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

  class ExtVars
    RESERVE_WORDS = %w{ void char short int long float double auto static const signed unsigned extern volatile
                        register return goto if else switch case default break for while do continue typedef
                        struct enum union sizeof }.freeze
    COORD_PARSE = ->(coord) { coord&.match(/(\d+):(\d+)\z/)[1..2].map(&:to_i) }
    attr_accessor :ext

    def self.main(ext)
      ExtVars.new(ext).main
    end

    def initialize(ext)
      self.ext = ext
      @tokens = 'xkeEKMaDQSCqVdjAWuzgJyXNsbOwIThorFPtcipnGZBHYUvlmfLR'.split('').shuffle
    end

    def token_gen!
      ->(obj) { obj.token.blank? ? obj.set_token!(@tokens.pop) : obj.token }
    end

    def func_var(nodes)
      if nodes._nodetype == 'FuncDef'
        FuncDef.new(
            body: self.search_var(nodes.body).flatten.compact,
            name: nodes.decl.name,
            p: COORD_PARSE.(nodes.decl.coord),
            args: params_var(nodes.decl.type.args&.params || []).compact, # 引数無しの場合 空
        )
      elsif nodes.dig('type', 'type', '_nodetype') == 'Struct'
        StructDef.new(
            name: nodes.name,
            p: COORD_PARSE.(nodes.coord),
            decls: params_var(nodes.type.type['decls'] || []).compact
        )
      else
        search_var(nodes)
      end
    end


    def type_names(decl)
      if decl.dig('type', '_nodetype') == 'TypeDecl' && (type = decl.dig('type', 'type')) && (names = type['names'])
        names.map do |name|
          Val.new(type: 'TypeName', name: name, p: COORD_PARSE.(type.coord))
        end
      else
        []
      end
    end

    def params_var(params)
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

    def variable_sets
      @variable_sets ||= ext.flat_map { |node| func_var(node) }
    end


    def globals
      @globals ||= variable_sets.select(&:decl?)
    end

    def func_decls
      @func_decls ||= variable_sets.select(&:func_decl?)
    end

    def structs
      @structs ||= variable_sets.select(&:struct_def?)
    end

    def struct_decls
      @struct_decls ||= variable_sets.select(&:struct_def?).flat_map(&:decls)
    end

    def funcs
      @funcs ||= variable_sets.select(&:func_def?)
    end

    def func_body
      @func_body ||= variable_sets.select(&:func_def?).map do |func|
        {
            name: func.name,
            args: func.args,
            body: func.body.select(&:decl?),
        }
      end
    end



    def main
      globals.each(&token_gen!)
      func_decls.each(&token_gen!)
      structs.each(&token_gen!)
      struct_decls.each(&token_gen!)
      funcs.each do |func|
        if func_decl = func_decls.find {|func_decl| func_decl.name == func.name }.presence
          func.token = func_decl.token
        else
          token_gen!.(func)
        end
      end
      variable_sets.each do |item|
        case item.type
          when 'StructDef'
            token_gen!.(item)
            item.decls.map(&token_gen!)
          when 'FuncDef'
            token_gen!.(item)
            item.args.map(&token_gen!)
            item.body.each do |var|
              case var.type
                when 'Decl'
                  token_gen!.(var)
                else
                  if func = func_body.find{|s| s.name == item.name }
                    dec = func.body.find{|d|d.name == var.name}.presence || func.args.find{|a|a.name == var.name}.presence
                  end
                  dec ||= funcs.find{|f|f.name == var.name}.presence || structs.find{|s| s.name == var.name} || struct_decls.find{|sd| sd.name == var.name} || globals.find { |g| g.name == var.name }
                  if dec.present?
                    var.token = dec.token
                    var.decl_type = dec.type
                  end
              end
            end
        end
      end
      variable_sets
    rescue NoMethodError => e
      []
    end



    def search_var(nodes)
      coord_parse = ->(coord) { coord&.match(/(\d+):(\d+)\z/)[1..2].map(&:to_i) }
      case nodes
        when Array
          nodes.flat_map do |node|
            search_var(node)
          end
        when Hash
          if nodes.keys.include?('name')
            if nodes.dig('type').try(:dig, '_nodetype') == 'FuncDecl'
              [
                  FuncDecl.new(name: nodes.name, p: coord_parse.(nodes.coord))
              ].concat(
                  type_names(nodes)
              )
            else
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

    class VariableSet
      include ActiveModel::Model
      attr_accessor :name, :p, :token, :decl_type

      def decl?; false end

      def func_decl?; false end
      def func_def?; false end
      def struct_def?; false end

      def set_token!(token)
        unless RESERVE_WORDS.include?(name)
          @token ||= "D#{token}"
        end
      end

      def to_sets; self end
    end

    class FuncDef < VariableSet
      attr_accessor :body, :args

      def type; 'FuncDef' end
      def func_def?; true end

      def set_token!(token)
        unless RESERVE_WORDS.include?(name)
          @token ||= "F#{token}"
        end
      end

      def to_sets
        [].concat(args).concat(body).push(self)
      end
    end

    class FuncDecl < VariableSet
      def type; 'FuncDecl' end
      def func_decl?; true end

      def set_token!(token)
        unless RESERVE_WORDS.include?(name)
          @token ||= "F#{token}"
        end
      end
    end

    class Val < VariableSet
      attr_accessor :type
      def decl?
        type == 'Decl'
      end

      def set_token!(token)
        unless RESERVE_WORDS.include?(name)
          @token ||= "D#{token}"
        end
      end
    end

    class StructDef < VariableSet
      attr_accessor :decls

      def type; 'StructDef' end

      def struct_def?; true end

      def set_token!(token)
        @token ||= "F#{token}"
      end

      def to_sets
        [].concat(decls).push(self)
      end
    end

  end

end
