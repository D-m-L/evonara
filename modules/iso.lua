local Mesh = require("libs/iso/mesh")
local Camera = require("libs/iso/camera")

local mesh,camera
local sw,sh = love.window.getDimensions()
local gradient

local id = love.image.newImageData(1,2)
id:setPixel(0,0,0x60,0x71,0x5f)
id:setPixel(0,1,0x94,0xa5,0xd1)
gradient = love.graphics.newImage(id)

camera = Camera.new()
camera.a, camera.b = math.rad(60), math.rad(60)

mesh = Mesh.loadObj("gfx/obj/level.obj", "gfx/obj/tempel5.png")
mesh.drawAxis = true
mesh:setFilter("nearest")
mesh.culling = true
mesh:updateLight()

function drawDebug()
	love.graphics.setColor(255,255,255,255)
	love.graphics.printf("(1)Level (2) Utah Teapot (arrows)rotate (c)backface culling (f)texture filtering (a)draw axis (d)depth sorting",0,sh-15,sw,"center")
	local c = 2
	local cc = 2
--	for i,v in pairs(mesh:getDebug()) do 
--		love.graphics.print(i..": "..v,20,5+15*cc)
--		cc=cc+1
--	end
  love.graphics.print("FPS: "..love.timer.getFPS(),20,20 * 1)
  love.graphics.print("camera.b: ".. math.deg(camera.b),20,20 * 2)
  love.graphics.print("camera.a: ".. math.deg(camera.a),20,20 * 3)
end

function love.draw()
	love.graphics.draw(gradient,0,0,0,sw,sh/2)
	love.graphics.push()
	love.graphics.translate(sw/2,sh/2+sh*0.25)
	mesh:draw(0,0,camera)
	love.graphics.pop()
	drawDebug()
end

function love.update(dt)
	  camera:update()
    mesh:update(camera)
    if love.keyboard.isDown("up") then
        camera.b = camera.b+dt
    elseif love.keyboard.isDown("down") then
        camera.b = camera.b-dt
    elseif love.keyboard.isDown("right") then
        camera.a = camera.a+dt
    elseif love.keyboard.isDown("left") then
        camera.a = camera.a-dt
    end
end

local filter = false

function love.keypressed(k)
	if k == "c" then
		if mesh.culling then mesh.culling = false
		else mesh.culling = true end
	end
	if k == "f" then
		if filter then mesh:setFilter("nearest") filter=false
		else mesh:setFilter("linear") filter=true end
	end
	if k == "a" then
		if mesh.drawAxis then mesh.drawAxis=false
		else mesh.drawAxis=true end
	end
	if k == "s" then
		if mesh.sorting then mesh.sorting=false
		else mesh.sorting=true end
	end
	if k=="1" then
		mesh:release()
		mesh = Mesh.loadObj("gfx/obj/level.obj","gfx/obj/tempel5.png")
		mesh:updateLight()
	end
	if k=="2" then
		mesh:release()
		mesh = Mesh.loadObj("gfx/obj/wt_teapot.obj")
		mesh:updateLight()
	end
    if ( k == "escape" ) then
		state.switch("mainmenu")
    collectgarbage()
  end
end

