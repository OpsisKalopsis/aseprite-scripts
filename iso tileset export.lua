local downscale = false

local currentImage = {
  width = app.activeSprite.width, 
  height = app.activeSprite.height, 
}

local path,title = app.activeSprite.filename:match("^(.+[/\\])(.-).([^.]*)$")

function ToogleDownscale()
  downscale = not downscale
end

function ValidateInput(dialogData)
  local tileWidth = dialogData.tileWidth
  if(tileWidth % 2 ~= 0) then
    print("The Width/Height value must be an even number")
    return false
  end
  return true
end

function CopyImage(fromImage, rect, newImageSize)
  local pixelsFromSelection = fromImage:pixels(rect)
  local selectedImage = Image(newImageSize.x, newImageSize.y)
  
  for it in pixelsFromSelection do
    local pixelValue = it()
    selectedImage:putPixel(it.x - rect.x, it.y - rect.y, pixelValue)
  end
  return selectedImage
end

function PlotImage(fromImage, toImage, putPoint)
  for pix in fromImage:pixels() do
    local pixelValue = pix()
    toImage:putPixel(pix.x + putPoint.x, pix.y + putPoint.y, pixelValue)
  end 
end

function CreateIsoTile(fromImage, rect, newImageSize)
  local pixelsFromSelection = fromImage:pixels(rect)
  local selectedImage = Image(newImageSize.x, newImageSize.y)

  for it in pixelsFromSelection do
    local pixelValue = it()
    
    local newx = (newImageSize.x/2-2)+it.x*2-it.y*2
    local newy = it.x+it.y
    local stopx = newx+3
    for tempx=newx,stopx,1 do
      --add one to y axis so the resize would work
      selectedImage:putPixel(tempx, newy+1, pixelValue)
    end
  end
  return selectedImage
end

function ConvertToIso(dialogData)
  local tileWidth = dialogData.tileWidth
  local savePath = dialogData.filename
  local sprite = app.activeSprite
  local fromImage = Image(sprite)
  
  local numberOfWidthTiles = math.floor(currentImage.width / tileWidth)
  local numberOfHeightTiles = math.floor(currentImage.height / tileWidth)
  local newWidth = tileWidth * 4
  local newHeight = tileWidth * 2

  local newImageWidth = numberOfWidthTiles * newWidth
  local newImageHeight = numberOfHeightTiles * newHeight
  local tileSize = Point(tileWidth * 4,tileWidth * 2)
  local newImage = Image(newImageWidth, newImageHeight)
  
  if(downscale) then
    newImage:resize(newImage.width/2, newImage.height/2)
    newWidth = newWidth/2
    newHeight = newHeight/2
  end
  
  for columns = 0, numberOfHeightTiles - 1 do
    for rows = 0, numberOfWidthTiles - 1 do
      local toRect = Rectangle(rows*newWidth, columns*newHeight, newWidth, newHeight)
      local fromRect = Rectangle(rows*tileWidth, columns*tileWidth, tileWidth, tileWidth)
      --Move current image to 0,0 to skip working with offsets
      local resetImage = CopyImage(fromImage, fromRect, Point(tileWidth, tileWidth))
      local isometricTile = CreateIsoTile(resetImage, Rectangle(0,0,tileWidth, tileWidth), tileSize)
      if downscale then
        isometricTile:resize{width=(tileWidth*2),height=tileWidth}
        isometricTile = CopyImage(isometricTile, Rectangle(0,1,tileWidth*2,tileWidth), Point(tileWidth * 2, tileWidth))
      else
        isometricTile = CopyImage(isometricTile, Rectangle(0,1,tileWidth*4,tileWidth*2), tileSize)
      end
      PlotImage(isometricTile,newImage,toRect)
    end
  end

  newImage:saveAs(savePath)
end


local dialog = Dialog("Isometric Tileset export")
dialog
  :slider{id="tileWidth",
  min=4,
  max=currentImage.width,
  value=16,
  label="Width/Height of tiles:" }
  :newrow()
  :check{id="downscale", text="downscale", onclick=ToogleDownscale}
  :file{ id="filename",
        label="Filename:",
        title="Filename to save to",
        open=false,
        save=true,
        filename=path .. "iso-" .. title .. ".png",
        filetypes={ "png" }}
  :separator()
  :button{text="Export",onclick=function() 
    if(ValidateInput(dialog.data)) then
      ConvertToIso(dialog.data)
      dialog:close() 
    end
  end}
  :show{wait=true}