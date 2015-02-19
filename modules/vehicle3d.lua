local state = require 'modules/libs/stateswitcher'
local Sti = require 'modules/libs/STI'
require 'modules/libs/mode7'
require 'modules/libs/3dsprites'
--translateSprites(-25, 0, -75)

-- So far, I'm expecting a string = "atmos" or "jumper"
mode=passvar[1]

local atime = 0
local btime = love.timer.getTime()
local ascending = false
local trendingleft = false

idle = {
}

--Depth between layers
depth = .9
--Water animation offset
waterOff = 0

-- I have no idea why, but this makes the buildings almost perfect
bldVscale = 1000
psCorr = .001
buildSlices = 8
something = 1

if (mode == "jumper") then fog = nil else fog = nil end

tree = {
  tex = love.graphics.newImage('gfx/tree.png'),
  x = 282,
  y = 740,
  z = 0,
  visible = true,
}
tree.h = tree.tex:getHeight()

sprite = {}
sprite[1] = { tree }

canThrust = true
--zoom = 2
minHeight = .2
maxHeight = .0008
pitch = 90
hAccel = 0
FOV = 90 -- this is actually more like the pivot offset -- 180: the bottom of our canvas, 90: bottom 3/4ths, etc
--viewDist = (scrn.w / 2) / math.tan( (FOV / 2) )

-- Load Map
local map = Sti.new("maps/island01")
peep_map = Peep.new("map", map)
local groundLayer = map.layers["Ground"]

if (mode == "atmos") then
  cam.alt = .0008
  level = {
    --tex = love.graphics.newImage('fishmazeclear.png'),
    ground = love.graphics.newImage('gfx/earth.png'),
  }
  evo = {
    tex = love.graphics.newImage('gfx/evo/atmos.png'), 
    x = 533,
    y = 1498,
    rot = .1352,
    gforce = 0,
    speed = 0,
    grip = 0,
    quad = {}
  }
elseif (mode == "jumper") then
  cam.alt = .05
  fog = true
  level = {
    --ground = love.graphics.newImage('gfx/mode7/worldmaptest.png'),
    ground = love.graphics.newImage('gfx/ground.png'),
    shadows = love.graphics.newImage('gfx/shadows.png'),
    ocean = love.graphics.newImage('gfx/ocean.png'),
    buildings = love.graphics.newImage('gfx/buildings.png'),
    bg = { image = love.graphics.newImage('gfx/skies/sky3.png'), x = 0, y = 0, },
  }
  evo = {
    tex = love.graphics.newImage('gfx/evo/jump.png'), 
    x = 0,
    y = 0,
    z = 0,
    rot = math.rad(270),
    gforce = 0, --G force (left/right)
    speed = 0,
    grip = 0,
    quad = {}
  }

  bgH = level.bg.image:getHeight()
  bgW = level.bg.image:getWidth()
  grndH = level.ground:getHeight()
  grndW = level.ground:getWidth()
else
  cam.alt = .0033
  FOV = 100

  level = {
    ground = love.graphics.newImage('gfx/test.png'),
    bg = { image = love.graphics.newImage('gfx/skies/sky2.png'), x = 0, y = 0, },
  }
  level.bg.h = lg.getHeight(level.bg.image)
  evo = {
    tex = love.graphics.newImage('gfx/evo/jump.png'), 
    x = 170,
    y = 186,
    rot = 0,
    gforce = 0,
    speed = 0,
    grip = 0,
    quad = {}
  }

  bgH = level.bg.image:getHeight()
  bgW = level.bg.image:getWidth()
  grndH = level.ground:getHeight()
  grndW = level.ground:getWidth()
end

function love.update(dt)
  camHr   = maths.round(cam.alt, 4)
  evoxr   = maths.roundby(evo.x, .25)
  evoyr   = maths.roundby(evo.y, .25)
  evorot  = maths.round(evo.rot, 2)
  hAr     = maths.roundby(hAccel, .5)
  --if (scrn == nil) then
  --jumperInit()
  --end

  --if (printStats) then
  doMouse(dt) doKeys(dt) --end
  doWater(dt)
  --simulate(dt)
  logic(dt)

end

function doWater(dt)
  --Animate Water
  atime = atime + dt
  if (atime > .2) then
    if (depth > .9 and ascending == false) then depth = depth - .005 end
    if (depth <= .9) then ascending = true end
    if (depth < .95 and ascending == true) then depth = depth + .005 end
    if (depth >= .95) then ascending = false end
    --atime = love.timer.getTime()
    atime = 0
  end	

  if (love.timer.getTime() > btime + .5) then	
    -- if (waterOff < 8 ) then waterOff = waterOff + 1 end
    -- if (waterOff == 8) then waterOff = 0 end
    waterOff = maths.wrap(waterOff + 1, 0, 8)
    btime = love.timer.getTime()
  end
end


function love.draw()
  map:setDrawRange(0, 0, 1024, 1024)
  love.graphics.setCanvas(canvas)
  love.graphics.clear(canvas)

  -- Set solid BG Color
  if (mode == "atmos") then -- Deep spacea
    love.graphics.setColor(blueblack)
    love.graphics.rectangle('fill', 0, 0, scrn.w, scrn.h)

    -- reset color for bg and ground - night effects possible!!
    love.graphics.setColor(white)

    local cw = scrn.w/2
    local ch = scrn.h/2

    -- Earth plane
    drawMode7(evoxr, evoyr, level.ground, 0, FOV, evorot, camHr, cw , ch )
    drawMode7_2(evoxr, evoyr, level.ground, 0, FOV, evorot, camHr, cw , ch )
    drawMode7_4(evoxr, evoyr, level.ground, 0, FOV, evorot, camHr, cw , ch )
    drawMode7_6(evoxr, evoyr, level.ground, 0, FOV, evorot, camHr, cw , ch )
    drawMode7_8(evoxr, evoyr, level.ground, 0, FOV, evorot, camHr, cw , ch )

  elseif (mode == "jumper") then -- Sky & Water
    -- draw above the BG
    love.graphics.setColor(orange)
    love.graphics.rectangle('fill', 0, 0, scrn.w, level.bg.y)

    --Water
    love.graphics.setColor(purple)
    love.graphics.rectangle('fill', 0, level.bg.y, scrn.w, scrn.h)

    -- reset and draw sky/background - night effects possible!!
    love.graphics.setColor(white)
    level.bg.x = maths.clamp(evorot % bgW * 326, -bgW, bgW)
    love.graphics.draw(level.bg.image, level.bg.x, level.bg.y + 2)
    love.graphics.draw(level.bg.image, level.bg.x - bgW, level.bg.y + 2)

    -- Drawn in splits to simulate SNES-like error
    local cO = 512 + waterOff
    local cw = scrn.w/2
    local ch = canvas:getHeight()
    step = 2
    local waterx = maths.wrap(evoxr, evoxr - 4, evoxr + 4)

    -- Water plane
--    drawMode7(cO + waterx, cO + evoyr, level.ocean, 0, FOV, evorot, camHr * depth, cw , ch )
--    drawMode7_2(cO + waterx, cO + evoyr, level.ocean, 0, FOV, evorot, camHr * depth, cw , ch )
--    drawMode7_4(cO + waterx, cO + evoyr, level.ocean, 0, FOV, evorot, camHr * depth, cw , ch )
--    drawMode7_6(cO + waterx, cO + evoyr, level.ocean, 0, FOV, evorot, camHr * depth, cw , ch )
--    drawMode7_8(cO + waterx, cO + evoyr, level.ocean, 0, FOV, evorot, camHr * depth, cw , ch )

--    -- Shadow plane
--    drawMode7(evoxr, evoyr, level.shadows, 0, FOV, evorot, camHr * depth, cw , ch )
--    drawMode7_2(evoxr, evoyr, level.shadows, 0, FOV, evorot, camHr * depth, cw , ch )
--    drawMode7_4(evoxr, evoyr, level.shadows, 0, FOV, evorot, camHr * depth, cw , ch )
--    drawMode7_6(evoxr, evoyr, level.shadows, 0, FOV, evorot, camHr * depth, cw , ch )
--    drawMode7_8(evoxr, evoyr, level.shadows, 0, FOV, evorot, camHr * depth, cw , ch )

    -- Main plane
      drawMode7tile(map, groundLayer, evoxr, evoyr, 0, FOV, evorot, camHr, cw , ch )
--    drawMode7_2(evoxr, evoyr, level.ground, 0, FOV, evorot, camHr, cw , ch )
--    drawMode7_4(evoxr, evoyr, level.ground, 0, FOV, evorot, camHr, cw , ch )
--    drawMode7_6(evoxr, evoyr, level.ground, 0, FOV, evorot, camHr, cw , ch )
--    drawMode7_8(evoxr, evoyr, level.ground, 0, FOV, evorot, camHr, cw , ch )

    -- Buildings
--    for slice = 1,buildSlices do
--      drawMode7(
--        evoxr, evoyr, level.buildings, 0, FOV, evorot,
--        camHr * (slice * (2 * pitch) + bldVscale) * psCorr, cw, ch )
--      drawMode7_2(
--        evoxr, evoyr, level.buildings, 0, FOV, evorot,
--        camHr * (slice * (2 * pitch) + bldVscale) * psCorr, cw, ch )
--      drawMode7_4(
--        evoxr, evoyr, level.buildings, 0, FOV, evorot,
--        camHr * (slice * (2 * pitch) + bldVscale) * psCorr, cw, ch )
--      drawMode7_6(
--        evoxr, evoyr, level.buildings, 0, FOV, evorot, 
--        camHr * (slice * (2 * pitch) + bldVscale) * psCorr, cw, ch )
--      drawMode7_8(
--        evoxr, evoyr, level.buildings, 0, FOV, evorot,
--        camHr * (slice * (2 * pitch) + bldVscale) * psCorr, cw, ch )
--    end

    drawSprite3d()

  else
    -- draw above the BG
    love.graphics.setColor(darkorange)
    love.graphics.rectangle('fill', 0, 0, scrn.w, scrn.h / 4)

    -- Dark BG
    -- love.graphics.setColor(0, 0, 64)
    -- love.graphics.rectangle('fill', 0, scrn.h / 4, scrn.w, scrn.h)

    -- -- reset and draw sky/background - night effects possible!!
    love.graphics.setColor(white)
    level.bg.x = -evoxr / 2
    love.graphics.draw(level.bg.image, level.bg.x / 2, scrn.h / 4 - bgH)

    -- local cO = 1024 + waterOff
--    local cw = canvas:getWidth()
--    local ch = canvas:getHeight()
    -- local step = 2

    -- -- Main plane				--offsetx, offsy, rot, 
--    drawMode7floorEx(evoxr, evoyr, level.ground, 0, FOV, 0, camHr, scrn.w, scrn.h )

--    rasterScroll(evoxr, evoyr, level.ground, something, FOV, 0, 1, scrn.w, scrn.h )
    love.graphics.draw(level.ground, -evo.x/2, 180, 0, 10, 1, 0, 0, -evo.x/50, 0)

--    drawSpritePersp()
  end

  -- reset color
  love.graphics.setColor(white)

  -- Draw player character
  --love.graphics.draw(evo.tex, evo.quad[3], scrn.w/2, scrn.h * .9 + pitch, 0, scrn.scl * math.sign(-evo.gforce), scrn.scl, 32, 64)
  -- for i=1,#idle do
  -- idle[i]:draw(evo.tex, i*75, i*50)
  -- end

  love.graphics.setCanvas()
  love.graphics.push()
  love.graphics.origin()
  love.graphics.draw(canvas, 0, 0, 0, scrn.scl, scrn.scl)
  love.graphics.pop()

  -- Draw Fog
  if (fog) then
    love.graphics.setColor(fogyellow)
    love.graphics.rectangle('fill', 0, math.floor(pitch * scrn.scl), scrn.w, math.floor(split1 * 0.04) * scrn.scl )
    love.graphics.rectangle('fill', 0, math.floor(pitch * scrn.scl), scrn.w, math.floor(split2 * 0.03) * scrn.scl )
    love.graphics.rectangle('fill', 0, math.floor(pitch * scrn.scl), scrn.w, math.floor(split3 * 0.02) * scrn.scl )
    love.graphics.rectangle('fill', 0, math.floor(pitch * scrn.scl), scrn.w, math.floor(split4 * 0.02) * scrn.scl )
  end

--  drawPostFx()
  drawDummyUI()

end

function doAtmosLogic(dt)
  -- In space, our acceleration will be really slow. TBD how fast, since if I do lasers, how long do I want the level to last?
  -- As long as our height is above ground, then fall
  if (cam.alt <= 1) then cam.alt = cam.alt + (cam.alt * dt) * hAccel end
  if (evo.x > 490) then evo.x = (evo.x - .05) end
  if (evo.y > 450) then evo.y = (evo.y - .37) end
  evo.rot = evo.rot - .0001
  -- Acceleration due to gravity	
  if (hAccel <= 2) then hAccel = (hAccel + .00004)  end
end

function logic(dt)

  split1 = scrn.h * (.1 / cam.alt * .15 )
  ssplit1 = maths.clamp(split1, 0, scrn.h )
  split2 = scrn.h * (.2 / cam.alt * .15 )
  ssplit2 = maths.clamp(split2, 10, scrn.h )
  split3 = scrn.h * (.5 / cam.alt * .15 )
  ssplit3 = maths.clamp(split3, 20, scrn.h )
  split4 = scrn.h * (.9 / cam.alt * .15 )
  ssplit4 = maths.clamp(split4, 30, scrn.h )

  if (mode == "atmos") then
    doAtmosLogic(dt)
  elseif (mode == "jumper") then	
    -- Thrusters
    if love.keyboard.isDown(' ') then
      -- If we're below our ceiling, and the thrusters haven't cut out, apply thrust
      if (cam.alt >= maxHeight) and (canThrust) then
        -- If we're good, then apply thrust.
        if (hAccel >= -.8) then hAccel = (hAccel - .08) end
      end
    end
    level.bg.y = math.ceil(pitch - bgH)
    --doGravity()

    -- When we reach the upper limit, cut thrusters
    if (cam.alt < maxHeight) then
      --cam.alt = maxHeight
      canThrust = nil
    end
    -- At low, Bounce on the ground
    if (cam.alt > minHeight) then
      cam.alt = minHeight
      hAccel = -hAccel / 2
    end
    -- Pitch the camera based on height - 800 is a magic number : (
    pitch = math.floor(cam.alt * 800)

    evo.grip = (1 - math.abs(evo.gforce)) * evo.speed
    if joy('gas') then
      evo.speed = evo.speed + dt / 5
--    translateSprites(50 * dt, 0, 0)
--    evo.y = evo.y - 50 * dt

    elseif joy('brake') then
--    translateSprites(-50 * dt, 0, 0)
      evo.speed = evo.speed - (evo.speed * dt) * 2
--        evo.y = evo.y + 50 * dt

    else
      evo.speed = evo.speed - (evo.speed * dt) * .5
    end

    if joy('right') then
--      if evo.gforce > 0 then evo.gforce = evo.gforce/2 end
--      --If the G force is the opposite way you're turning, it will quickly align in your favor
      evo.gforce = evo.gforce - dt * 15
--      translateSprites(0, 0, -50 * dt )
--      evo.x = evo.x - 50 * dt

    elseif joy('left') then
--      if evo.gforce < 0 then evo.gforce = evo.gforce/2 end
      evo.gforce = evo.gforce + dt * 15
--      translateSprites(0, 0, 50 * dt)
--      evo.x = evo.x + 50 * dt

    else
      evo.gforce = evo.gforce - (evo.gforce * dt) * 10
      --Straightens up when not turning
    end
  
    evo.grip = maths.clamp(2.5 - math.abs(evo.gforce) - evo.speed, 0, 1)
    --Calculates your max speed based on how hard you're turning
    evo.speed = maths.softclamp(evo.speed, -evo.speed, evo.grip, .5, dt)
    evo.gforce = maths.clamp(evo.gforce, -1, 1)
    --Keeps limits in check
    evo.rot = evo.rot + (evo.gforce * evo.grip)*dt*2
    evo.rot = evo.rot + (evo.gforce * evo.grip)*dt*2
    evo.rot = maths.wrap(evo.rot, 0, math.pi * 2)
    rotateY(-(evo.gforce * evo.grip)*dt*4)

    local xdisp = math.deg(evo.speed/4)
    local ydisp = math.deg(evo.speed/4)
    evo.x = evo.x -  xdisp * math.cos(evo.rot - math.pi/2) * (dt * 10)
    evo.y = evo.y +  ydisp * math.sin(evo.rot - math.pi/2) * (dt * 10)
--    translateSprites(0, math.deg(evo.speed/4)*math.cos(evo.rot - math.pi/2) * (dt * 10), -math.deg(evo.speed/4)*math.sin(evo.rot - math.pi/2) * (dt * 10))
    translateSprites(0, 0, math.abs(xdisp) * dt * 100)
    translateSprites(-math.abs(ydisp) * dt * 100, 0, 0)

  else
    if joy('gas') then

      evo.y = evo.y - 100 * dt
    elseif joy('brake') then
      --if (evo.y <= grndH + 8) then evo.y = evo.y + 50 * dt else evo.y = grndH + 8 end
      evo.y = evo.y + 100 * dt
    else
      --evo.speed = evo.speed - (evo.speed * dt) * .5
    end
    if joy('right') then
      --if (evo.x <= grndW - 192) then evo.x = evo.x + 50 * dt else evo.x = grndW - 192 end
      evo.x = evo.x + 100 * dt
    elseif joy('left') then
      --if (evo.x >= 192) then evo.x = evo.x - 50 * dt else evo.x = 192 end
      evo.x = evo.x - 100 * dt
    end
  end


end

function drawDummyUI()
  love.graphics.setColor(128, 255, 128)
  love.graphics.rectangle('fill', scrn.w/2 - 32, scrn.h * .9, 64, 8)
  love.graphics.setColor(255, 0, 0)
  love.graphics.rectangle('fill', -evo.gforce * 32 + scrn.w/2, scrn.h * .9, 2, 8)
  love.graphics.setColor(0, 0, 255)
  love.graphics.rectangle('fill', (evo.gforce*maths.clamp(evo.speed * 2, 0, .5) * evo.grip) * 32 + scrn.w/2, scrn.h * .9, 2, 8)

  love.graphics.setColor(128, 255, 128)
  love.graphics.rectangle('fill', scrn.w/2 - 64, scrn.h * .8, 8, 64)
  love.graphics.setColor(255, 0, 0)
  love.graphics.rectangle('fill', scrn.w/2 - 64, scrn.h * .8 - evo.grip * 128 + 128, 8, 2)

  love.graphics.setColor(128, 255, 128)
  love.graphics.rectangle('fill', scrn.w/2 + 64, scrn.h * .8, 8, 64)
  love.graphics.setColor(255, 0, 0)
  love.graphics.rectangle('fill', scrn.w/2 + 64, scrn.h * .8 - evo.speed * 64 + 64, 8, 2)


  if (printStats) then doPrintStats() end
end

function doGravity(dt)
  -- Jumper: As long as our height is above ground, then fall
  if (cam.alt <= minHeight) then
    cam.alt = cam.alt + (cam.alt * dt) * hAccel
  end

  if (hAccel <= 0.04) and (cam.alt >= minHeight + .01) then hAccel = 0 cam.alt = minHeight end
  if (hAccel <= 0) then hAccel = (hAccel + .04)  end
  if (hAccel >= .04) then
    if (hAccel <= 2) then
      hAccel = (hAccel + .04)
    end
    hAccel = (hAccel - .005)  end
  end

  function doPrintStats()
    love.graphics.setColor(0,255,0)
    love.graphics.print(
      'waterOffset = 		' .. waterOff		 	.. '\n' ..
      'atime = 			' .. atime 				.. '\n' ..
      'something = 		' .. something 		.. '\n' ..
      'pitch = 			' .. pitch 				.. '\n' ..
      'height = 			' .. camHr 	.. '\n' ..
      'hAccel = 			' .. hAccel 			.. '\n' ..
      'evo.x =         	' .. evoxr 				.. '\n' ..
      'evo.y =           	' .. evoyr 				.. '\n' ..
      'FOV =         	' .. FOV 			.. '\n' ..
      'evo.rot (deg) =   	' .. math.deg(evo.rot) 	.. '\n' ..
      'evo.speed =       	' .. evo.speed			.. '\n' ..
      'FPS =          ' .. love.timer.getFPS()
      , 0, 0
    )
  end

function doMouse(dt)
    mouse = {
      l = love.mouse.isDown('l'),
      r = love.mouse.isDown('r'),
      x = love.mouse.getX(),
      y = love.mouse.getY(),
    }

    if mouse.l then something = something + .2 * dt end
    if mouse.r then something = something - .2 * dt end
end

function doKeys(dt)
  local down = love.keyboard.isDown
--  if love.keyboard.isDown('t') then cam.alt = cam.alt + .005 * dt end
--  if love.keyboard.isDown('g') then cam.alt = cam.alt - .005 * dt end
  if love.keyboard.isDown('t') then rotateZ(dt / 2) end
  if love.keyboard.isDown('g') then rotateZ(dt / 2) end
  if love.keyboard.isDown('y') then psCorr = psCorr + .00001 end
  if love.keyboard.isDown('h') then psCorr = psCorr - .00001 end
--  if down('q') then
--    rotateY(dt * 2)
--  elseif down('e') then
--    rotateY(-dt * 2)
--  end
end

function joy(key)
    if love.keyboard.isDown(unpack(controls[key])) then return true else return false end
end

function love.keypressed( key, unicode )
    if key == ('t') then rotateZ(.003) end
    if key == ('g') then rotateZ(.003) end
    if ( key == "escape" ) then state.switch("mainmenu") collectgarbage() end
    if ( key == "f1" ) then switchScreen() end
    if (key == "o" ) then
      if (printStats) then printStats = nil
      else printStats = true end
    end
end