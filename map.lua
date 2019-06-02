Map = Object:extend()

function Map:new(mapName)
--  self.map = require('maps/' .. mapName)
  local tempMap = require('maps/' .. mapName)
--  for k,v in pairs(tempMap) do self[k] = v end
  self = mergeTables(self, tempMap)

  frameWidth = 16
  frameHeight = 16
  
  -- Create quads of every tile in the image:
  tiles = {}
  for i = 0, 31 do
    for j = 0, 31 do
      table.insert(
        tiles, love.graphics.newQuad(
          j * frameWidth, i * frameHeight, frameWidth, frameHeight, image.width, image.height
        )
      )
    end
  end

  -- Find spawn point coordinates:
  self.spawn = {x = 0, y = 0}
  for i, v in ipairs(self.layers[2].data) do
    if v == 425 then
      local mapWidth = self.layers[2].width -- number of tiles wide
      local mapHeight = self.layers[2].height -- number of tiles in height
      self.spawn.y = (math.floor(i / mapHeight) + 1) * self.tileheight
      local x = i
      while x > mapWidth do x = x - mapWidth end
      self.spawn.x = (x * self.tilewidth) + 8 -- 8 is for correcting
    end
  end
end

function Map:update(dt)
  
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
        image.src, tiles[v], x, y, 0, 1, 1, 0, 0, 0, 0
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
      image.src, tiles[i], self.tilewidth * index, self.tileheight * j, 0, 1, 1, 0, 0, 0, 0
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
