local shadows = require("shadows")
local sti = require("sti")

local LightWorld		=	require("shadows.LightWorld")
local Light				=	require("shadows.Light")
local NormalShadow	=	require("shadows.ShadowShapes.NormalShadow")
local HeightShadow	=	require("shadows.ShadowShapes.HeightShadow")
local Star				=	require("shadows.Star")
local Body				=	require("shadows.Body")
local PolygonShadow	=	require("shadows.ShadowShapes.PolygonShadow")
local CircleShadow	=	require("shadows.ShadowShapes.CircleShadow")
local ImageShadow		=	require("shadows.ShadowShapes.ImageShadow")

translation = {x = 0, y = 0, z = 1}

LWorld = LightWorld:new()
LWorld:SetColor(40, 40, 40, 255)
L = Light:new(LWorld, 500)
L:SetColor(255, 255, 255, 255)
L:SetPosition(400, 400, 20)

--local S = Star:new(LWorld, 50000)
--S:SetColor(255, 255, 255, 255)
--S:SetPosition(-5000, -5000, 400)

testBody = Body:new(LWorld)
testBody:SetPosition(0, 0, 1.3)

testBody2 = Body:new(LWorld)
testBody2:SetPosition(0, 0, 1.3)

testBody3 = Body:new(LWorld)
testBody3:SetPosition(0, 0, 1.3)

testBody4 = Body:new(LWorld)
testBody4:SetPosition(0, 0, 1.3)

CircleShadow:new(testBody, 200, 180, 50)

nm = NormalShadow:new(testBody2, love.graphics.newImage("normalmap.png"))
nm.Img = love.graphics.newImage("texture.png")
nm:SetPosition(500, 600)

hm = HeightShadow:new(testBody3, love.graphics.newImage("heightmap.png"))
hm.Img = love.graphics.newImage("heightmaptexture.png")
hm:SetPosition(200, 200)

is = ImageShadow:new(testBody4, love.graphics.newImage("heightmap.png"))
is:SetPosition(500, 200)

function love.load()

	windowWidth, windowHeight = love.graphics.getDimensions()

	love.physics.setMeter(32)

	map = sti("as_snow/as_snow.lua", {"box2d"})

	world = love.physics.newWorld(0, 0)

	map:box2d_init(world)
	LWorld:InitFromPhysics(world)
	
	testBody4:Remove()

end

function love.update(dt)

	if love.keyboard.isDown("w") then

		translation.y = translation.y - 500 * love.timer.getDelta()

	elseif love.keyboard.isDown("s") then

		translation.y = translation.y + 500 * love.timer.getDelta()

	end

	if love.keyboard.isDown("a") then

		translation.x = translation.x - 500 * love.timer.getDelta()

	elseif love.keyboard.isDown("d") then

		translation.x = translation.x + 500 * love.timer.getDelta()

	end

	local tx, ty = testBody:GetPosition()

	--testBody:SetPosition(tx + 20 * love.timer.getDelta(), ty)

	map:update(dt)

	L:SetPosition( translation.x + love.mouse.getX() / translation.z, translation.y + love.mouse.getY() / translation.z)
	LWorld:SetPosition(translation.x, translation.y, translation.z)
	
	LWorld:Update()
	
end

function love.wheelmoved(id, direction)
	
	if id == 0 then
		
		translation.z = translation.z - direction / 20
		
	end
	
end

love.graphics.maxFramerate = 100

function love.draw()

	love.graphics.setColor(255, 255, 255, 255)

	map:draw(-translation.x, -translation.y, translation.z, translation.z)
	
	love.graphics.translate(-translation.x * translation.z, -translation.y * translation.z)
	love.graphics.scale(translation.z, translation.z)
	
	local x, y = nm:GetPosition()
	
	love.graphics.draw(nm.Img, x, y)
	
	local x, y = hm:GetPosition()
	
	love.graphics.draw(hm.Img, x, y)
	
	love.graphics.origin()
	LWorld:Draw()

end

function love.mousepressed(x, y, b)
	
	if b == 1 then
		
		L = Light:new(LWorld, 300)
		L:SetColor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 255)
		
	else
		
		testBody:Remove()
		
	end

end