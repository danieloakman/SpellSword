function love.load()
	if arg[#arg] == '-debug' then
    -- Enable debugging if run in debug mode:
    require('mobdebug').start()
  end
  io.stdout:setvbuf('no') -- NOTE: TURN THIS OFF WHEN RUNNING IN PROD
  local majorV, minorV, revision, codename = love.getVersion()
  print('LOVE2D version: ' .. majorV .. '.' .. minorV .. 'r' .. revision .. ' ' .. codename)
  
  -- Disable anti-aliasing, kind of:
  love.graphics.setDefaultFilter('nearest', 'nearest', 1)
  
  windowWidth, windowHeight = love.graphics.getDimensions()
  
  -- Require libraries:
  Object = require 'lib/classic'
  Camera = require 'lib/camera'
  inspect = require 'lib/inspect'
  u = require 'lib/underscore'
  sfxr = require 'lib/sfxr'

  require 'player'
  require 'map'
  require 'physics'
  require 'utils'
  require 'meleeWeapon'
  
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
  local dx,dy = player.x - camera.x, (player.y) - camera.y
  camera:move(dx / 2, dy / 2)
end

function love.draw()
  camera:attach() -- do all drawing after this
  map:draw('floor')
  map:draw('backWalls')
  player:draw()
  map:draw('frontWalls')
--  map:drawTestGrid()
--  pEng:draw()
  camera:detach() -- do all drawing before this
end

function love.mousepressed(x, y, button, isTouch)
  Player:mousepressed(x, y, button, isTouch)
end

function love.keypressed(key)
  player:keypressed(key)
  if key == '=' and camera.scale < 10 then camera.scale = camera.scale + 1 end
  if key == '-' and camera.scale > 1 then camera.scale = camera.scale - 1 end
  if key == 'escape' then love.event.quit(0) end
end

function love.keyreleased(key)
  player:keyreleased(key)
end
