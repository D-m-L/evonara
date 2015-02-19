io.stdout:setvbuf("no")

local sdl = require("libs/3d2/SDLHook")

-- The wavefront obj loading library
local ject = require 'libs/3d2/lib.ject'

local debugutil = require 'libs/3d2/lib.debugutil'()

local Matrix4 = require 'libs/3d2/lib.math.mat4'
local Vector3 = require 'libs/3d2/lib.math.vec3'
local Vector2 = require 'libs/3d2/lib.math.vector'

local mesh, mesh2
local shader
local mvp
local waveobj
local last_material_texture

--function love.load(arg)
  -- you can access sdl
  print(sdl.GetSystemRAM())

  -- and opengl
  gl.glEnable( gl.GL_CULL_FACE )

  love.graphics.setDefaultMipmapFilter("linear", 0.8)

  local vs = love.filesystem.read("gfx/shaders/effect.vert")
  local fs = love.filesystem.read("gfx/shaders/effect.frag")
  shader = love.graphics.newShader(vs, fs)  


  local level = "gfx/obj/level.obj"
  local chest = "gfx/obj/chest/chest.obj"

  waveobj = ject.parse_fn(level, function(path)
    local lines = {}
    for line in love.filesystem.lines(path) do
      table.insert(lines, line)
    end
    return lines
  end,
  function(path)
    return love.filesystem.exists(path)
  end)

  local last_material_lib = waveobj.material_libs[#waveobj.material_libs]
  if last_material_lib then
    local last_material = last_material_lib.materials[#last_material_lib.materials]
    last_material_texture = last_material.map_kd_path
    
    image = love.graphics.newImage(last_material_texture)
  end

  local vertex_map = {}

  local vertices = {}
  for i,v in ipairs(waveobj.v) do
    table.insert(vertices, {v[1], v[2], v[3], v[4]})
  end

  local texture_coords = {}
  for i,v in ipairs(waveobj.vt) do
    table.insert(texture_coords, {math.floor(waveobj.vt[i][1] * 255), math.floor(waveobj.vt[i][2] * 255)})
  end

  local sorted_vertices = {}
  for _,f in ipairs(waveobj.f) do
    for __,r in ipairs(f.references) do
      local sv = { vertices[r.v][1], vertices[r.v][2], vertices[r.v][3], vertices[r.v][4], texture_coords[r.vt][1], -texture_coords[r.vt][2], 0, 0 }
      table.insert(sorted_vertices, sv)
    end
  end
  
  mesh = love.graphics.newMesh(sorted_vertices, image, "triangles")
  mesh2 = love.graphics.newMesh(sorted_vertices, image, "triangles")

  --love.graphics.setShader(shader)

  mvp = {
    m = Matrix4.scale( .01, .01, .01 );
    v = Matrix4.lookat( Vector3( 0, 2, 9 ),
                        Vector3( 0, 0, 0 ),
                        Vector3( 0, 1, 0 ) );
    p = Matrix4.perspectiveFov( 100, gWindow.width / gWindow.height, 0.1, 100 );
  }


--  shader:send("Model", mvp.m:lovemat())
--  shader:send("View", mvp.v:lovemat())
--  shader:send("Projection", mvp.p:lovemat())
--end


function love.update(dt)
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
end

function love.draw()
--  love.graphics.setCanvas(canvas)
--  drawSky(sky)
  
--  lg.setColor(200, 100, 255, 255)
--  love.graphics.setCanvas()
--	love.graphics.draw(canvas, scrn.x, scrn.y, scrn.r, scrn.scl, scrn.scl, 0, 0, scrn.xsk, scrn.ysk)
  
--  gl.glEnable( gl.GL_DEPTH_TEST )
--  gl.glDepthFunc( gl.GL_LESS )
  
  shader:send("Model", Matrix4.scale( .01, .01, .01 ):lovemat())
  love.graphics.draw(mesh2, 0, 0)
  shader:send("Model", mvp.m:lovemat())
  shader:send("View", mvp.v:lovemat())
  shader:send("Projection", mvp.p:lovemat())
  love.graphics.draw(mesh, 0, 0)
--  gl.glDisable( gl.GL_DEPTH_TEST )


  love.graphics.setShader()
  debugutil:print({
    ("fps: %.2f"):format(love.timer.getFPS()),
    ("vertices: %s"):format(tostring(#waveobj.v)),
    ("faces: %s"):format(tostring(#waveobj.f)),
    ("texture: %s"):format(last_material_texture),
    "",
    "Controls: w, a, s, d, (q & e rotate)"
  },10, 10, 14)
  love.graphics.setShader(shader)

end

function love.keypressed(b,u)
  if ( b == "escape" ) then
    love.graphics.setShader()
		state.switch("mainmenu")    
    collectgarbage()
  end
end