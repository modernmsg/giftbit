require 'giftbit'

describe Giftbit do
  let(:auth) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJTSEEyNTYifQ==.TFdWYU5VTVhzK3JFaVhHT2p5VDRHNFRsUk1ybnk2V2E4TDNDSW5meEdXdTVERUJNeHlDTEU1K216Qk1hb3Q4QlZaTVJvWndjR2ZoS01xc3gzdnZMUHdQckN1Z0kreG9rYVF3c1JjUjNkNlNLVmROQTlJb0hvMmpHdkx2REh3NXE=.cu7N3bPxGg8fPxFsIUcjyOISwn+29YpB0l7YDHwkMDg=' }
  let :data do
    {
      message: 'Thank you for being an awesome person',
      subject: 'Present from Community Rewards',
      contacts: [firstname: 'Sean', lastname: 'Linsley', email: 'sean@modernmsg.com'],
      marketplace_gifts: [id: 1, price_in_cents: 5000]
    }
  end

  after do
    Giftbit.auth  = nil
    Giftbit.auths = nil
  end

  it 'errors without auth' do
    expect{
      Giftbit.account
    }.to raise_error 'you must set an auth token at application boot'
  end

  it 'errors without auth, but auths set' do
    Giftbit.auths = {default: auth}

    expect{
      Giftbit.account
    }.to raise_error 'you must init a new API instance with the auth you want to use'
  end

  it 'errors for unregistered auth' do
    Giftbit.auths = {default: auth}

    expect{
      Giftbit.new(auth: :foo).account
    }.to raise_error KeyError, 'key not found: :foo'
  end

  it 'errors when both auth and auths are set' do
    Giftbit.auth  = auth
    Giftbit.auths = {default: auth}

    expect{
      Giftbit.account
    }.to raise_error "auth and auths can't both be set"

    expect{
      Giftbit.new(auth: :default).account
    }.to raise_error "auth and auths can't both be set"
  end

  it '.each_auth' do
    Giftbit.auths = {default: auth, custom: 'foo'}

    times_called = 0

    Giftbit.each_auth do |api|
      times_called += 1

      expect(api).to be_an_instance_of Giftbit
      expect([auth, 'foo']).to include api.auth
    end

    expect(times_called).to eq 2
  end

  [:class, :instance].each do |variant|
    describe "(#{variant})" do
      before do |example|
        if variant == :class
          Giftbit.auth = example.metadata[:invalid_auth] ? 'notavalidtoken' : auth
        else
          Giftbit.auths = {default: auth}
          Giftbit.auths.merge! invalid: 'notavalidtoken' if example.metadata[:invalid_auth]
        end
      end

      let :api do |example|
        if variant == :class
          Giftbit
        else
          auth = example.metadata[:invalid_auth] ? :invalid : :default
          Giftbit.new auth: auth
        end
      end

      describe '#account' do
        it 'returns welcome message with valid credentials' do
          res = api.account

          expect(res['info']['name']).to eql 'Credentials are valid'
        end

        it 'returns unauthorized message with invalid credentials', invalid_auth: true do
          res = api.account

          expect(res['text']).to eql 'Unauthorized'
          expect(res['status']).to eql 401
        end
      end

      describe '#marketplace' do
        it 'lists all gifts' do
          res = api.marketplace
          expect(res['info']['name']).to eql 'Marketplace Gifts Retrieved'
        end

        it 'lists all gifts by vendor' do
          res = api.marketplace vendor: 6
          expect(res['total_count']).to be >= 0
        end
      end

      describe '#regions' do
        it 'lists all regions' do
          res = api.regions
          expect(res['regions'].count).to eql 36
        end

        it 'returns Regions Retrieved message' do
          res = api.regions
          expect(res['info']['name']).to eql 'Marketplace Regions Retrieved'
        end
      end

      describe '#vendors' do
        it 'list all vendors' do
          res = api.vendors
          expect(res['vendors'].count).to eql 24
        end

        it 'returns Vendors Retrieved message' do
          res = api.vendors
          expect(res['info']['name']).to eql 'Marketplace Vendors Retrieved'
        end
      end

      describe '#categories' do
        it 'lists all categories' do
          res = api.categories
          expect(res['categories'].count).to eql 15
        end

        it 'returns Categories Retrieved message' do
          res = api.categories
          expect(res['info']['name']).to eql 'Marketplace Categories Retrieved'
        end
      end

      describe '#campaign' do
        it 'list all campaigns created' do
          res = api.campaign
          expect(res['campaigns'].count).to be >= 5
          expect(res['info']['name']).to eql 'Campaign Retrieved'
        end

        it 'can fetch campaign with ID provided' do
          data[:id] = "GiftbitGift#{Time.now.utc.to_i}"
          gift = api.create_gift(data)

          sleep 5

          res = api.campaign(id: gift['info']['id'])

          expect(res['info']['id']).to eql gift['info']['id']
          expect(res['info']['name']).to eql 'Campaign Retrieved'
        end

        after  do
          api.campaign['campaigns'].map do |campaign|
            if campaign['id'].include?('GiftbitGift') && campaign['status'] == 'QUOTE'
              api.delete_gift campaign['id']
            end
          end
        end
      end

      describe '#create_gift' do
        it 'create quote for gift default' do
          data[:id] = "GiftbitGift#{Time.now.utc.to_i}"
          gift = api.create_gift(data)

          expect(gift['info']['name']).to eql 'Campaign Quote'
        end

        it 'sends gift right away if quote is set to false' do
          data[:id]    = "GiftbitGift#{Time.now.utc.to_i}"
          data[:quote] = false

          gift = api.create_gift(data)

          expect(gift['info']['name']).to eql 'Campaign Created'
        end

        after do
          api.campaign['campaigns'].map do |campaign|
            if campaign['id'].include?('GiftbitGift') && campaign['status'] == 'QUOTE'
              api.delete_gift campaign['id']
            end
          end
        end
      end

      describe '#send_gift' do
        it 'sends quoted gift with ID' do
          data[:id]    = "GiftbitGift#{Time.now.utc.to_i}"
          data[:quote] = true
          gift = api.create_gift(data)

          sleep 5

          res = api.send_gift(gift['campaign']['id'])

          expect(res['info']['name']).to eql 'Campaign Created'
        end
      end

      describe '#delete_gift' do
        it 'deletes the gift with ID' do
          data[:id] = "GiftbitGift#{Time.now.utc.to_i}"
          gift = api.create_gift(data)

          sleep 5

          res = api.delete_gift(gift['campaign']['id'])
          expect(res['info']['name']).to eql 'Campaign Deleted'
        end
      end

      describe '#gifts' do
        it 'can fetch the gifts for a given campaign' do
          data[:id]    = "GiftbitGift#{Time.now.utc.to_i}"
          data[:quote] = false
          gift = api.create_gift(data)

          sleep 30

          gifts = api.gifts(campaign_uuid: gift['campaign']['uuid'])
          expect(gifts['gifts'].length).to be > 0

          gifts['gifts'][0].tap do |g|
            expect(g['campaign_uuid']).to eql gift['campaign']['uuid']
            expect(g['status']).to eql 'SENT_AND_REDEEMABLE'
            expect(g['delivery_status']).to eql 'DELIVERED'
            expect(g['redeemed_date']).to eql nil
            expect(g['management_dashboard_link']).to eql "http://testbedapp.giftbit.com/campaign/campaignInfo?uuid=#{gift['campaign']['uuid']}&gift_uuid=#{g['uuid']}"
          end
        end

        it 'can re-send an email for a given campaign gift' do
          data[:id]    = "GiftbitGift#{Time.now.utc.to_i}"
          data[:quote] = false
          gift = api.create_gift(data)

          sleep 15

          gift = api.gifts(campaign_uuid: gift['campaign']['uuid'])['gifts'].first

          res = api.resend_gift(gift['uuid'])

          expect(res['info']['code']).to eql 'INFO_GIFTS_RESENT'
        end

        after do
          api.campaign['campaigns'].map do |campaign|
            if campaign['id'].include?('GiftbitGift') && campaign['status'] == 'QUOTE'
              api.delete_gift campaign['id']
            end
          end
        end
      end

      describe '#get_links' do
        it 'returns link status' do
          data[:id]            = "GiftbitGift#{Time.now.utc.to_i}"
          data[:delivery_type] = 'SHORTLINK'
          gift = api.create_gift(data)

          sleep 5

          res = api.get_links(gift['campaign']['id'])

          expect(res['info']['code']).to eql 'INFO_LINKS_GENERATION_IN_PROGRESS'
        end
      end
    end
  end
end
