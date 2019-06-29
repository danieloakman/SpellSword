local Entity = require 'entity'
local Player = Entity:extend()
local MeleeWeapon = require 'meleeWeapon'

function Player:new(genderClass, x, y)
  local startCoords = {
    mK = {x = 128, y = 96}, -- male knight
    fK = {x = 128, y = 64}, -- female knight
    mR = {x = 128, y = 32}, -- male rogue
    fR = {x = 128, y = 0}, -- female rogue
    mW = {x = 128, y = 162}, -- male wizard
    fW = {x = 128, y = 128} -- female wizard
  }
  self.super:new(startCoords[genderClass], x, y + 8, 12, 12, 100, 8, 24)
  self.delta = {x = 0, y = 0}
  self.isMoving = {left = false, right = false, up = false, down = false}
  self.speedBoostAmount = 1.5
  self.lWeapon = MeleeWeapon('dagger', self)
  self.rWeapon = nil
end

function Player:update(dt)
  -- Resetting variables:
  self.isMoving = {left = false, right = false, up = false, down = false}
  self.delta.x = self.super.x
  self.delta.y = self.super.y
  
  -- Updating speed:
  if love.keyboard.isDown('lshift') then -- If speedBoost active:
    self.super.speedMulti = self.super.speedMulti * self.speedBoostAmount
  end
  self.super.speed = self.super.baseSpeed * self.super.speedMulti
  
  -- Controls:
  if love.keyboard.isDown('a') then
    self.super.x = self.super.x - self.super.speed * dt
    if self.super.scaleX > 0 then
      self.super.scaleX = self.super.scaleX * -1 -- Reverse image and make it face left
    end
    self.isMoving.left = true
  end
  if love.keyboard.isDown('d') then
    self.super.x = self.super.x + self.super.speed * dt
    if self.super.scaleX < 0 then
      self.super.scaleX = self.super.scaleX * -1 -- Make image face right
    end
    self.isMoving.right = true
  end
  if love.keyboard.isDown('w') then
    self.super.y = self.super.y - self.super.speed * dt
    self.isMoving.up = true
  end
  if love.keyboard.isDown('s') then
    self.super.y = self.super.y + self.super.speed * dt
    self.isMoving.down = true
  end
  
  -- Update frames:
  if self.isMoving.left or self.isMoving.right or self.isMoving.up or self.isMoving.down then
    -- Change to moving framesd
    self.super.startFrame = 5
    self.super.endFrame = 9
  else
    -- Change to idle frames:
    self.super.startFrame = 1
    self.super.endFrame = 5
  end
  
  -- Updating speedMulti for diagonally moving
  if (self.isMoving.left and self.isMoving.up) or (self.isMoving.up and self.isMoving.right) or
    (self.isMoving.right and self.isMoving.down) or (self.isMoving.down and self.isMoving.left) then
    -- Player is moving diagonally, so change the multiplier
    self.super.speedMulti = 1 / math.sqrt(2) -- 0.7071
  else
    self.super.speedMulti = 1
  end
  
  self.super:update(dt)
  self.delta.x = self.delta.x - self.super.x
  self.delta.y = self.delta.y - self.super.y
  
  if self.lWeapon then self.lWeapon:update(dt, self) end
  if self.rWeapon then self.rWeapon:update(dt, self) end
end

function Player:draw()
  self.super:draw()
  if self.lWeapon then self.lWeapon:draw() end
  if self.rWeapon then self.rWeapon:draw() end
end

function Player:mousepressed(x, y, button, isTouch)
  if button == 1 then
    if self.lWeapon then
      
    end
  else
    print(
      x .. ' ' .. y .. '\n' ..
      (windowWidth / 2) / self.super.x .. ' ' .. (windowHeight / 2) / self.super.y .. '\n' ..
      x / self.super.x .. ' ' .. y / self.super.y
    )
  end
end

function Player:keypressed(key)
  -- Debug button:
  if key == 'c' then
    print(
      '\nx: ' .. self.super.x .. ' y: ' .. self.super.y .. '\ndelta.x: ' ..
      self.delta.x .. ' delta.y: ' .. self.delta.y .. '\nisMoving: ' .. inspect(self.isMoving) ..
      '\nspeed: ' .. self.super.speed .. ' speedMulti: ' .. self.super.speedMulti
    )
  end
  if key == 'space' then
--    u.filter({1,2,3,4}, function(v) return v % 2 == 0 end)

--    u(u.keys(self)):chain()
--      :each(function(v)
--        print(v .. ' ' .. tostring(self[v]))
--      end)

--    u(u.keys(self)):chain()
--      :each(lmd(v) -> )

--    u(u.keys(self)):chain()
--      :filter(function(key) return string.match(key, 'Weapon',) end)
--      :each(print)

    local sound = sfxr.newSound()
    sound:randomJump()
    local soundData = sound:generateSoundData()
    local source = love.audio.newSource(soundData)
    source:play()
  end
end

function Player:keyreleased(key)
  
end

function Player:moveTo(x, y)
  self.super.x = x
  self.super.y = y
end

return Player
