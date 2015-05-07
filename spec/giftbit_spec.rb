require "giftbit"

describe Giftbit do
  let(:auth) { "eyJ0eXAiOiJKV1QiLCJhbGciOiJTSEEyNTYifQ==.TFdWYU5VTVhzK3JFaVhHT2p5VDRHNFRsUk1ybnk2V2E4TDNDSW5meEdXdTVERUJNeHlDTEU1K216Qk1hb3Q4QlZaTVJvWndjR2ZoS01xc3gzdnZMUHdQckN1Z0kreG9rYVF3c1JjUjNkNlNLVmROQTlJb0hvMmpHdkx2REh3NXE=.cu7N3bPxGg8fPxFsIUcjyOISwn+29YpB0l7YDHwkMDg=" }
  let(:endpoint ) { "https://testbedapp.giftbit.com/papi/v1/"}
  let(:data) { {message: "Thank you for being an awesome person", subject: "Present from ModemMsg", contacts: [{firstname: "Audee", lastname: "Velasco", email: "auds@adooylabs.com"}], marketplace_gifts: [{id:1, price_in_cents:5000}]} }

  before(:each) do
    Giftbit.endpoint = endpoint
    Giftbit.auth = auth
  end
  
  describe "#account" do
    it "returns Welcome Msg with valid credentials" do
      res = Giftbit.account

      expect(res["info"]["name"]).to eql "Credentials are valid"
    end

    it "returns Unauthorized Msg with invalid credentials" do
      Giftbit.auth = "notavalidtoken"
      res = Giftbit.account

      expect(res["text"]).to eql "Unauthorized"
      expect(res["status"]).to eql 401
    end
  end

  describe "#marketplace" do
    it "list all gifts" do
      res = Giftbit.marketplace
      expect(res["info"]["name"]).to eql "Marketplace Gifts Retrieved"
    end

    it "list all gifts by vendor" do
      res = Giftbit.marketplace(vendor:6)
      expect(res["total_count"]).to be >= 0
    end

    it "display list of gifts limits" do
      res = Giftbit.marketplace(limit:5)
      expect(res["total_count"]).to be >= 0
    end
  end

  describe "#regions" do
    it "list all 36 regions from giftbit database" do
      res = Giftbit.regions
      expect(res["regions"].count).to eql 36 #TODO: make this a dynamic fetch compare
    end

    it "returns Regions Retrieved Msg" do
      res = Giftbit.regions
      expect(res["info"]["name"]).to eql "Marketplace Regions Retrieved"
    end
  end

  describe "#vendors" do
    it "list all 76 vendor from giftbit database" do
      res = Giftbit.vendors
      expect(res["vendors"].count).to eql 80 #TODO: make this a dynamic fetch compare
    end

    it "returns Retrieved Vendors Msg" do
      res = Giftbit.vendors
      expect(res["info"]["name"]).to eql "Marketplace Vendors Retrieved"
    end
  end

  describe "#categories" do
    it "list all 15 categories from giftbit database" do
      res = Giftbit.categories
      expect(res["categories"].count).to eql 15
    end

    it "returns Retrieved Categories Msg" do
      res = Giftbit.categories
      expect(res["info"]["name"]).to eql "Marketplace Categories Retrieved"
    end
  end

  describe "#campaign" do
    it "list all campaigns created" do
      res = Giftbit.campaign
      expect(res["info"]["name"]).to eql "Campaign Retrieved"
    end

    it "can fetch campaign with ID provided" do
      data_fetch = data
      data_fetch[:id] = "GiftbitGift#{Time.now.utc.to_i}"
      gift = Giftbit.creategift(data_fetch) 

      res = Giftbit.campaign(id: gift["info"]["id"])

      expect(res["info"]["id"]).to eql res["info"]["id"]
      expect(res["info"]["name"]).to eql "Campaign Retrieved"
    end

    after(:all) do
      @cp_list = Giftbit.campaign 

      @cp_list["campaigns"].map do |campaign|
        if (campaign["id"].include? "GiftbitGift") && campaign["status"] == "QUOTE"
          res = Giftbit.deletegift(campaign["id"])
        end
      end
    end
  end

  describe "#creategift" do
    it "create quote for gift default" do
      data_create = data
      data_create[:id] = "GiftbitGift#{Time.now.utc.to_i}"
      gift_create = Giftbit.creategift(data_create)

      expect(gift_create["info"]["name"]).to eql "Campaign Quote"
    end

    it "sends gift right away if quote is set to false " do
      data[:id] = "GiftbitGift#{Time.now.utc.to_i}"
      data[:quote] = false

      gift = Giftbit.creategift(data)

      expect(gift["info"]["name"]).to eql "Campaign Created"
    end

    after(:all) do
      @cp_list = Giftbit.campaign 

      @cp_list["campaigns"].map do |campaign|
        if (campaign["id"].include? "GiftbitGift") && campaign["status"] == "QUOTE"
          res = Giftbit.deletegift(campaign["id"])
        end
      end
    end
  end

  describe "#sendgift" do
    it "sends quoted gift with ID" do
      data[:id] = "GiftbitGift#{Time.now.utc.to_i}"
      data[:quote] = true
      gift = Giftbit.creategift(data) 

      #this is step is approval of quote gift
      res = Giftbit.sendgift(gift["campaign"]["id"]) 

      expect(res["info"]["name"]).to eql "Campaign Created"
    end
  end

  describe "#deletegift" do
    it "deletes the gift with ID" do
      data_del = data
      data_del[:id] = "GiftbitGift#{Time.now.utc.to_i}"
      gift = Giftbit.creategift(data_del)

      res = Giftbit.deletegift(gift["campaign"]["id"])
      expect(res["info"]["name"]).to eql "Campaign Deleted"
    end
  end

  describe "#getrequest" do
    it "raise an error if no argument" do
      expect { Giftbit.get }.to raise_error(ArgumentError)
    end
  end

  describe "#postrequest" do
    it "raise and error if no argument" do
      expect { Giftbit.post }.to raise_error(ArgumentError)
    end
  end
end
