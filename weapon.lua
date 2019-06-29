local Object = require 'classic'
-- Abstract class:
local Weapon = Object:extend()

function Weapon:new(weapon, owner)
  self.x, self.y = owner.x, owner.y
  self.scaleX, self.scaleY = owner.scaleX, owner.scaleY
  self.offsetX, self.offsetY = weapon.sprite.idle.offsetX, weapon.sprite.idle.offsetY
  self.rotation = weapon.sprite.idle.rot
  self.damage = weapon.damage
  self.attackSpeed = weapon.attackSpeed
  self.frameWidth = weapon.sprite.frameWidth
  self.frameHeight = weapon.sprite.frameHeight
  quad = love.graphics.newQuad(
    weapon.sprite.x, weapon.sprite.y,
    self.frameWidth, self.frameHeight, image.width, image.height
  )
end

function Weapon:update(dt, owner)
  self.x, self.y = owner.x, owner.y
  self.scaleX, self.scaleY = owner.scaleX, owner.scaleY
end

function Weapon:draw()
  love.graphics.draw(
    image.src, quad, self.x, self.y, self.rotation, self.scaleX, self.scaleY, self.offsetX, self.offsetY, 0, 0
  )
end

return Weapon
