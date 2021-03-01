-- recept
-- dra ut plus en på alla sidor
-- rotera 45 grader
-- dra ihop ifrån toppen typ 48%
-- Markeringen skall vara tre pixlar över om det är 16x16
-- Markeringen skall vara 6 pixlar över om det är 32x32

local activeFrame = 1


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

function copyImage(fromImage, newRect,adjustHeight,adjustWidth)
    return nil
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
  
    if angle == 0 then
      for y = 0 , centeredImage.height-1, 1 do
        for x = 0, centeredImage.width-1, 1 do
          local px = centeredImage:getPixel(x, y)
          outputImg:drawPixel(x, y, px)
        end
      end
    elseif angle == math.pi / 2 then
      for y = 0 , centeredImage.height-1, 1 do
        for x = 0, centeredImage.width-1, 1 do
          local px = centeredImage:getPixel(centeredImage.width - 1 - y, x)
          outputImg:drawPixel(x, y, px)
        end
      end
    elseif angle == math.pi * 3 / 2 then
      for y = 0 , centeredImage.height-1, 1 do
        for x = 0, centeredImage.width-1, 1 do
          local px = centeredImage:getPixel(y, centeredImage.height - 1 - x)
          outputImg:drawPixel(x, y, px)
        end
      end
    elseif angle == math.pi then
      for y = 0 , centeredImage.height-1, 1 do
        for x = 0, centeredImage.width-1, 1 do
          local px = centeredImage:getPixel(centeredImage.width - 1 - x, centeredImage.height - 1 - y)
          outputImg:drawPixel(x, y, px)
        end
      end
    else
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
    end
    return outputImg
  end

--local auxLayer = app.activeLayer
--local imageToRotate = auxLayer:cel(1).image:clone()

local currentImage = Image(sprite)
local pixelsFromSelection = currentImage:pixels(selection.bounds)
local selectedImage = Image(selection.bounds.width, selection.bounds.height)

for it in pixelsFromSelection do
  local pixelValue = it() -- get pixel
  selectedImage:putPixel(it.x, it.y, pixelValue)
  --selectedImage:putPixel(it.x, it.y, c)          -- set pixel
        -- get pixel x,y coordinates
end

selectedImage:resize{size=Size(selectedImage.width + 1, selectedImage.height + 1)}

local newImage = Rotate45Degress(selectedImage)

pixelsFromNewImage = newImage:pixels(Rectangle(0, 1, 24, 23))
local resultImage = Image(24,23)

for it in pixelsFromNewImage do
  local pixelValue = it() -- get pixel
  resultImage:putPixel(it.x, it.y-1, pixelValue)
  --selectedImage:putPixel(it.x, it.y, c)          -- set pixel
        -- get pixel x,y coordinates
end

--resultImage:resize{size=Size(resultImage.width, 11)}
--resultImage:resize{width=24, height=11, pivot=Point(0,0), method='rotsprite'}
resultImage:resize(24,12)
--resultImage:resize{width=24, height=11, pivot=Point(12,13)}
--resultImage:resize(24,11)

pixFromResult = resultImage:pixels(Rectangle(0,1,24,12))
local finalImage = Image(24,11)

for it in pixFromResult do
  local pixelValue = it() -- get pixel
  finalImage:putPixel(it.x, it.y-1, pixelValue)
  --selectedImage:putPixel(it.x, it.y, c)          -- set pixel
        -- get pixel x,y coordinates
end



local outputLayer = sprite:newLayer()
outputLayer.name = "Hej"
local outputSprite = outputLayer.sprite
local cel = sprite:newCel(outputLayer, activeFrame)
cel.image = Image(finalImage)
--cel.image = Image(newImage)
-- sprite.selection = Selection(Rectangle(0, 1, 24, 23))

-- app.command.MoveMask{
--  target="content",
--   direction="up",
--   units="pixel",
--   quantity=1
-- }





-- local outputImage = Image(outputSprite)
-- outputImage:drawImage(newImage)

