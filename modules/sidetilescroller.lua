--[[ Hello ]]--
local State = require 'modules/libs/stateswitcher'
local Lume = require 'modules/libs/lume'
local Sti = require 'modules/libs/STI'

local debugWorldDraw = require("modules/libs/debugDraw")

--TLfres.transform()

--require('camera')
require 'modules/libs/maths'
require 'modules/libs/steering'
require 'modules/libs/anAL'

require 'modules/enemy'
local ara = require 'modules/heroes/ara'
local evo = require 'modules/heroes/evo'
local cam = require 'modules/heroes/cam'
local sky = require 'modules/heroes/Bgs'

-- a bunch of temp globals
printStats = 1
something = 16
lctrl, lalt = false, false
callTxt, callPersist = '', 0   -- Txt hold callback info text, Persists counts repeated callback calls

lightmode = { white, s3top, green, s3bot}
wlight = lightmode[4]

-- Load Map
local map = Sti.new("maps/splash01")
--local peep_map = Peep.new("map", map)

-- Add a Custom Sprite Layer to map rendering
map:addCustomLayer("Sprite Layer", 3)
-- Create our friendly layer aliases, we'll probably assume that every level has these
local spriteLayer = map.layers["Sprite Layer"]
local groundLayer = map.layers["Ground"]
local frontLayer = map.layers["Front"]
local waterLayer = map.layers["Water"]

-- Prepare World Physics & Collision
initPhys(forces.meter, forces.gravity)
collision = map:initWorldCollision(world)
--peep_collision = Peep.new("collision", collision)

-- Init Ents
sky:init()
ents.Startup()
enems.Startup()
spriteLayer.enemies = {}
initEnemies(spriteLayer.enemies)
addEnemy(spriteLayer.enemies, "bogey", 10)
--addEnemy(spriteLayer.enemies, "bat", 40)
--addEnemy(spriteLayer.enemies, "cat", 25)
ara:init(map, groundLayer, 160,448) -- Call function to add player to map layer
evo:init()
cam:init(ara, evo)
-- name, x, y, size, facing, health, r
local mech = enems.Create( "mech", 600, 300, 500, "left")
local bat = enems.Create( "bat", 600, 300)
--local mech2 = Spriter:loadSpriter( "gfx/enem/", "mech" )
--local mechAnims = mech2:getAnimationNames()
----Set the first animation found as the active animation
--mech2:setCurrentAnimationName( mechAnims[1] )
--mech2:setOffset(0,500)
--local lightning = ents.Create( "lightning", 0, 0, ara.x, ara.y, 4)
peep_g = Peep.new("enems", enems)
--lightning:init(0,0, ara.x, ara.y, 16)

-- SOME TEST STUFF
--First pass at setting up water
--setupWater(waterLayer)
local waterx1, watery1, waterx2, watery2 = 576, 1008, 1104, 1344
--local mesh = ents.Create( "mesh", 300, 200)

function love.update(dt)
  updateShader()
  --dt = math.min(dt, .07)
  dt_buffer = dt_buffer + dt
  if dt_buffer > cam.frDesired then -- Slow motion possible
    dt_buffer = dt_buffer - cam.frDesired

--  wind = wind + 5 * dt

    ara:update(dt, groundLayer)
    evo:update(dt, groundLayer)
--    lightning:setDest(ara.x, ara.y)
--    lightning:setPos(mech.x, mech.y)
--    if dolightning == true then
--      lightning:load(ara.x, ara.y, mech.x + mech.w, mech.y + 40, 4)
--    end

    target = ara
    updateEnemies(spriteLayer, target, dt)

--    peep_map:update(dt)
    peep_g:update(dt)
--    peep_collision:update(dt)
    world:update(dt)
    flux.update(dt)
    
    ents:update(dt)
    enems:update(dt)
    map:update(dt)

  end -- block end for slow motion effect
  cam:update(dt, ara, evo)

  while string.len(cbtxt) > 1424 do
    local newstring = string.sub(cbtxt, -1424)
    cbtxt = newstring
  end
end

function love.draw()
  love.graphics.setCanvas(canvas)

--  local rzoom = maths.round(cam.zoom, 2)
  --local ara = map.layers["Sprite Layer"].ara
--	local player = ara
--	local centering = scrn.scl * cam.zoom
--  local scale = scrn.scl / scrn.fullfactor
  -- This finds the center of the screen, taking into account player offset, and camera offset and zoom
--	local tx = maths.roundby((scrn.w / (scrn.scl / scrn.fullfactor) ) / centering - (player.x + cam.ox), 1 / cam.zoom)
--	local ty = maths.roundby((scrn.h / (scrn.scl / scrn.fullfactor) ) / centering - (player.y - player.h / scrn.scl + cam.oy), 1 / cam.zoom )
--  local tx = scrn.w / scale / centering - ((ara.x + evo.x) / 2) + cam.ox
--	local ty = scrn.h / scale / centering - (( (ara.y - ara.h / scrn.scl) + evo.y ) / 2) + cam.oy
  local tx, ty = cam:getCenter()

  map:setDrawRange(tx, ty, scrn.w / cam.zoom, (scrn.h / cam.zoom))

  lg.setColor(blueblack)
  sky:draw(ara)

--  lg.rectangle("fill", 0, 0, scrn.w, scrn.h)

  love.graphics.setColor(white)
  --This 'saves' the graphics system's state for shenanigans
  love.graphics.push()
  love.graphics.scale(cam.zoom, cam.zoom * scrn.vscl) 	--Set up our zoom
  -- draw the camera at our center point
  love.graphics.translate(math.ceil(tx), math.ceil(ty)) -- can maths.roundby(tx, 1 / maths.clamp(cam.zoom, .02, 1)
  -- Prepare to draw map layers	
  -- Set the lighting to match the sky! In this case we use the top, dark color, and silhouette our buddy against the warm oranges!
  local r,g,b,a = unpack(wlight)
  if a == nil then a = 255 end
  love.graphics.setColor( r - 150, g - 150, b + 50, a - 75 )
--  waterLayer:draw()
  love.graphics.setColor(wlight)
  map:drawTileLayer(groundLayer)
  ara:draw()
  evo:draw()
  ents:draw()
  enems:draw()
  drawEnemies(spriteLayer)
  love.graphics.setColor( r - 150, g - 150, b + 50, a - 75 )
  waterLayer:draw()
  love.graphics.setColor(wlight)

  local ltx, lty = cam:getZoom(240, 0, 480, 480, 20, 1)
  lg.translate(ltx, 0)
  frontLayer:draw() 	-- Draw front parallax
  love.graphics.pop() -- kill the scaling

  --drawLevelUI()
  drawCanvas(unpack(white))
  drawPostFX()
  drawDebugUI()
--  debugWorldDraw(world,0,0,scrn.w, scrn.h)
  --peep_map:draw()
--  peep_collision:draw()
  peep_g:draw()
end

function love.keypressed( key, dt )
  local enemies = map.layers["Sprite Layer"].enemies
  if ( key == "escape" ) then

    -- Loop through the enemies and kill 'em all! ...eventually
    State.switch("menu")
    collectgarbage()
  end
  if key == "i" then
    cam:switchMode()
    cam:switchTarget()
  end
  --local i = 1
  if (key == "t" ) then
    if cam.fps < 60 then
      cam.fps = cam.fps + 5
    end
    flux.to(cam, 1, { frDesired = 1 / cam.fps })
  end
  if (key == "g" ) then
    if cam.fps > 5 then
      cam.fps = cam.fps - 5
    end
    flux.to(cam, 1, { frDesired = 1 / cam.fps })
  end
  if (key == "p" ) and (lctrl == true) then
    deleteAllEnemies(spriteLayer.enemies)
  end
  if (key == "p" ) then 
    addEnemy(spriteLayer.enemies)
  end
  shaderkey(key)

--	if (key == "g" ) then
--		if (i > 1) then i = i - 1 end
--	end
  --wlight = lightmode[i]
  

  

  if (key == "f1" ) then switchScreen() end
  if (key == "o" ) then
    if (debug < 3) then debug = debug + 1
    else debug = 0 end
  end
  if (key == "[" ) then
    --addEnemy("bat", 10)
    require("mobdebug").on()
  end
  if (key == "]" ) then
    require("mobdebug").off()
  end
end

function love.mousepressed(x, y, button)
  cam:getMouse(button)
  if button == "l" or button == "r" then dolightning = true end

--  peep_map:mousepressed(x, y, button)
  peep_g:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  peep_g:mousereleased(x, y, button)
  dolightning = false
end

function love.keyreleased ( key )
  --local ara = map.layers["Sprite Layer"].ara
--	if key == "a" or "left" or "right" or "d" or "s" or "down" then
--		ara.state.input = false
--	end
  if key == "lctrl" then lctrl = false end
  if key == "lalt" then lalt = false end
end

function love.resize(w, h)
  map:resize(w, h)
end

function drawDebugUI()
  -- UI Stuff Goes Here --
  -- do life meter etc
  local buttons = "Buttons: (" .. pAct .. " or " .. sAct .. ") and (" .. pInt .. " or " .. sInt  ..")"
  local dirs = "  " .. pU .. pL .. pD .. pR .. " or " .. sU .. sL .. sD .. sR
  love.graphics.setColor(255, 0, 0, 255)
  love.graphics.print(buttons .. dirs, 30, 30)

  if (debug > 0) then
    love.graphics.setColor(255,30,30)
    love.graphics.printf("Levels - Sideview Systems.",30,60,love.window.getWidth()-100)
    love.graphics.setColor(0,0,0)
    love.graphics.printf("Press 'escape' for main menu.",30,90,love.window.getWidth()-200)

    doPrintStats()
    listEnemies(spriteLayer)
    printKeyPresses()
    if (debug > 1) then
      drawCollisions()
    end
  end

  love.graphics.setColor(green)
  love.graphics.print( '' .. love.timer.getFPS(), 4, 4)
end

function drawCollisions()
  local scrn = {w = love.graphics.getWidth(), h = love.graphics.getHeight(), scl = 2 }
  local zoomR = maths.roundby(cam.zoom, .02)
  local centering = zoomR * scrn.scl ^ 2
  local tx = math.floor( -ara.x + scrn.w / centering - cam.ox)
  local ty = math.floor( -ara.y + scrn.h / centering + ara.h / 2 - cam.oy)
  map:setDrawRange(tx, ty, scrn.w / zoomR, scrn.h / zoomR)

  -- Set for debug collision drawing
  love.graphics.push()
  love.graphics.scale(zoomR, zoomR)
  -- To draw sprite in centre of screen we re-center around the dynamic body
  love.graphics.translate(tx, ty)
  love.graphics.translate(tx, ty)
  love.graphics.scale(zoomR * scrn.scl, zoomR * scrn.scl)
  love.graphics.scale(zoomR * 1 / (zoomR * zoomR), zoomR * 1 / (zoomR * zoomR))
  --Draw Evo's debug collision junks
  love.graphics.setColor(blue)
  love.graphics.circle("line", evo.body:getX(), evo.body:getY(), evo.originSh:getRadius(), 8)

  --Draw Animals debugs junks
  for i=1, #spriteLayer.enemies, 1 do
    if spriteLayer.enemies[i].name == "dog" then
      love.graphics.polygon("line", spriteLayer.enemies[i].body:getWorldPoints(spriteLayer.enemies[i].originSh:getPoints()))
    else
      love.graphics.circle("line", map.layers["Sprite Layer"].enemies[i].body:getX(),
        map.layers["Sprite Layer"].enemies[i].body:getY(), map.layers["Sprite Layer"].enemies[i].size * .8, 12)
    end
  end
  
  --Draw level debug collision junks
  love.graphics.setColor(green)
  map:drawWorldCollision(collision)
  ara:drawCollision()
  enems:drawCollisions()

  love.graphics.pop() -- kill the scaling
end

function doPrintStats()

  printDebugText(blueblack, 4, 201)
  printDebugText(green, 3, 200)

end



function printDebugText(color, x, y)
  local xvel, yvel = ara.body:getLinearVelocity()
  --local ara = spriteLayer.ara
  local curFrame = ara.anim:getCurrentFrame()

--  local walltype = map:getTileKind(groundLayer, ara.ctx, ara.cty)
--  local floortype = map:getTileKind(groundLayer, ara.tx, ara.ty)
--  if groundLayer.data[ara.cty] then if groundLayer.data[ara.cty][ara.ctx] then if groundLayer.data[ara.cty][ara.ctx].properties then
--        walltype = groundLayer.data[ara.cty][ara.ctx].properties.kind
--      end end end
--  if groundLayer.data[fty] then if groundLayer.data[fty][ftx] then if groundLayer.data[fty][ftx].properties then

--        floortype = groundLayer.data[fty][ftx].properties.kind
--      end end end

  local r,g,b = unpack(wlight)
  local hx, hy = ara.head:getPosition()
--  local distance = 0
--  if #spriteLayer.enemies >= 1 then distance = math.floor(getDistancetoTarget(spriteLayer.enemies[#spriteLayer.enemies], ara)) end
  local distances = ""
  for i = 1, #enems do
    distances = distances .. #enems[i].distance .. ", "
  end
  love.graphics.setColor(color)
  love.graphics.print(
    'zoom = ' .. maths.roundby(cam.zoom, .02)	.. '\n' ..
    'z interator = ' .. cam.zit		.. '\n' ..
    'wlight r,g,b = ' .. r .. ' ' .. g .. ' ' .. b	.. '\n' ..
    'wind = ' .. math.floor(forces.wind)	.. '\n' ..
    --'        lightmode = ' .. tostring(lightmode[1])				.. '\n' ..
    --'enemNum = ' .. enemNum						.. '\n' ..
    'Enemies in array = ' .. #spriteLayer.enemies						.. '\n' ..  
    'head.x, .y = ' .. math.floor(hx)	.. ', ' .. math.floor(hy)	.. '\n' ..
    'ara.state.xmov, ymov = ' .. ara.state.xmov	.. ', ' ..	ara.state.ymov	.. '\n' ..  
    'ara.state.facing = ' .. ara.state.facing				.. '\n' ..
    'ara.state.changing = ' .. tostring(ara.state.changing)	.. '\n' ..
    'ara.state.input = ' .. tostring(ara.state.input)		.. '\n' ..
    'anim Speed = ' .. ara.anim.speed	.. '\n' ..
    'ara.anim.cFrame = ' .. curFrame	.. '\n' ..
    'ara xvel, yvel = ' .. maths.round(xvel, 4)	.. ', ' .. maths.round(yvel, 4) .. '\n' .. 
    'ara.x, .y, .r = ' .. math.floor(ara.x)	.. ', ' .. math.floor(ara.y) .. ', ' .. ara.r .. '\n' ..
    'ara.tile.x, .y, .kind, .col = ' .. ara.tile.x .. ', ' .. ara.tile.y .. ", " .. ara.tile.kind .. '\n' ..
    'ara.fronttile.x, .y, .kind, .col = ' .. ara.fronttile.x .. ', ' .. ara.fronttile.y .. ", " .. ara.fronttile.kind .. ", " .. tostring(ara.fronttile.collides) ..'\n' ..
    'obstacle height = ' .. ara.state.obstacleheight .. "\n" ..
    'cam.fps, .target1, .target2, .mode = ' .. cam.fps .. ', ' .. cam.target1.name .. ', ' .. cam.target2.name .. ', ' .. cam.mode ..'\n' ..
    'cam.x, .y, .ox, .oy, .attached = ' .. math.floor(cam.tx) .. ', ' .. math.floor(cam.ty) .. ', ' .. math.floor(cam.ox) .. ', ' .. math.floor(cam.oy) .. ", " .. tostring(cam.attached) .. '\n' ..
    'distances = ' .. distances .. '\n' ..
    'outx, outy = ' .. outx .. " " .. outy .. '\n' ..
    'callBack Counter = ' .. cbpersists .. '\n'
    -- 'evo.x =         	' .. evo.x 				.. '\n' ..
    -- 'evo.y =           	' .. evo.y 				.. '\n' ..
    -- 'evo.rot =         	' .. evo.rot 			.. '\n' ..
    -- 'evo.rot (deg) =   	' .. math.deg(evo.rot) 	.. '\n' ..
    -- 'evo.speed =       	' .. evo.speed			.. '\n' ..
    , x, y)
  if (debug > 2) then love.graphics.print(cbtxt, x + scrn.w/2, y - 150) end
end

function get_key_for_value( t, value )
  for k,v in pairs(t) do
    if v==value then return k end
  end
  return nil
end