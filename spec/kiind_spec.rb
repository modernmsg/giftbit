require "kiind"

describe Kiind do
  let(:auth) { "eyJ0eXAiOiJKV1QiLCJhbGciOiJTSEEyNTYifQ==.L2tzL3NnVHRKZUswZVhQSExTc0M4MzV6cUxmb2VucWR6emU2OVN5elVnQTU4cHEwY0Jvc0hCVFhidDhmb1o5dnE2dzFQV0JUNHhSUFRkTWU3cVdvY0E9PQ==.TpLYmrjpSsO1zPRgXOfukU2Mu16o+lVyIbmi9oZwHCY=" }

  let(:endpoint ) { "https://testbed.kiind.me/papi/v1/"}

  let(:data) { {message: "Thank you for being an awesome person", subject: "Present from ModemMsg", contacts: [{firstname: "Audee", lastname: "Velasco", email: "auds@adooylabs.com"}], marketplace_gifts: [{id:1, price_in_cents:5000}]} }

  before(:each) do
    Kiind.auth = auth
  end
  
  describe "#account" do
    it "returns Welcome Msg with valid credentials" do
      res = Kiind.account

      expect(res["info"]["name"]).to eql "Credentials are valid"
    end

    it "returns Unauthorized Msg with invalid credentials" do
      Kiind.auth = "notavalidtoken"
      res = Kiind.account

      expect(res["text"]).to eql "Unauthorized"
      expect(res["status"]).to eql 401
    end
  end

  describe "#marketplace" do
    it "list all gifts" do
      res = Kiind.marketplace
      expect(res["info"]["name"]).to eql "Marketplace Gifts Retrieved"
    end

    it "list all gifts by vendor" do
      res = Kiind.marketplace(vendor:6)
      expect(res["marketplace_gifts"].count).to eql 2 #this will fail if vendor added new card
    end

    it "display list of gifts limits" do
      res = Kiind.marketplace(limit:5)
      expect(res["marketplace_gifts"].count).to eql 5
    end
  end

  describe "#regions" do
    it "list all 36 regions from kiind database" do
      res = Kiind.regions
      expect(res["regions"].count).to eql 36 #TODO: make this a dynamic fetch compare
    end

    it "returns Regions Retrieved Msg" do
      res = Kiind.regions
      expect(res["info"]["name"]).to eql "Marketplace Regions Retrieved"
    end
  end

  describe "#vendors" do
    it "list all 76 vendor from kiind database" do
      res = Kiind.vendors
      expect(res["vendors"].count).to eql 76 #TODO: make this a dynamic fetch compare
    end

    it "returns Retrieved Vendors Msg" do
      res = Kiind.vendors
      expect(res["info"]["name"]).to eql "Marketplace Vendors Retrieved"
    end
  end

  describe "#categories" do
    it "list all 15 categories from kiind database" do
      res = Kiind.categories
      expect(res["categories"].count).to eql 15
    end

    it "returns Retrieved Categories Msg" do
      res = Kiind.categories
      expect(res["info"]["name"]).to eql "Marketplace Categories Retrieved"
    end
  end

  describe "#campaign" do
    it "list all campaigns created" do
      res = Kiind.campaign
      expect(res["info"]["name"]).to eql "Campaign Retrieved"
    end

    it "can fetch campaign with ID provided" do
      data_fetch = data
      data_fetch[:id] = "KiindGift#{Time.now.utc.to_i}"
      gift = Kiind.creategift(data_fetch) 

      res = Kiind.campaign(id: gift["info"]["id"])

      expect(res["info"]["id"]).to eql res["info"]["id"]
      expect(res["info"]["name"]).to eql "Campaign Retrieved"
    end

    after(:all) do
      puts "cleaning up... "

      @cp_list = Kiind.campaign 

      @cp_list["campaigns"].map do |campaign|
        if (campaign["id"].include? "KiindGift") && campaign["status"] == "QUOTE"
          res = Kiind.deletegift(campaign["id"])
        end
      end

      puts "done cleaning.. "
    end
  end

  describe "#creategift" do
    it "create quote for gift default" do
      data_create = data
      data_create[:id] = "KiindGift#{Time.now.utc.to_i}"
      gift_create = Kiind.creategift(data_create)

      expect(gift_create["info"]["name"]).to eql "Campaign Quote"
    end

    #FYI - I don't want to test here the actual sending since we are not allow
    # => to delete campaign that are sent or status:"Campaign Created" 

    # it "sends gift right away if quote is set to false " do
    #   data[:id] = "KiindGift#{Time.now.utc.to_i}"
    #   data[:quote] = false

    #   gift = Kiind.creategift(data)

    #   expect(gift["info"]["name"]).to eql "Campaign Created"
    # end

    after(:all) do
      puts "cleaning up... "

      @cp_list = Kiind.campaign 

      @cp_list["campaigns"].map do |campaign|
        if (campaign["id"].include? "KiindGift") && campaign["status"] == "QUOTE"
          res = Kiind.deletegift(campaign["id"])
        end
      end

      puts "done cleaning.. "
    end
  end

  #FYI - I don't want to test here the actual sending since we are not allow
  # => to delete campaign that are sent or status:"Campaign Created"
  # describe "#sendgift" do
  #   it "sends quoted gift with ID" do
  #     data[:id] = "KiindGift#{Time.now.utc.to_i}"
  #     gift = Kiind.creategift(data) 

  #     #this is step is approval of quote gift
  #     res = Kiind.sendgift(gift["campaign"]["id"]) 

  #     expect(res["info"]["name"]).to eql "Campaign Created"
  #   end
  # end

  #FYI: Only Status=QUOTE campaign can be deleted
  describe "#deletegift" do
    it "deletes the gift with ID" do
      data_del = data
      data_del[:id] = "KiindGift#{Time.now.utc.to_i}"
      gift = Kiind.creategift(data_del)

      res = Kiind.deletegift(gift["campaign"]["id"])
      expect(res["info"]["name"]).to eql "Campaign Deleted"
    end
  end

  describe "#getrequest" do
    it "raise an error if no argument" do
      expect { Kiind.getrequest }.to raise_error(ArgumentError)
    end
  end

  describe "#postrequest" do
    it "raise and error if no argument" do
      expect { Kiind.postrequest }.to raise_error(ArgumentError)
    end
  end

end
