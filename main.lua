-- Globally required libraries:
lume = require 'lib/lume'
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
--local PolygonRoom = require 'shadows.Room.PolygonRoom'
--local RectangleRoom = require 'shadows.Room.RectangleRoom'
--local Star = require 'shadows.Star'
local Body = require 'shadows.Body'
local PolygonShadow = require 'shadows.ShadowShapes.PolygonShadow'

function love.load()
  print('Love.load():', lume.time(function()
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
    lWorld = LightWorld:new()
    map = Map('testMap')
    camera = Camera(map.spawn.x, map.spawn.x, 3)
    player = Player('mR', map.spawn.x, map.spawn.y)
    pEngine = Physics(player, map) -- Physics Engine
    
--    cursorLight = Light:new(lWorld, 300)
--    cursorLight:SetColor(255, 255, 255, 255)
  end))
end

function love.update(dt)
  player:update(dt)
  pEngine:update(dt)
  
  -- Update camera coordinates:
  local dx,dy = player.x - camera.x, player.y - camera.y
  camera:move(dx / 2, dy / 2)
  
  -- Move cursor light and set altitude to 0.5
--	cursorLight:SetPosition(love.mouse.getX(), love.mouse.getY(), 0.5)

	-- Recalculate the light world
	lWorld:Update(dt)
  map:update(dt)
end

function love.draw()
  camera:attach() -- Do all drawing after this
  map:draw('floor')
  map:draw('backWalls')
  player:draw()
  map:draw('frontWalls')
  if _g.drawMapGrid then map:drawTestGrid() end
  if _g.drawCollisionBoxes then pEngine:draw() end
	lWorld:Draw() -- Everything above this will be affected by lights and shadows
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
    local newLight = Light:new(lWorld, math.random(100, 300))
    -- Set the light's color randomly
    newLight:SetColor(math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255))
    newLight:SetPosition(love.mouse.getX(), love.mouse.getY(), 1.1)
  end
  if key == 'k' then
    print('lWorld.Lights: ', #lWorld.Lights)
    lume.each(lWorld.Lights, function(light)
      print(light)
    end)
    print('lWorld.Bodies: ', #lWorld.Bodies)
    lume.each(lWorld.Bodies, function(body)
      print(body)
    end)
  end
end

function love.keyreleased(key)
  player:keyreleased(key)
end
