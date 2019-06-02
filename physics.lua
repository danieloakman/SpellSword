Physics = Object:extend()

function Physics:new(player, map)
  self.HC = require 'lib/HC'

  -- Array to hold collision messages:
--  self.text = {}
  
  -- Create collision box for player:
  self.playerC = self.HC.rectangle(player.x, player.y + 8, player.width, player.height)
  
  -- Create collision boxes for special map objects, i.e. monsters, pillars, pickups etc
  -- todo: when creating other map object's collision boxes, like monsters, pickups, etc, put them into other variables other than self.mapWallsC
  self.mapWallsC = {}
  local tWidth, tHeight = map.tilewidth, map.tileheight
  local tileCollisionData = require('tileCollisionData')
  local arrLayerNames = {--[['frontWalls',]] 'backWalls'}
  for i,v in ipairs(arrLayerNames) do
    local wallArr = map:get2dArrayOfLayer(v)
    for i = 1, #wallArr do
      for j = 1, #wallArr[i] do
        local v = wallArr[i][j]
        local data = tileCollisionData['id' .. v]
        if data ~= nil then -- you could also do: not data
          if data.shape == 'rectangle' then
            table.insert(self.mapWallsC, self.HC.rectangle((j * tWidth) + data.offsetX, (i * tHeight) + data.offsetY, data.width, data.height))
          elseif data.shape == 'polygonShape' then
            table.insert(self.mapWallsC, 
              self.HC.polygon(
                data.vertices[1].x + tWidth * j,data.vertices[1].y + tHeight * i, data.vertices[2].x + tWidth * j,data.vertices[2].y + tHeight * i,
                data.vertices[3].x + tWidth * j,data.vertices[3].y + tHeight * i, data.vertices[4].x + tWidth * j,data.vertices[4].y + tHeight * i,
                data.vertices[5].x + tWidth * j,data.vertices[5].y + tHeight * i, data.vertices[6].x + tWidth * j,data.vertices[6].y + tHeight * i
              )
            )
          end
        end
      end
    end
  end

  -- Place HC.rectangles in the empty spaces directly next to the edges of rooms. I.e. right next to floors.
  local wallArr = map:get2dArrayOfLayer('floor')
  for i = 1, #wallArr do
    for j = 1, #wallArr[i] do
      local v = wallArr[i][j]
      if v == 0 then
        -- Look at adjacent tiles, if one of them is a floor then place a HC.rectangle
        local arr = {{i=i, j=j-1}, {i=i, j=j+1}, {i=i-1, j=j}, {i=i+1, j=j}} -- adjacent tiles on left, right, top and bottom sides
        local adjacentTiles = {}
        for index,value in ipairs(arr) do
          if value.i < 1 or value.i > map.width then value.i = i end
          if value.j < 1 or value.j > map.height then value.j = j end
          table.insert(adjacentTiles, wallArr[value.i][value.j])
        end
        local isAdjacentFloor = false
        local offsetY = 0
        for index,value in ipairs(adjacentTiles) do
          if value ~= 0 then 
            isAdjacentFloor = true
            if index == 4 then offsetY = -4 end -- is bordered on bottom with a floor, so decrease collision box height
          end
        end
        if isAdjacentFloor then
          table.insert(self.mapWallsC, 
            self.HC.rectangle((j * tWidth) - 4, (i * tHeight) - 4, tWidth + 8, tHeight + 8 + offsetY)
          )
        end
      end
    end
  end
end

function Physics:update(dt, player)
  -- Update playerC with new player position:
  self.playerC:moveTo(player.x, player.y)
  
  -- Check for collisions with player. If there are any
  -- move player back to position before collision:
  for shape, delta in pairs(self.HC.collisions(self.playerC)) do
    player:moveTo(player.x + delta.x, player.y + delta.y)
  end
end

function Physics:draw()
  -- Draw player's collision box:
  self.playerC:draw('line')
  
  -- Draw all wall's collision box:
  for i,v in ipairs(self.mapWallsC) do v:draw('line') end
end
