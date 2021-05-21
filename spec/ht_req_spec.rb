# frozen_string_literal: true

RSpec.describe HtReq do
  it "バージョンがちゃんとあるか確認" do
    expect(HtReq::VERSION).not_to be nil
  end
  
  it "とりあえずテスト送信してみる" do
    expect(HtReq.test_request).to eq(true)
  end

  it "とりあえずパラメータなしで送る" do
    expect(HtReq.request.code).to eq('200')
  end
  
  it "GETでパラメータありで送る" do
    expect(HtReq.request({
      :url=>'https://kyozai.net/gemtest/ht_req/2',
      :params=>{
        :firstname=>'tagomori'
      }
    }).body).to eq('tagomori')
  end
  
  it "URLとパラメータだけ送ってURLを作る" do
    expect(HtReq.set_get_params_to_url(
      'http://xxx.com',
      {
        :name=>'tagomori'
      }).to_s).to eq('http://xxx.com?name=tagomori')
  end
  
  it "POSTでパラメータなしで送る" do
    expect(HtReq.request({
      :method=>'POST'
    }).code).to eq('200')
  end
  
  it "POSTでパラメータありで送る" do
    expect(HtReq.request({
      :method=>'POST',
      :url=>'https://kyozai.net/gemtest/ht_req/2',
      :params=>{
        :firstname=>'tagomori'
      }
    }).body).to eq('tagomori')
  end
  
end
