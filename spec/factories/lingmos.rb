# frozen_string_literal: true

FactoryBot.define do
  factory :lingmo do
    token { '2ZCKr5iD))DVtCRabSXIA_7sC=yJkeHYffI5vd)UVYmzc5ePP2' }
    owner { 'Uneeq' }
    lingmo_id { 36_483 }
    expiration_timestamp { Time.at(1584365600) }
    request_endpoint { 'AssignSession' }
  end
end
