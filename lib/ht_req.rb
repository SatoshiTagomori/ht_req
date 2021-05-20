# frozen_string_literal: true

require_relative "ht_req/version"
require 'net/http'
require 'uri'
require 'json'
require 'active_support'

module HtReq
  class Error < StandardError; end
  
  @error =[]
  
  def self.help()
    puts <<"EOS"
こんなふうに使います
HtReq.send_request({
  :method => 'GET',
  :url => 'https://kyozai.net/'
  :params =>{
    'name'=>'tagomori',
    'pass'=>'tagomori123'
  },
  :header=>{'Content-Type'=>'application/x-www-form-urlencoded'}
})
EOS
  end
  
  def self.error()
    result = @error
    @error=[]
    result
  end
  
  
  def self.get_json_data(param)
    res = self.send_request(param)
    if res.code != '200'
      return false
    else
      JSON.parse(res.body) rescue false
    end
  end
  
  #テスト送信してみて問題ないか確かめる
  def self.test_send(param={})
    self.send_request(param).code == '200' ? true:false
  end
  
  
  #メインの関数
  def self.send_request(param={})
    #methodがなければGETにする
    request_method = param[:method].nil? ? 'GET': param[:method]
    #urlがなければとりあえず我がサイトにしておく
    if param[:url].nil? then param[:url]='https://kyozai.net/' end
    #urlをパースする
    url = URI.parse(param[:url])
    #pathがなければrootにする
    if url.path=='' then url.path='/' end
    #Getの場合は必要であればパラメータを設定する
    url = self.SetGetParams(request_method,url,param)
    #httpのインスタンスを作成
    http = Net::HTTP.new(url.host,url.port)
    #ssl通信を許可
    http.use_ssl=true
    http.verify_mode=OpenSSL::SSL::VERIFY_NONE
    #接続した結果のレスポンスをreturn
    res = http.start do 
      #Postの場合とGetの場合を両方インスタンス化
      req = eval('Net::HTTP::'+request_method.capitalize+'.new(url.path)')
      #リクエストヘッダを設定する
      req=self.SetRequestHeader(req,param)
      #Postの場合、パラメータがあれば送る
      req = self.SetFormData(req,request_method,param)
      http.request(req)
    end
    if res.code != '200'
      @error.push({:code=>res.code,
                    :body=>res.body,
                    :datetime=>Time.now.to_s,
                    :header=>res.header.msg
                  })
    end
    res
  end
  
  def self.SetRequestHeader(req,param)
    if !param[:header].nil?
      param[:header].each{|k,v|
        req[k]=v
      }
    end
    req
  end
  
  #getのパラメータを設定する
  def self.SetGetParams(request_method,url,param)
    if request_method.capitalize=='Get' && !param[:params].nil?
      url.query = URI.encode_www_form(param[:params]).gsub("+","%20")
    end
    url
  end
  
  #Postの場合はフォームデータを入れる
  def self.SetFormData(req,request_method,param)
      if request_method.capitalize=='Post' && !param[:params].nil?
        req.set_form_data(param[:params])
      end
      req
  end
  
end
