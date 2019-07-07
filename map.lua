local class = require 'lib/middleclass'
local Map = class('Map')

local Light = require 'shadows.Light'
local Body = require 'shadows.Body'
local PolygonShadow = require 'shadows.ShadowShapes.PolygonShadow'
--local CircleShadow = require 'shadows.ShadowShapes.CircleShadow'

function Map:initialize(mapName)
  local tempMap = require('maps/' .. mapName)
  self = mergeTables(self, tempMap)

  self.pixelWidth = self.tilewidth * self.width
  self.pixelHeight = self.tileheight * self.height
    
  -- Create quads of every tile in the image:
  tiles = {}
  for i = 0, 31 do
    for j = 0, 31 do
      table.insert(
        tiles, love.graphics.newQuad(
          j * self.tilewidth, i * self.tileheight, self.tilewidth, self.tileheight, spriteSheet.width, spriteSheet.height
        )
      )
    end
  end

  -- Find spawn point coordinates:
  self.spawn = {x = 0, y = 0}
  for i,v in ipairs(self.layers[2].data) do
    if v == 425 then
      local mapWidth = self.layers[2].width -- number of tiles wide
      local mapHeight = self.layers[2].height -- number of tiles in height
      self.spawn.y = (math.floor(i / mapHeight) + 1) * self.tileheight
      local x = i
      while x > mapWidth do x = x - mapWidth end
      self.spawn.x = (x * self.tilewidth) + 8 -- 8 is for correcting for player offset
    end
  end
  
  -- Create bodies and shadows for the walls:
--  self.bodies = {}
--  self.shadows = {}
--  local layerArr = self:get2dArrayOfLayer('floor')
--  for i,row in ipairs(layerArr) do
--    for j,v in ipairs(row) do
--      if v == 0 then
--        -- Look at adjacent tiles, if one of them is a floor place a body and shadow
--        local arr = {{i=i, j=j-1}, {i=i, j=j+1}, {i=i-1, j=j}, {i=i+1, j=j}} -- adjacent tiles on left, right, top and bottom sides
--        local adjacentTiles = {}
--        for index,value in ipairs(arr) do
--          if value.i < 1 or value.i > self.width then value.i = i end
--          if value.j < 1 or value.j > self.height then value.j = j end
--          table.insert(adjacentTiles, layerArr[value.i][value.j])
--        end
--        local isAdjacentFloor = false
--        local offsetY = 0
--        for index,value in ipairs(adjacentTiles) do
--          if value ~= 0 then 
--            isAdjacentFloor = true
--            if index == 4 then offsetY = -4 end -- is bordered on bottom with a floor, so decrease shadow height
--          end
--        end
--        if isAdjacentFloor then
----          local tWidth,tHeight = self.tilewidth, self.tileheight
----          local body = Body:new(lWorld)
----          local x,y = (j * tWidth), (i*tHeight)
----          local vertices = {0,0, tWidth+8,0, tWidth+8,tHeight+8, 0,tHeight+8}
----          local shadow = PolygonShadow:new(body, 0,0, tWidth+8,0, tWidth+8,tHeight+8, 0,tHeight+8)
----          table.insert(self.bodies, {body=body, x=x, y=y})
----          table.insert(self.shadows, shadow)
--        end
--      end
--    end
--  end
  
  --todo: Find and create lights that are in the map:
  self.lights = {}
end

function Map:update(dt)
  -- Update body position and shadow vertices of walls:
--  for i,v in ipairs(self.bodies) do
--    local screenX,screenY = camera:cameraCoords(v.x, v.y)
--    local x,y = v.body:GetPosition()
--    if x ~= screenX or y ~= screenY then
--      v.body:SetPosition(screenX, screenY)
--    end
--    -- todo: Update shadow vertices
--  end
----  lume.each(self.bodies, function(v) print(v.body:GetPosition()) end)
end

function Map:draw(layer)
  local layerIndex
  if layer == 'floor' then layerIndex = 1
  elseif layer == 'backWalls' then layerIndex = 3
  elseif layer == 'frontWalls' then layerIndex = 4 end
  -- Draw floor layer
  for i,v in ipairs(self.layers[layerIndex].data) do
    if v ~= 0 then
      local mapWidth = self.layers[layerIndex].width -- number of tiles wide
      local mapHeight = self.layers[layerIndex].height -- number of tiles in height
      local j = math.floor(i / mapWidth) + 1
      while i > mapHeight do i = i - mapHeight end -- decrease i to less than mapHeight
      local x = (self.tilewidth * i)
      local y = (self.tileheight * j)
      love.graphics.draw(
        spriteSheet.src, tiles[v], x, y, 0, 1, 1, 0, 0, 0, 0
      )
    end
  end
end

function Map:get2dArrayOfLayer(layerName)
  local arr = {} -- 2D array
  for layerIndex = 1, #self.layers do
    if self.layers[layerIndex].name == layerName then -- found the correct layer
      local mapWidth = self.layers[layerIndex].width -- number of tiles wide
      local mapHeight = self.layers[layerIndex].height -- number of tiles in height
      -- Initialise 2D array with zeros:
      for i = 1, mapHeight do
        arr[i] = {}
        for j = 1, mapWidth do
          arr[i][j] = 0
        end
      end
      -- Populate 2D array
      for i,v in ipairs(self.layers[layerIndex].data) do
        if v ~= 0 then
          local j = math.floor(i / mapWidth) + 1
          while i > mapHeight do i = i - mapHeight end -- decrease i to less than mapHeight
          arr[j][i] = v
        end
      end
    end
  end
  return arr
end

--[[ Debug functions: ]]--
function Map:drawTiles()
  for i,v in ipairs(tiles) do
    local j = math.floor(i / 32) + 1
    local index = i
    while index > 32 do index = index - 32 end
    love.graphics.draw(
      spriteSheet.src, tiles[i], self.tilewidth * index, self.tileheight * j, 0, 1, 1, 0, 0, 0, 0
    )
  end
end

function Map:drawTestGrid()
  local width = self.width * self.tilewidth -- in pixels
  local height = self.height * self.tileheight -- in pixels
  local interval = 32
  -- Draw column lines:
  for i = 0, width do
    love.graphics.line(i * interval, 0, i * interval, height)
  end
  -- Draw row lines:
  for i = 0, height do
    love.graphics.line(0, i * interval, width, i * interval)
  end
  -- Draw text coordinates:
  interval = 64
  local y = 0
  while y <= height do
    local x = 0
    while x <= width do
      love.graphics.print(
        x .. ' ' .. y, x, y, 0,
        0.5, 0.5, 0, 0
      )
      x = x + interval
    end
    y = y + interval
  end
end

return Map

