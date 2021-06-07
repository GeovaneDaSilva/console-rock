json.cache! ["v1/threat-map-config"] do
  json.renderAmount 5
  json.pathRate 250
  json.iconSize 28
  json.fadeOutDelay 1000
  json.maxFeedLength 500
  json.originIconUrl asset_url("threat-map-origin.svg")
  json.targetIconUrl asset_url("threat-map-target.svg")
  json.originColor "#d02149"
  json.targetColor "#fd0"

  json.vectorMap do
    json.map "world_mill"
    json.backgroundColor "#f6f8f8"
    json.zoomOnScroll false
    json.zoomStep 0
    json.regionStyle do
      json.hover do
        json.set! "fill-opacity", 1
      end
    end
    json.regionLabelStyle do
      json.initial do
        json.set! "font-family", "inherit"
      end
      json.hover do
        json.color "white"
      end
    end
  end
end
