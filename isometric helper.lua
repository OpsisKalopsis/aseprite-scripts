local downscale = false

function CopyImage(fromImage, rect, newImageSize)
  local pixelsFromSelection = fromImage:pixels(rect)
  local selectedImage = Image(newImageSize.x, newImageSize.y)
  
  for it in pixelsFromSelection do
    local pixelValue = it()
    selectedImage:putPixel(it.x - rect.x, it.y - rect.y, pixelValue)
  end
  return selectedImage
end

function SlideImage(fromImage, rect, isFront)
  local pixelsFromSelection = fromImage:pixels(rect)
  local slidedImage = Image(rect.width, rect.height + rect.width/2)
  local yOffset = 0
  local yStartOffset = 0
  local walker = 1

  if(isFront) then
    yStartOffset = rect.width / 2
    yOffset = yStartOffset
    walker = -1
  end

  for it in pixelsFromSelection do
    local pixelValue = it()
    local newX = it.x - rect.x
    local newY = it.y - rect.y
    if(newX % 2 == 0) then
      yOffset = yOffset + walker
    end

    if(newX == 0) then
      yOffset = yStartOffset
    end
    slidedImage:putPixel(newX, newY + yOffset, pixelValue)
  end
  return slidedImage
end

--loop through x texture coords
function ToIso(fromImage, rect, newImageSize)
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

function RefreshCanvas()
  --should be a nicer solution
  app.command.Undo()
  app.command.Redo()
end

function ValidateSelection(sprite, selection)
  -- bail if there's no active sprite
  
  if not sprite then 
      print("No sprite")
      return false
  end

  -- bail if nothing's selected
  if selection.isEmpty then 
      print("Missing selection")
      return false
  end

  if selection.bounds.width % 2 ~= 0 then
    print("The width must be an even number")
    return false
  end

  if selection.bounds.width ~= selection.bounds.height then
    print("The selection must be a square")
    return false
  end

  return true
end

function ToogleDownscale()
  downscale = not downscale
end

function ConvertToSide()
  local sprite = app.activeSprite
  local selection = sprite.selection
  originPoint = selection.origin
  if(not ValidateSelection(sprite, selection)) then
    return
  end

  local currentImage = Image(sprite)
  local selectedImage = SlideImage(currentImage, selection.bounds, false)

  app.transaction(
    function()
      local outputLayer = sprite:newLayer()
      outputLayer.name = "IsometricSide"
      local outputSprite = outputLayer.sprite
      local cel = sprite:newCel(outputLayer, 1)
      local backToOriginImage = Image(outputSprite.width,outputSprite.height)
      backToOriginImage:drawImage(selectedImage, originPoint)
      cel.image = backToOriginImage
    end
  )
  RefreshCanvas()
end

function ConvertToFront()
  local sprite = app.activeSprite
  local selection = sprite.selection
  local originPoint = selection.origin
  if(not ValidateSelection(sprite, selection)) then
    return
  end

  local currentImage = Image(sprite)
  local selectedImage = SlideImage(currentImage, selection.bounds, true)

  app.transaction(
    function() 

      local outputLayer = sprite:newLayer()
      outputLayer.name = "IsometricFront"
      local outputSprite = outputLayer.sprite
      local cel = sprite:newCel(outputLayer, 1)
      local backToOriginImage = Image(outputSprite.width,outputSprite.height)
      backToOriginImage:drawImage(selectedImage, originPoint)
      cel.image = backToOriginImage
    end
  )
  RefreshCanvas()
end

function ConvertToTile()
  local sprite = app.activeSprite
  local selection = sprite.selection
  local originPoint = selection.origin
  if(not ValidateSelection(sprite, selection)) then
    return
  end

  local isometricTile

  local currentImage = Image(sprite)
  local oneSide = selection.bounds.width
  local selectedImage = CopyImage(currentImage, selection.bounds, Point(oneSide, oneSide))

  isometricTile = ToIso(selectedImage, Rectangle(0,0,oneSide,oneSide), Point(oneSide * 4,oneSide * 2))

  if downscale then
    isometricTile:resize{width=(oneSide*2),height=oneSide}
    isometricTile = CopyImage(isometricTile, Rectangle(0,1,oneSide*2,oneSide), Point(oneSide*2,oneSide))
  else
    isometricTile = CopyImage(isometricTile, Rectangle(0,1,oneSide*4,oneSide*2), Point(oneSide*4,oneSide*2))
  end

  app.transaction(
    function() 
      local outputLayer = sprite:newLayer()
      outputLayer.name = "IsometricTile"
      local outputSprite = outputLayer.sprite
      
      local backToOriginImage = Image(outputSprite.width,outputSprite.height)
      backToOriginImage:drawImage(isometricTile, originPoint)
      local cel = outputSprite:newCel(outputLayer, 1)
      cel.image = backToOriginImage
    end
    )
    RefreshCanvas()
end

local dialog = Dialog("Isometric Toolbar")
dialog
  :button{text="Side",onclick=ConvertToSide}
  :button{text="Front",onclick=ConvertToFront}
  :separator()
  :button{text="Tile",onclick=ConvertToTile}
  :newrow()
  :check{id="downscale", text="downscale", onclick=ToogleDownscale}
  :show{wait=false}