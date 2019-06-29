function love.load()
	if arg[#arg] == '-debug' then
    -- Enable debugging if run in debug mode:
    require('mobdebug').start()
  end
  
  -- Prints console out to output of editor
--  io.stdout:setvbuf('no') -- NOTE: TURN THIS OFF WHEN RUNNING IN PROD

  local majorV, minorV, revision, codename = love.getVersion()
  print('LOVE2D version: ' .. majorV .. '.' .. minorV .. 'r' .. revision .. ' ' .. codename)
  
  -- Disable anti-aliasing, kind of:
  love.graphics.setDefaultFilter('nearest', 'nearest', 1)
  
  windowWidth, windowHeight = love.graphics.getDimensions()
  
  -- Globally required libraries:
  inspect = require 'lib/inspect'
  _ = require 'lib/underscore'
  sfxr = require 'lib/sfxr'
  require 'utils'
  
  -- Require libraries:
  local Camera = require 'lib/camera'
  local Player = require 'player'
  local Map = require 'map'
  local Physics = require 'physics'
  
  -- Shadows:
  Shadows = require "shadows"
  LightWorld = require "shadows.LightWorld"
  Light = require "shadows.Light"
  Body = require "shadows.Body"
  PolygonShadow = require "shadows.ShadowShapes.PolygonShadow"
  CircleShadow = require "shadows.ShadowShapes.CircleShadow"
  
  -- Create a light world
  newLightWorld = LightWorld:new()
  lightArr = {}
  bodyArr = {}

  -- Create a light on the light world, with radius 300
  table.insert(lightArr, Light:new(newLightWorld, 300))

  -- Set the light's color to white
  lightArr[1]:SetColor(255, 255, 255, 255)

  -- Set the light's position
  lightArr[1]:SetPosition(400, 400)
  
  -- Create a body
  table.insert(bodyArr, Body:new(newLightWorld))

  -- Set the body's position and rotation
  bodyArr[1]:SetPosition(300, 300)
  bodyArr[1]:SetAngle(-15)

  -- Create a polygon shape on the body with the given points
  PolygonShadow:new(bodyArr[1], -10, -10, 10, -10, 10, 10, -10, 10)

  -- Create a circle shape on the body at (-30, -30) with radius 16
  CircleShadow:new(bodyArr[1], -30, -30, 16)

  -- Create a second body
  table.insert(bodyArr, Body:new(newLightWorld))

  -- Set the second body's position
  --bodyArr[2]:SetPosition(350, 350)

  -- Add a polygon shape to the second body
  PolygonShadow:new(bodyArr[2], -20, -20, 20, -20, 20, 20, -20, 20)
  
  image = {src = love.graphics.newImage('graphics/0x72_DungeonTilesetII_v1.2.png')}
  image.width = image.src:getWidth()
  image.height = image.src:getHeight()
  map = Map('testMap')
  player = Player('mR', map.spawn.x, map.spawn.y)
  pEng = Physics(player, map) -- Physics Engine
  camera = Camera(player.x, player.y, 3)
end

function love.update(dt)
  player:update(dt)
  pEng:update(dt, player)
  
  -- Update camera coordinates:
  local dx,dy = player.x - camera.x, player.y - camera.y
  camera:move(dx / 2, dy / 2)
  
  -- Move the light to the mouse position with altitude 1.1
	lightArr[1]:SetPosition(love.mouse.getX(), love.mouse.getY(), 1.1)
	
	-- Recalculate the light world
	newLightWorld:Update()
  
  -- 130 by 90 for pillar
  local x, y = camera:cameraCoords(130, 90)
  
  bodyArr[2]:SetPosition(x, y)
  -- newLightWorld:SetPosition(player.x - windowWidth / 2, player.y - windowHeight / 2, 1)
end

function love.draw()
  camera:attach() -- do all drawing after this
  map:draw('floor')
  map:draw('backWalls')
  player:draw()
  map:draw('frontWalls')
--  map:drawTestGrid()
--  pEng:draw()
	newLightWorld:Draw() -- Draw the light world with white color
  camera:detach() -- do all drawing before this
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
    local newLight = Light:new(newLightWorld, 300)

    -- Set the light's color randomly
    newLight:SetColor(math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255))
    table.insert(lightArr, newLight)
  end
  if key == 'k' then
    local x, y, z = newLightWorld:GetPosition()
    print('lightWordl coords: ' .. x .. ' ' .. y .. ' ' .. z)
    print('lightArr:')
    _.each(lightArr, function(l) print(l:GetPosition()) end)
    print('bodyArr:')
    _.each(bodyArr, function(b) print(b:GetPosition()) end)
  end
end

function love.keyreleased(key)
  player:keyreleased(key)
end
