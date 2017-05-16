require 'giftbit'
require 'vcr'
require 'webmock'

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = true
end

def retry_request(cassette)
  if cassette.recording?
    VCR.eject_cassette

    response = yield
    attempts = 1

    until response || attempts > 12 do
      sleep 5
      response = yield
      attempts += 1
    end

    VCR.insert_cassette(cassette.name, record: :new_episodes)
  end

  yield
end

describe Giftbit do
  let(:auth) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJTSEEyNTYifQ==.TFdWYU5VTVhzK3JFaVhHT2p5VDRHNFRsUk1ybnk2V2E4TDNDSW5meEdXdTVERUJNeHlDTEU1K216Qk1hb3Q4QlZaTVJvWndjR2ZoS01xc3gzdnZMUHdQckN1Z0kreG9rYVF3c1JjUjNkNlNLVmROQTlJb0hvMmpHdkx2REh3NXE=.cu7N3bPxGg8fPxFsIUcjyOISwn+29YpB0l7YDHwkMDg=' }
  let :data do
    {
      id: "GiftbitGift#{Time.now.utc.to_i}",
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

  context 'authentication' do
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
  end

  describe '.each_auth' do
    it 'returns each auth' do
      Giftbit.auths = {default: auth, custom: 'foo'}

      times_called = 0

      Giftbit.each_auth do |api|
        times_called += 1

        expect(api).to be_an_instance_of Giftbit
        expect([auth, 'foo']).to include api.auth
      end

      expect(times_called).to eq 2
    end
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

      context 'requests' do
        it 'parses JSON for a successful request' do
          VCR.use_cassette('request-200') do
            json = api.create_gift(data)

            expect(json['status']).to eql 200
          end
        end

        it 'parses JSON for a client error' do
          VCR.use_cassette('request-400') do
            json = api.create_gift

            expect(json['status']).to eql 422
            expect(json).to have_key 'error'
          end
        end

        it 'creates JSON for a server error' do
          VCR.use_cassette('request-500') do
            json = api.create_gift

            expect(json['status']).to eql 503
            expect(json.dig('error', 'message')).to include '<html>'
          end
        end
      end

      describe '#account' do
        it 'returns welcome message with valid credentials' do
          VCR.use_cassette('account-valid') do
            res = api.account

            expect(res['info']['name']).to eql 'Credentials are valid'
          end
        end

        it 'returns unauthorized message with invalid credentials', invalid_auth: true do
          VCR.use_cassette('account-invalid') do
            res = api.account

            expect(res['text']).to eql 'Unauthorized'
            expect(res['status']).to eql 401
          end
        end
      end

      describe '#funds' do
        it 'returns funds info' do
          VCR.use_cassette('funds') do
            res = api.funds
            expect(res['info']['name']).to eql 'Fund information retrieved'
            expect(res['fundsbycurrency']['USD']['available_in_cents']). to be >= 0
          end
        end
      end

      describe '#marketplace' do
        it 'lists all gifts' do
          VCR.use_cassette('marketplace-all') do
            res = api.marketplace

            expect(res['info']['name']).to eql 'Marketplace Gifts Retrieved'
          end
        end

        it 'lists all gifts by vendor' do
          VCR.use_cassette('marketplace-by-vendor') do
            res = api.marketplace vendor: 6

            expect(res['total_count']).to be >= 0
          end
        end
      end

      describe '#regions' do
        it 'lists all regions' do
          VCR.use_cassette('regions-all') do
            res = api.regions

            expect(res['regions'].count).to eql 4
          end
        end
      end

      describe '#vendors' do
        it 'list all vendors' do
          VCR.use_cassette('vendors-all') do
            res = api.vendors

            expect(res['vendors'].count).to eql 27
          end
        end
      end

      describe '#campaign' do
        it 'list all campaigns created' do
          VCR.use_cassette('campaign-all') do
            res = api.campaign

            expect(res['campaigns'].count).to be >= 5
          end
        end

        it 'can fetch campaign with ID provided' do
          VCR.use_cassette('campaign-by-id') do
            gift = api.create_gift(data)

            res = api.campaign(id: gift['info']['id'])

            expect(res['info']['id']).to eql gift['info']['id']
          end
        end
      end

      describe '#gifts' do
        it 'can fetch the gifts for a given campaign' do
          VCR.use_cassette('gifts') do
            gifts = api.gifts

            expect(gifts['gifts'].length).to be > 0
          end
        end
      end

      describe '#create_gift' do
        it 'creates a gift' do
          VCR.use_cassette('create_gift') do
            gift = api.create_gift(data)

            expect(gift['info']['name']).to eql 'Campaign Created'
          end
        end
      end

      describe '#resend_gift' do
        it 'can re-send an email for a given campaign gift' do
          VCR.use_cassette('resend_gift') do |cassette|
            gift = api.create_gift(data)
            gift = retry_request(cassette) do
              api.gifts(campaign_uuid: gift['campaign']['uuid'])['gifts'].first
            end
            res = api.resend_gift(gift['uuid'])

            expect(res['info']['code']).to eql 'INFO_GIFTS_RESENT'
          end
        end
      end

      describe '#get_links' do
        it 'returns link status' do
          VCR.use_cassette('get_links') do
            data[:delivery_type] = 'SHORTLINK'
            gift = api.create_gift(data)

            res = api.get_links(gift['campaign']['id'])

            expect(res['info']['code']).to eql 'INFO_LINKS_GENERATION_IN_PROGRESS'
          end
        end
      end
    end
  end
end
