require 'rails_helper'

RSpec.describe Orchestration do
  it "returns an expected JSON object" do 
    json_data = JSON.load(file_fixture("houndify_response.json").read)
    Houndify.any_instance.stub(:query).and_return(json_data)

    o = Orchestration.new("What is the weather in Pensacola, FL?", "Houndify")
    response = o.orchestrate
    expect(response).to eq (
        {:answer=>"{\"answer\":\"The weather is 84 °F and mostly cloudy near Prosper, Texas.\",\"instructions\":{\"emotionalTone\":[{\"tone\":\"happiness\",\"value\":0.5,\"start\":2,\"duration\":4,\"additive\":true,\"default\":true}],\"displayHtml\":{\"html\":\"<link rel='stylesheet' href='//static.midomi.com/corpus/H_Zk82fGHFX/build/css/templates.min.css'><script src='//static.midomi.com/corpus/H_Zk82fGHFX/build/js/templates.min.js'></script><div class='h-template h-image-carousel-wrapper'>   <div class='h-image-carousel h-image-carousel-Small' data-carousel-id=h-image-carousel-0><img src=http://static.midomi.com/h/images/w/weather_mostlycloudy.png>   </div> </div> <div class='h-template h-two-col-table-wrapper'>   <table class='h-template-table h-two-col-table pure-table pure-table-horizontal'>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Temperature       </td>       <td class='h-template-cell h-two-col-table-right-text'>84 °F       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Temperature Feels Like       </td>       <td class='h-template-cell h-two-col-table-right-text'>90 °F       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Wind Chill       </td>       <td class='h-template-cell h-two-col-table-right-text'>85 °F       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Dew Point       </td>       <td class='h-template-cell h-two-col-table-right-text'>72 °F       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Percent Humidity       </td>       <td class='h-template-cell h-two-col-table-right-text'>66%       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Visibility       </td>       <td class='h-template-cell h-two-col-table-right-text'>9 mi       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Precipitation for the Next Hour       </td>       <td class='h-template-cell h-two-col-table-right-text'>0 in       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Precipitation Today       </td>       <td class='h-template-cell h-two-col-table-right-text'>0.9 in       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Wind       </td>       <td class='h-template-cell h-two-col-table-right-text'>4 mph 338°NNW       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Wind Gust       </td>       <td class='h-template-cell h-two-col-table-right-text'>7 mph       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Barometric Pressure       </td>       <td class='h-template-cell h-two-col-table-right-text'>29.94 inHg and Steady       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>UV Index       </td>       <td class='h-template-cell h-two-col-table-right-text'>0 (Low)       </td>     </tr>   </table> </div> \"}}}", :matchedContext=>"", :conversationPayload=>""}
    )   
  end

  it "handles over daily limit Houndify error" do
    json_data = {Error: "Over daily limit\n"}
    Houndify.any_instance.stub(:query).and_return(json_data)

    o = Orchestration.new("What is the weather in Pensacola, FL?", "Houndify")
    response = o.orchestrate
    expect(response).to eq (
        {:answer=>"{\"answer\":\"Sorry, I cannot answer that right now\",\"instructions\":{\"emotionalTone\":[{\"tone\":\"happiness\",\"value\":0.5,\"start\":2,\"duration\":4,\"additive\":true,\"default\":true}],\"displayHtml\":{\"html\":null}}}", :conversationPayload=>"", :matchedContext=>""}
    )
  end
end