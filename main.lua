-- Globally required libraries:
_u = require 'lib/underscore'
sfxr = require 'lib/sfxr'
require 'utils'

-- Require libraries:
local Camera = require 'lib/camera'
local Player = require 'player'
local Map = require 'map'
local Physics = require 'physics'

-- Shadows:
--local Shadows = require 'shadows'
local LightWorld = require 'shadows.LightWorld'
local Light = require 'shadows.Light'
local PolygonRoom = require 'shadows.Room.PolygonRoom'
local RectangleRoom = require 'shadows.Room.RectangleRoom'
local Star = require 'shadows.Star'

function love.load()
	if arg[#arg] == '-debug' then
    -- Enable debugging if run in debug mode:
    require('mobdebug').start()
  end
  
  -- Prints console out to output of editor
  if _g.dev then io.stdout:setvbuf('no') end -- Only run in dev because of performance hit when on

  local majorV, minorV, revision, codename = love.getVersion()
  print('LOVE2D version: ' .. majorV .. '.' .. minorV .. 'r' .. revision .. ' ' .. codename)
  
  -- Disable anti-aliasing, kind of:
  love.graphics.setDefaultFilter('nearest', 'nearest', 1)
  
  windowWidth, windowHeight = love.graphics.getDimensions()
  
  spriteSheet = {src = love.graphics.newImage('graphics/0x72_DungeonTilesetII_v1.2.png')}
  spriteSheet.width = spriteSheet.src:getWidth()
  spriteSheet.height = spriteSheet.src:getHeight()
  lightWorld = LightWorld:new()
  map = Map('testMap')
  camera = Camera(map.spawn.x, map.spawn.x, 3)
  player = Player('mR', map.spawn.x, map.spawn.y)
  pEng = Physics(player, map) -- Physics Engine
  
  cursorLight = Light:new(lightWorld, 300)
  cursorLight:SetColor(255, 255, 255, 255)
--  star = Star:new(lightWorld, 5000)
  
--  room = PolygonRoom:new(lightWorld, 400, 300, {0,0, 100,0, 100,100, 0,100})
--  room = RectangleRoom:new(lightWorld, 200, 200, 200, 200)

  -- Create a light on the light world, with radius 300
--  table.insert(lightArr, Light:new(lightWorld, 300))

  -- Set the light's color to white
--  lightArr[1]:SetColor(255, 255, 255, 255)

  -- Set the light's position
--  lightArr[1]:SetPosition(400, 400)
  
  -- Create a body
--  table.insert(bodyArr, Body:new(lightWorld))

  -- Set the body's position and rotation
--  bodyArr[1]:SetPosition(300, 300)
--  bodyArr[1]:SetAngle(-15)

  -- Create a polygon shape on the body with the given points
--  PolygonShadow:new(bodyArr[1], -10, -10, 10, -10, 10, 10, -10, 10)

  -- Create a circle shape on the body at (-30, -30) with radius 16
--  CircleShadow:new(bodyArr[1], -30, -30, 16)

  -- Create a second body
--  table.insert(bodyArr, Body:new(lightWorld))

  -- Set the second body's position
  --bodyArr[2]:SetPosition(350, 350)

  -- Add a polygon shape to the second body
--  PolygonShadow:new(bodyArr[2], -20, -20, 20, -20, 20, 20, -20, 20)
end

function love.update(dt)
  player:update(dt)
  pEng:update(dt, player)
  
  -- Update camera coordinates:
  local dx,dy = player.x - camera.x, player.y - camera.y
  camera:move(dx / 2, dy / 2)
  
  -- Move cursor light and set altitude to 0.5
	cursorLight:SetPosition(love.mouse.getX(), love.mouse.getY(), 0.5)

	-- Recalculate the light world
	lightWorld:Update()
end

function love.draw()
  camera:attach() -- Do all drawing after this
  map:draw('floor')
  map:draw('backWalls')
  player:draw()
  map:draw('frontWalls')
  if _g.drawMapGrid then map:drawTestGrid() end
  if _g.drawCollisionBoxes then pEng:draw() end
	lightWorld:Draw() -- Everything above this will be affected by lights and shadows
  if _g.drawFps then
    love.graphics.print('FPS: '..tostring(love.timer.getFPS( )), 1, 1, 0, 1, 1)
  end
  camera:detach() -- Do all drawing before this
end

function love.mousepressed(x, y, button, isTouch)
  player:mousepressed(x, y, button, isTouch)
end

function love.keypressed(key)
  player:keypressed(key)
  if key == '=' and camera.scale < 10 then camera.scale = camera.scale + 1 end
  if key == '-' and camera.scale > 1 then camera.scale = camera.scale - 1 end
  if key == 'escape' then love.event.quit(0) end
  if key == 'l' then
    -- Create a new light with radius 300
    local newLight = Light:new(lightWorld, math.random(100, 300))
    -- Set the light's color randomly
    newLight:SetColor(math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255))
    newLight:SetPosition(love.mouse.getX(), love.mouse.getY(), 1.1)
  end
  if key == 'k' then
    print('lightWorld.lights:')
    _u.each(lightWorld.Lights, function(light)
      print(light)
    end)
  end
end

function love.keyreleased(key)
  player:keyreleased(key)
end
