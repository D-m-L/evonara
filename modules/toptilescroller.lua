--[[ Hello ]]--
local sti = require 'libs/STI'
local state = require 'libs/stateswitcher'
local anim8 = require 'libs/anim8'

--require('camera')
require 'libs/maths'

require('player')
require('enemy')

addEnemy("bat", 10)
addEnemy("dog", 40)
addEnemy("cat", 25)

dmlDebug = 1
scanlines = 1
printStats = true

visibleTiles = {}

zoom = 1

offsetx = 0
offsety = 0
falling = false
canJump = true

-- Load Map
map = sti.new("map/splash01")

love.physics.setMeter(48)
-- Prepare physics world
world = love.physics.newWorld(0, 6000)
-- Prepare collision objects
collision = map:initWorldCollision(world)
-- Add a Custom Layer
map:addCustomLayer("Sprite Layer", 3)

local spriteLayer = map.layers["Sprite Layer"]

	-- Add Custom Data
	spriteLayer.sprite = {
		image = arajunk,
		x = 400,
		y = 400,
		r = 0,
	}
	
spriteLayer.sprite.body		= love.physics.newBody(world, spriteLayer.sprite.x/2, spriteLayer.sprite.y/2, "dynamic")
--Let's try a circle instead
spriteLayer.sprite.shape	= love.physics.newRectangleShape(40, 40)
spriteLayer.sprite.fixture	= love.physics.newFixture(spriteLayer.sprite.body, spriteLayer.sprite.shape)

spriteLayer.sprite.body:setLinearDamping(10)
spriteLayer.sprite.body:setFixedRotation(true)

-- Override Draw callback
	function spriteLayer:draw()
		local image = self.sprite.image
		local x = math.floor(self.sprite.x - 24)
		local y = math.floor(self.sprite.y - 48)
		local r = self.sprite.r --spriteLayer.sprite.body:getAngle() ?
		love.graphics.draw(image, x, y, r, 1, 1, 24, 24)
	end

function love.update ( dt )
	world:update(dt)
	
	-- Update sprite's coordinates
	local sprite = map.layers["Sprite Layer"].sprite
	
	--Set idle if nothing pushed
	if (facingleft == true) and (notmoved == true) then ara.anim:flipH() end
	
	local down = love.keyboard.isDown
	local x, y = 0, 0
	if down("w") or down("up") then
		y = y - 12000
		--ara.anim = ara.anims.araWalkScared
		--ara.spritesheet = AWSsheet
	end
	if down("s") or down("down") then
		y = y + 4000
		--ara.anim = ara.anims.araWalkScared
		--ara.spritesheet = AWSsheet
	end
	if down("a") or down("left") then
		ara.spritesheet = AWSsheet
		ara.anim = ara.anims.araWalkScared
		if (facingleft == false) then ara.anim:flipH() end
		x = x - 4000
		facingleft = true
		notmoved = false
	end
	if down("d") or down("right") then
		ara.spritesheet = AWSsheet
		ara.anim = ara.anims.araWalkScared
		if (facingleft == true) then ara.anim:flipH() end
		x = x + 4000		
		facingleft = false
		notmoved = false
	end
	
	--ara.anim:update(dt)
	
	sprite.body:applyForce(x, y)
	sprite.x, sprite.y = sprite.body:getWorldCenter()
	--sprite.x = x
	--sprite.y = y
	sprite.x = maths.round(sprite.x, 0)
	sprite.y = maths.round(sprite.y, 0)
	
	map:update(dt)
	
	-- if love.mousepressed("r") then 
		
		
	-- end
	-- if love.mousepressed("l") then
		
		
	-- end
end

function love.mousepressed(x, y, button)
	if button == "l" then
		if (zoom <= 3.75) then zoom = zoom + .25 end
	end
	if button == "r" then
		if (zoom >= .5) then zoom = zoom - .25 end
	end
end

function love.draw()
	local sprite = map.layers["Sprite Layer"].sprite
	local screen = {w = love.graphics.getWidth(), h = love.graphics.getHeight() }

	local tx = math.floor( -sprite.x + screen.w / 4 * zoom )
	local ty = math.floor( -sprite.y + screen.h / 4 * zoom )
	
	

	map:setDrawRange(tx, ty, screen.w / zoom, screen.h / zoom)
	
	--This 'saves' the graphics system's state for shenanigans
	love.graphics.push()	
	--Set up our zoom
	love.graphics.scale(zoom, zoom)
	-- To draw sprite in centre of screen we re-center around the dynamic body
	love.graphics.translate(tx, ty)
	-- The map draws normally now
	map:draw(1, 1)
	love.graphics.translate(tx, ty)
	love.graphics.scale(zoom * 2, zoom * 2)
	
	--we should have the correct spritesheet from update logic	--fix anim8 origin - sorta
	ara.anim:draw(ara.spritesheet, (sprite.x / zoom) - (48 / zoom), sprite.y / zoom - (72 / zoom))
	
	-- love.graphics.setColor(255, 255, 0, 255)
	-- map:drawWorldCollision(collision)

	-- love.graphics.setColor(255, 0, 0, 255)
	-- love.graphics.polygon("line", sprite.body:getWorldPoints(sprite.shape:getPoints()))
	
	love.graphics.pop() -- kill the scaling		
	drawLevelUI()

end

function love.keypressed( key, unicode )
	if ( key == "escape" ) then state.switch("mainmenu") end
	--if ( key == "q") then -- q = next map
		--gMapNum = (gMapNum or 1) + 1
		--if (gMapNum > 10) then gMapNum = 1 end
		--TiledMap_Load(string.format("map/map%02d.tmx",gMapNum))
		--gCamX,gCamY = 100,100
	--end
	if (key == "t" ) then offsetx = offsetx + 1 end
	if (key == "g" ) then offsetx = offsetx - 1 end
	if (key == "f1" ) then switchScreen() end
	if (key == "o" ) then
		if (printStats) then printStats = nil
		else printStats = true end
	end
	if (key == "p" ) then
		addEnemy("bat", 10)
	end

end

function love.keyreleased ( key )
	--gKeyPressed[key] = nil
end

function printKeyPresses()
	if love.mouse.isDown(action) then 
		love.graphics.printf("R R R",100,love.window.getHeight()-20,love.window.getWidth()-100)
	end
	if love.mouse.isDown(secondary) then 
		love.graphics.printf("L L L",50,love.window.getHeight()-20,love.window.getWidth()-100)
	end
	
	if love.keyboard.isDown(playerUP) then 
		love.graphics.printf("^ ^ ^",150,love.window.getHeight()-20,love.window.getWidth()-100)
	end
	if love.keyboard.isDown(playerDOWN) then 
		love.graphics.printf("V V V",200,love.window.getHeight()-20,love.window.getWidth()-100)
	end
	if love.keyboard.isDown(playerLEFT) then 
		love.graphics.printf("< < <",250,love.window.getHeight()-20,love.window.getWidth()-100)
	end
	if love.keyboard.isDown(playerRIGHT) then 
		love.graphics.printf("> > >",300,love.window.getHeight()-20,love.window.getWidth()-100)
	end
end

function love.resize(w, h)
    map:resize(w, h)
end

function drawLevelUI()
	if (scanlines) then doScanlines() end
	
	-- UI Stuff Goes Here --

	
	
	
	if (printStats) then
		love.graphics.setBackgroundColor(200,200,200)
		love.graphics.setColor(255,30,30)
		love.graphics.printf("Levels - Testing Camera System.",50,50,love.window.getWidth()-100)
		love.graphics.setColor(0,0,0)
		love.graphics.printf("Press 'escape' for main menu.",100,80,love.window.getWidth()-200)
		love.graphics.printf("...",100,150,love.window.getWidth()-200)	
		
		printKeyPresses()
		doPrintStats()
		
		-- --Recreate the push pop for the map scaling, etc
		-- love.graphics.push()	
		-- love.graphics.scale(zoom, zoom)
		-- love.graphics.translate(math.floor( -map.layers["Sprite Layer"].sprite.x + love.window.getWidth() * zoom * 2), math.floor( -map.layers["Sprite Layer"].sprite.y + love.window.getHeight() * zoom * 2))
		-- love.graphics.setColor(255, 255, 0, 255)
		-- map:drawWorldCollision(collision)
		-- love.graphics.setColor(255, 0, 0, 255)
		-- love.graphics.polygon("line", map.layers["Sprite Layer"].sprite.body:getWorldPoints(map.layers["Sprite Layer"].sprite.shape:getPoints()))
		-- love.graphics.pop()	
		-- --

		
		listEnemies()
	end
	
	local dir = "WASD / UDLR to move"
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.print(dir, 30, 30)
end

function doPrintStats()
love.graphics.setColor(0,255,0)
    love.graphics.print(
		'zoom = 				' .. zoom		 	.. '\n' ..
		'enemNum = 				' .. enemNum				.. '\n' ..
		'Enemies in array = 	' .. #enemies				.. '\n' ..
		'sprite.x = 			' .. map.layers["Sprite Layer"].sprite.x	.. '\n' ..
		'sprite.y = 			' .. map.layers["Sprite Layer"].sprite.y				.. '\n' ..
		-- 'height = 			' .. camH 	.. '\n' ..
		-- 'hAccel = 			' .. hAccel 			.. '\n' ..
        -- 'evo.x =         	' .. evo.x 				.. '\n' ..
        -- 'evo.y =           	' .. evo.y 				.. '\n' ..
        -- 'evo.rot =         	' .. evo.rot 			.. '\n' ..
        -- 'evo.rot (deg) =   	' .. math.deg(evo.rot) 	.. '\n' ..
        -- 'evo.speed =       	' .. evo.speed			.. '\n' ..
        'FPS =          ' .. love.timer.getFPS()
        , 0, 200
																)
end
	