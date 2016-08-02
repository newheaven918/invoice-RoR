require 'rails_helper'

RSpec.describe "Api::V1::Payments", type: :request do

  before do
    Rails.cache.clear
    FactoryGirl.create :token
    FactoryGirl.create :user
    @headers = {'Content-Type' => 'application/json', 
        'Authorization' => 'Token token="123token"'}
    @tax = FactoryGirl.create :tax
    @retention = FactoryGirl.create :tax_retention
  end

  describe 'Taxes show' do
    it 'GET /api/v1/taxes/:id' do
      get api_v1_tax_path(@tax), nil, @headers
      expect(response).to be_success
      expect(json['name']).to eql 'VAT 21%'
    end
  end

  describe 'Taxes listing' do
    it 'GET /api/v1/taxes' do
      get api_v1_taxes_path, nil, @headers
      expect(response).to be_success
      expect(json.length).to eql 2
      expect(json[1]['name']).to eql 'RETENTION'
    end
  end

  describe 'Taxes creation' do
    it 'POST /api/v1/taxes' do
      tx = {
        'tax' => {
          'name' => 'newTAX',
          'value' => 33
        }
      }
      post api_v1_taxes_path, tx.to_json, @headers
      expect(response).to be_success
      expect(json['name']).to eql 'newTAX'
      # in db, too
      expect(Tax.find(json['id']).name).to eql 'newTAX'
      # location header
      expect(response.headers['Location']).to eql api_v1_tax_url(json['id'])
    end
  end

  describe 'Tax updating' do
    it 'PUT /api/v1/taxes/:id' do
      mod = {
        'tax' => {
          'name' => 'modTAX',
          'default' => true
        }
      }
      put api_v1_tax_url(@tax), mod.to_json, @headers
      expect(response).to be_success
      # name modified
      expect(json['name']).to eql 'modTAX'
      # in db, too
      expect(Tax.find(json['id']).name).to eql 'modTAX'
    end
  end

  describe 'Tax deletion' do
    it 'DELETE /api/v1/taxes/:id' do
      delete api_v1_tax_path(@tax), nil, @headers
      expect(response).to have_http_status :no_content
      expect(Tax.find_by_id(@tax.id)).to be_nil
    end
  end

end
