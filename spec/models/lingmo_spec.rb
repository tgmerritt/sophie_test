# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lingmo, type: :model do
  it 'instantiates an instance of Lingmo' do
    lingmo = build(:lingmo)
    expect(lingmo).to be_instance_of(Lingmo)
    expect(lingmo.token).to eq '2ZCKr5iD))DVtCRabSXIA_7sC=yJkeHYffI5vd)UVYmzc5ePP2'
    expect(lingmo.owner).to eq 'Uneeq'
    expect(lingmo.expiration_timestamp).to eq '2020-03-16 13:33:20'
    expect(lingmo.request_endpoint).to eq 'AssignSession'
  end

  describe 'Check 121 minutes into the future' do
    before do
      # We travel 121 minutes into the future from the Factory timestamp to check the expired? function
      travel_to (Time.at(1_584_365_600) + 121.minutes)
    end

    after do
      travel_back
    end

    it 'returns true for a token older than two hours' do
      lingmo = build(:lingmo)
      expect(lingmo.expired?).to be true
    end
  end

  describe 'Check 60 minutes into the future' do
    before do
      # We travel 60 minutes into the future from the Factory timestamp to check the expired? function
      travel_to (Time.at(1_584_365_600) + 60.minutes)
    end

    after do
      travel_back
    end

    it 'returns true for a token older than two hours' do
      lingmo = build(:lingmo)
      expect(lingmo.expired?).to be false
    end
  end

  describe 'GET request to Lingmo' do
    let(:lingmo_response) { instance_double(HTTParty::Response, body: lingmo_response_body) }
    let(:parsed_response) { JSON.parse(file_fixture('lingmo_get_response.json').read) }

    before do
      allow(HTTParty).to receive(:get).and_return(parsed_response)
    end

    it 'returns a new token from Lingmo and saves' do
      l = Lingmo.new
      l.get_token
      l.reload
      expect(l.token).to eq '2ZCKr5iD))DVtCRabSXIA_7sC=yJkeHYffI5vd)UVYmzc5ePP2'
      expect(l.expiration_timestamp).to eq Time.at(1_584_365_600)
      expect(l.owner).to eq 'Uneeq'
    end
  end

  describe 'GET request for translation' do
    let(:lingmo_response) { instance_double(HTTParty::Response, body: lingmo_response_body) }
    let(:parsed_response) { JSON.parse(file_fixture('lingmo_translation_response.json').read) }

    before do
      allow(HTTParty).to receive(:post).and_return(parsed_response)
      allow_any_instance_of(Lingmo).to receive(:expired?).and_return false
    end

    it 'returns a new token from Lingmo and saves' do
      response = Lingmo.new.translate('en-US', 'fr-FR', 'What is your name?')
      expect(response).to eq 'Quel est votre nom?'
    end
  end
end
