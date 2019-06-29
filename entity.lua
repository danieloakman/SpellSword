local Object = require 'lib/classic'
-- Abstract class:
local Entity = Object:extend()

function Entity:new(startCoords, x, y, width, height, speed, offsetX, offsetY)
  self.hp = 100
  self.x = x
  self.y = y
  self.baseSpeed = speed
  self.speed = speed
  self.speedMulti = 1
  self.stamina = 100
  self.width = width -- used for collision detection
  self.height = height -- used for collision detection
  self.scaleX = 1
  self.scaleY = 1
  self.currentFrame = 1
  self.startFrame = 1
  self.endFrame = 5
  self.offsetX = offsetX
  self.offsetY = offsetY
  local frameWidth = 16
  local frameHeight = 32
  frames = {}
  for i = 0, 8 do
    table.insert(
      frames, love.graphics.newQuad(
        (i * frameWidth) + startCoords.x, startCoords.y,
        frameWidth, frameHeight, image.width, image.height
      )
    )
  end
end

function Entity:update(dt)
  -- Update animation frames:
  self.currentFrame = self.currentFrame + dt * 10
  if self.currentFrame >= self.endFrame then
    self.currentFrame = self.startFrame
  end
end

function Entity:draw()
  love.graphics.draw(image.src, frames[math.floor(self.currentFrame)], self.x, self.y, 0, self.scaleX, self.scaleY, self.offsetX, self.offsetY, 0, 0)
end

return Entity
