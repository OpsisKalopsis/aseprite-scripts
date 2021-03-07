-- recept
-- dra ut plus en på alla sidor
-- rotera 45 grader
-- dra ihop ifrån toppen typ 48%
-- Markeringen skall vara tre pixlar över om det är 16x16
-- Markeringen skall vara 6 pixlar över om det är 32x32

local activeFrame = 1
local originPoint


-- bail if there's no active sprite
local sprite = app.activeSprite
if not sprite then 
    print("No sprite")
    return 
end

-- bail if nothing's selected
local selection = sprite.selection
if selection.isEmpty then 
    print("Missing selection")
    return 
end

function CopyImage(fromImage, rect, newImageSize)
  widthCorrection = widthCorrection or 0
  heightCorrection = heightCorrection or 0
  local pixelsFromSelection = fromImage:pixels(rect)
  local selectedImage = Image(newImageSize.x, newImageSize.y)
  
  for it in pixelsFromSelection do
    local pixelValue = it()
    selectedImage:putPixel(it.x - rect.x, it.y - rect.y, pixelValue)
  end
  return selectedImage
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

  selectedImage:putPixel(newImageSize.x - 1, newImageSize.y - 1, redPixel)
  return selectedImage
end

local isometricTile

if selection.bounds.width == 16 and selection.bounds.height == 16 then
  -- do for 16x16
  local currentImage = Image(sprite)
  local selectedImage = CopyImage(currentImage, selection.bounds, Point(16,16))
  originPoint = selection.origin
 
  isometricTile = ToIso(selectedImage, Rectangle(0,0,16,16), Point(64,32))

  isometricTile:resize{width=32,height=16}
  
elseif selection.bounds.width == 32 and selection.bounds.height == 32 then
  -- do for 32x32
  local currentImage = Image(sprite)
  local selectedImage = CopyImage(currentImage, selection.bounds, Point(32,32))
  originPoint = selection.origin

  isometricTile = ToIso(selectedImage, Rectangle(0,0,32,32), Point(128,64))

  isometricTile:resize{width=64,height=32}

else
  print("Only supports 16x16, 32x32 tiles")
  return
end


local outputLayer = sprite:newLayer()
outputLayer.name = "IsometricTile"
local outputSprite = outputLayer.sprite
local cel = sprite:newCel(outputLayer, activeFrame)
local backToOriginImage = Image(outputSprite.width,outputSprite.height)
--backToOriginImage:drawImage(newIso, originPoint)
backToOriginImage:drawImage(isometricTile, originPoint)
cel.image = backToOriginImage

