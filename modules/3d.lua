local Mesh = require("libs/3d/mesh")
local Camera = require("libs/3d/camera")
local state = require 'libs/stateswitcher'

local mesh,camera
local sw,sh = love.window.getDimensions()
local gradient

local Matrix4 = require 'libs/3d2/lib.math.mat4'
local Vector3 = require 'libs/3d2/lib.math.vec3'
local Vector2 = require 'libs/3d2/lib.math.vector'

zscale = 1
FOV =  100

--local mesh, mesh2
local shader
local mvp
local waveobj
local last_material_texture

--function love.load(arg)

  -- and opengl
  gl.glEnable( gl.GL_CULL_FACE )

  love.graphics.setDefaultMipmapFilter("linear", 0.8)

  local vs = love.filesystem.read("gfx/shaders/effect.vert")
  local fs = love.filesystem.read("gfx/shaders/effect.frag")
  shader = love.graphics.newShader(vs, fs)  

--function love.load()
local id = love.image.newImageData(1,2)
  id:setPixel(0,0,255,0,0)
  id:setPixel(0,1,0x94,0xa5,0xd1)
  gradient = love.graphics.newImage(id)

  camera = Camera.new()

  mesh = Mesh.loadObj("gfx/obj/level.obj","gfx/obj/tempel5.png")
  mesh.x = 0
  mesh.y = 0
  mesh.drawAxis = false
  mesh:setFilter("nearest")
  mesh.culling = true
  --mesh:updateLight()
--end

--  mesh2 = love.graphics.newMesh(sorted_vertices, image, "triangles")
  mesh2 = Mesh.loadObj("gfx/obj/chest/chest.obj","gfx/obj/tempel5.png")

mvp = {
  m = Matrix4.scale( .01, .01, .01 );
  v = Matrix4.lookat( Vector3( 0, 2, 9 ),
                      Vector3( 0, 0, 0 ),
                      Vector3( 0, 1, 0 ) );
  p = Matrix4.perspectiveFov( 100, sw / sh, 0.1, 100 );
}

function drawDebug()
	love.graphics.setColor(0,0,0,128)
	love.graphics.rectangle("fill",10,10,200,120)
	love.graphics.rectangle("fill",0,sh-20,sw,20)
	love.graphics.setColor(255,255,255,255)
	love.graphics.printf("(1)Level (2) Utah Teapot (arrows)rotate (c)backface culling (f)texture filtering (v)draw axis (z)sorting",0,sh-15,sw,"center")
	love.graphics.print("FPS: "..love.timer.getFPS(),20,20)
	local c = 2
	local cc = 2
	for i,v in pairs(mesh:getDebug()) do 
		love.graphics.print(i..": "..v,20,5+15*cc)
		cc=cc+1
	end
end

function love.draw()
  
  shader:send("Model", Matrix4.scale( .01, .01, .01 ):lovemat())
--  love.graphics.draw(mesh2, 0, 0)
  shader:send("Model", mvp.m:lovemat())
  shader:send("View", mvp.v:lovemat())
  shader:send("Projection", mvp.p:lovemat())
  --love.graphics.draw(mesh, 0, 0)
--  gl.glDisable( gl.GL_DEPTH_TEST )


--  love.graphics.setShader()
--  debugutil:print({
--    ("fps: %.2f"):format(love.timer.getFPS()),
--    ("vertices: %s"):format(tostring(#waveobj.v)),
--    ("faces: %s"):format(tostring(#waveobj.f)),
--    ("texture: %s"):format(last_material_texture),
--    "",
--    "Controls: w, a, s, d, (q & e rotate)"
--  },10, 10, 14)
  --love.graphics.setShader(shader)
  
  love.graphics.setCanvas(canvas)
  gradient:setFilter("linear")
	love.graphics.draw(gradient,0,0,0,sw/2,sh/4)
	love.graphics.push()
	love.graphics.translate(sw/4,sh/4+sh*0.25)
	mesh:draw(mesh.x,mesh.y,camera)
	mesh2:draw(0,0,camera)
	love.graphics.pop()
  love.graphics.setCanvas()
	love.graphics.draw(canvas, scrn.x, scrn.y, scrn.r, scrn.scl, scrn.scl, 0, 0, scrn.xsk, scrn.ysk)
  drawLevelUI()
	drawDebug()
end
function drawLevelUI()
	doScanlines()
end

function love.update(dt)
	camera:update()
  mesh:update(camera)
  local down = love.keyboard.isDown
  if down("i") then
      camera.b = camera.b+dt
  elseif down("k") then
      camera.b = camera.b-dt
  elseif down("l") then
      camera.a = camera.a+dt
  elseif down("j") then
      camera.a = camera.a-dt
  elseif down("e") then
      camera.c = camera.c-dt
  end
    if love.keyboard.isDown("w") then
  love.graphics.setShader(shader)
  mvp.m = mvp.m * Matrix4.translate( 0, 0, dt )
  end
  if love.keyboard.isDown("s") then
    love.graphics.setShader(shader)
    mvp.m = mvp.m * Matrix4.translate( 0, 0, -dt )
  end
  if love.keyboard.isDown("d") then
    love.graphics.setShader(shader)
    mvp.m = mvp.m * Matrix4.translate( dt, 0, 0 )
  end
  if love.keyboard.isDown("a") then
    love.graphics.setShader(shader)
    mvp.m = mvp.m * Matrix4.translate( -dt, 0, 0 )
  end
  if love.keyboard.isDown("e") then
    love.graphics.setShader(shader)
    mvp.m = mvp.m * Matrix4.rotate( dt, 0, 1, 0 )
  end
  if love.keyboard.isDown("q") then
    love.graphics.setShader(shader)
    mvp.m = mvp.m * Matrix4.rotate( -dt, 0, 1, 0 )
  end
    if down("up") or down("w") then mesh.y = mesh.y + 150 * dt end
		if down("s") or down("down") then mesh.y = mesh.y - 150 * dt end
		if down("a") or down("left") then mesh.x = mesh.x + 150 * dt end
		if down("d") or down("right") then mesh.x = mesh.x - 150 * dt end
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
	if k == "v" then
		if mesh.drawAxis then mesh.drawAxis=false
		else mesh.drawAxis=true end
	end
	if k == "z" then
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
  if (key == "t" ) then
    zscale = zscale + 1
    camera:update()
  end
  if (key == "g" ) then
    zscale = zscale - 1
    camera:update()
  end
end

