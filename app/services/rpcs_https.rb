require 'net/https'

class RpcsHTTPS
  BASE_URI = URI('https://rpcsr.sw.it.aoyama.ac.jp').freeze
  def initialize(password)
    @cookie = nil
    login(nil, password)
  end

  def login(number, password)
    # (https GET with basic auth)
    uri = URI('https://rpcsr.sw.it.aoyama.ac.jp/session')

    post_body_hash = { login: '35616147', password: password }
    post_body_json = JSON.pretty_generate(post_body_hash)
    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = req['Accept'] = 'application/json'
    # req['Authorization'] = 'bearer ' + access_token
    req.body = post_body_json
    res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') { |http|
      http.request(req)
    }
    case res
    when Net::HTTPSuccess
      puts JSON.pretty_generate(JSON.parse(res.body))
    when Net::HTTPFound
      res.get_fields('set-cookie').each do |cookie|
          cookie.split('; ').each do |param|
              pair = param.split('=')
              if pair[0] == '_rpcsr_session'
                  @cookie = pair[1]
                  break
              end
          end
          break unless @cookie.nil?
      end
    else
      abort "call api failed: body=" + res.body
    end

    res
  end

  def get(path='/', params={})
    uri = BASE_URI.merge(path)
    puts  uri

    post_body_json = JSON.pretty_generate(params)
    req = Net::HTTP::Get.new(uri)
    # req['Content-Type'] = req['Accept'] = 'application/json'
    req['Cookie'] = "_rpcsr_session=#{@cookie}"
    req.body = post_body_json
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
    res
  end


  def post(path='/', params={})
    uri = BASE_URI.merge(path)

    post_body_json = JSON.pretty_generate(params)
    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = req['Accept'] = 'application/json'
    req['Cookie'] = "_rpcsr_session=#{@cookie}"
    req.body = post_body_json
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
    res
  end

  def create_attempt(file)

    doc = Nokogiri::HTML(get('/attempts/new').body)
    nodes = doc.xpath('//*[@id="new_attempt"]/div/input')

    authenticity_token = nodes.first.attributes['value'].value
    binary_file = File.open("binary_file_path.c", "rb")
    puts authenticity_token
    # data = [
    #   ['authenticity_token', authenticity_token],
    #   [ "attempt[assignment_id]", '441' ],
    #   [ "attempt[file1]", binary_file, { filename: "file.c" } ],
    # ]

    post_body_hash = {
      {'authenticity_token' => authenticity_token},
      { "attempt[assignment_id]" => '441' },
      { "attempt[file1]" => binary_file },
    }
    post_body_json = JSON.pretty_generate(post_body_hash)

    url = BASE_URI.merge('/attempts')

    req = Net::HTTP::Post.new(url.path)
    # req['Content-Type'] = req['Accept'] = 'application/json'
    req['Cookie'] = "_rpcsr_session=#{@cookie}"
    req.set_form(data, "multipart/form-data")
    binding.pry

    Net::HTTP.start(url.host, url.port, use_ssl: true) { |http| http.request(req) }
  end

end
