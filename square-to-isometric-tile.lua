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

if selection.bounds.width ~= 16 and selection.bounds.height ~= 16 then
    print("Only supports 16x16 tiles")
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

function Rotate45Degress(image2Rotate)
    local RotationRand = 0.785398
    local maxSizeConst = 1.412
    local maskColor = image2Rotate.spec.transparentColor
    local maxSize = math.floor(image2Rotate.width * maxSizeConst)
    if math.floor(image2Rotate.height * maxSizeConst) > maxSize then
      maxSize = math.floor(image2Rotate.height * maxSizeConst)
    end
    if maxSize%2 == 1 then
      maxSize = maxSize + 1
    end
    -- maxSize is a even number
    local centeredImage = Image(maxSize, maxSize)
    -- center image2Rotate in the new image 'centeredImage'
    local image2RotatePosition = Point((centeredImage.width - image2Rotate.width) / 2, (centeredImage.height - image2Rotate.height) / 2)
    for y=image2RotatePosition.y, image2RotatePosition.y + image2Rotate.height - 1, 1 do
      for x=image2RotatePosition.x, image2RotatePosition.x + image2Rotate.width - 1, 1 do
        centeredImage:drawPixel(x, y, image2Rotate:getPixel(x - image2RotatePosition.x, y - image2RotatePosition.y))
      end
    end
  
    local pivot = Point(centeredImage.width / 2 - 0.5 + (image2Rotate.width % 2) * 0.5, centeredImage.height / 2 - 0.5 + (image2Rotate.height % 2) * 0.5)
    local outputImg = Image(centeredImage.width, centeredImage.height)
  
    for y = 0 , centeredImage.height-1, 1 do
      for x = 0, centeredImage.width-1, 1 do
        local oposite = pivot.x - x
        local adyacent = pivot.y - y
        local hypo = math.sqrt(oposite^2 + adyacent^2)
        if hypo == 0.0 then
          local px = centeredImage:getPixel(x, y)
          outputImg:drawPixel(x, y, px)
        else
          local currentAngle = math.asin(oposite / hypo)
          local resultAngle
          local u
          local v
          if adyacent < 0 then
            resultAngle = currentAngle + RotationRand
            v = - hypo * math.cos(resultAngle)
          else
            resultAngle = currentAngle - RotationRand
            v = hypo * math.cos(resultAngle)
          end
          u = hypo * math.sin(resultAngle)
          if centeredImage.width / 2 - u >= 0 and
            centeredImage.height / 2 - v >= 0 and
            centeredImage.height / 2 - v < centeredImage.height and
            centeredImage.width / 2 - u < centeredImage.width then
            local px = centeredImage:getPixel(centeredImage.width / 2 - u, centeredImage.height / 2 - v)
            if px ~= maskColor then
              outputImg:drawPixel(x, y, px)
            end
          end
        end
      end
    end 
    return outputImg
  end

local currentImage = Image(sprite)
local selectedImage = CopyImage(currentImage, selection.bounds, Point(16,16))
originPoint = selection.origin

selectedImage:resize{size=Size(selectedImage.width + 1, selectedImage.height + 1)}

local newImage = Rotate45Degress(selectedImage)

local resultImage = CopyImage(newImage, Rectangle(0,1,24,23), Point(24,23))

resultImage:resize(24,12)

local finalImage = CopyImage(resultImage, Rectangle(0,1,24,12), Point(24,11))

local outputLayer = sprite:newLayer()
outputLayer.name = "Hej"
local outputSprite = outputLayer.sprite
local cel = sprite:newCel(outputLayer, activeFrame)
print(outputSprite.width)
print(outputSprite.height)
local ultimaImage = Image(outputSprite.width,outputSprite.height)
ultimaImage:drawImage(finalImage, originPoint)
print(originPoint)
cel.image = ultimaImage

