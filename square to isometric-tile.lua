-- recept
-- dra ut plus en på alla sidor
-- rotera 45 grader
-- dra ihop ifrån toppen typ 48%
-- Markeringen skall vara tre pixlar över om det är 16x16
-- Markeringen skall vara 6 pixlar över om det är 32x32

local originPoint


-- bail if there's no active sprite
local sprite = app.activeSprite
local currentCel = app.activeCel
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

if selection.bounds.width % 2 ~= 0 then
  print("The width must be an even number")
  return
end

if selection.bounds.width ~= selection.bounds.height then
  print("The selection must be a square")
  return
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

local currentImage = Image(sprite.width, sprite.height)
currentImage:drawSprite(sprite, currentCel.frameNumber)
local oneSide = selection.bounds.width
local selectedImage = CopyImage(currentImage, selection.bounds, Point(oneSide, oneSide))

originPoint = selection.origin

isometricTile = ToIso(selectedImage, Rectangle(0,0,oneSide,oneSide), Point(oneSide * 4,oneSide * 2))

isometricTile:resize{width=(oneSide*2),height=oneSide}
isometricTile = CopyImage(isometricTile, Rectangle(0,1,oneSide*2,oneSide), Point(oneSide*2,oneSide))

local outputLayer = sprite:newLayer()
outputLayer.name = "IsometricTile"
local outputSprite = outputLayer.sprite
local cel = sprite:newCel(outputLayer, currentCel.frameNumber)
local backToOriginImage = Image(outputSprite.width,outputSprite.height)
--backToOriginImage:drawImage(newIso, originPoint)
backToOriginImage:drawImage(isometricTile, originPoint)
cel.image = backToOriginImage

