local State = require 'modules/libs/stateswitcher'
require 'modules/libs/steering'

ents.Startup()
local map = ents.Create( "cave", 0, 0, 320*4, 180*4, 24)
--map.tilesize = 48
map:setScoopPercent(.40)
peep_map = Peep.new("map", map)

initPhys(24, gravity)
--collision = map:initWorldCollision(world)

local ara = require 'modules/heroes/ara'
local evo = require 'modules/heroes/evo'
local cam = require 'modules/heroes/cam'

ara:init(map, map, map.width/2 * 24, map.height/2 * 24) -- Call function to add player to map layer
evo:init()
cam:init()

function love.update(dt)
  updateShader()

  if map.finished == true and arastarted ~= true then
    ara:init(map.startx, map.starty) -- Call function to add player to map layer
    arastarted = true
  end

  --dt = math.min(dt, .07)
  dt_buffer = dt_buffer + dt
  if dt_buffer > cam.frDesired then -- Slow motion possible
      dt_buffer = dt_buffer - cam.frDesired
  ents:update(dt, ara)
  
  ara:update(dt, collision) --, groundLayer)
  evo:update(dt) --, groundLayer)
  peep_map:update(dt)
  world:update(dt)
  flux.update(dt)
  end -- block end for slow motion effect
	

end

function love.draw()
  lg.setCanvas(canvas)
  lg.setColor(0,00,000,255)
  lg.rectangle("fill", 0, 0, scrn.w, scrn.h)

  local player = ara
  local centering = scrn.scl * cam.zoom
  -- This finds the center of the screen, taking into account player offset, and camera offset and zoom
  local tx = maths.roundby((scrn.w / (scrn.scl / scrn.fullfactor) ) / centering - (player.x + cam.ox), 1 / cam.zoom)
  local ty = maths.roundby((scrn.h / (scrn.scl / scrn.fullfactor) ) / centering - (player.y - player.h / scrn.scl + cam.oy), 1 / cam.zoom )

  love.graphics.setColor(white)
  --This 'saves' the graphics system's state for shenanigans
  love.graphics.push()
  if shader == true then
    love.graphics.scale(cam.zoom, cam.zoom * 2) 	--zoom is different due to shader geomtry
  else
    love.graphics.scale(cam.zoom, cam.zoom) 	--Set up our zoom
  end
  -- draw the camera at our center point
  love.graphics.translate(tx, ty)
 
  --evo:draw()
  ents:draw(player, cam)
  lg.setColor(s3top)
  if arastarted == true then
    ara:draw()
  end
  --drawEnemies(spriteLayer)
  
  love.graphics.pop() -- kill the scaling
  --drawLevelUI()
  lg.setColor(white)
  drawCanvas()
  
  if debug >= 1 then    drawCollisions()
  end
  printDebugText(21, 21, blueblack)
  printDebugText(20, 20, green)
  map.totaldrawn = 0
  drawDebugUI()
  peep_map:draw()
end

function drawDebugUI()
	love.graphics.setColor(green)
    love.graphics.print( '' .. love.timer.getFPS(), 4, 4)
end

function printDebugText(x, y, color)
  lg.setColor(unpack(color))
  love.graphics.print(
    'zoom = ' .. maths.roundby(cam.zoom, .02)	.. '\n' ..
		'z interator = ' .. cam.zit		.. '\n' ..
		'cam offsets = ' .. cam.ox		.. ', ' .. cam.oy		.. '\n' ..
		'ara tile = ' .. ara.tx		.. ', ' .. ara.ty		.. '\n' ..
		'cave.totaldrawn = ' .. map.totaldrawn	.. '\n' ..
		'cave.miners = ' .. #map.miners	.. '\n' ..
    'cave.activeminers = ' .. map.activeminers	.. '\n' ..
		'cave.finished = ' .. tostring(map.finished)	.. '\n' ..
		'cave.cleanedsingles = ' .. tostring(map.cleanedsingles)	.. '\n' ..

    'mapw, maph = ' .. map.width .. " " .. map.height .. '\n' ..
    'Final scoops= ' .. map.tscoops .. '\n' ..
    'Performed scoops= ' .. map.nscoops .. '\n' ..
    'Remaining scoops= ' .. map.tscoops - map.nscoops .. '\n' ..
    'cave.lowpoint= ' .. map.lowpoint .. '\n'
                              , x, y)
    
end

function love.keypressed( key )
	if ( key == "escape" ) then
		State.switch("menu")
    collectgarbage()
	end

  if (key == "k" ) then
    if map.finished == true then map.finished = false else map.finished = true end
  end
  if (key == "l" ) then
--    if drawDeadMiners == true then drawDeadMiners = false else drawDeadMiners = true end
  end
--  if (key == "i" ) then
--    map:cleanSingles()
--  end
  if (key == "o" ) then
    if debug == 1 then debug = 0 else debug = 1 end
  end
--  if (key == "p" ) then
--    map:createPools( math.floor(cave.height/6) )
--  end
end

function love.mousepressed(x, y, button)

  if button == "wu" then  
		if cam.zit < #cam.zsteps then
      flux.to(cam, 1, { zoom = cam.zsteps[cam.zit + 1], oy = cam.oy + cam.oy / cam.zoom })
      cam.zit = cam.zit + 1 end
	end
	if button == "wd" then  
		if cam.zit > 1 then
      flux.to(cam, 2, { zoom = cam.zsteps[cam.zit - 1] })
      cam.zit = cam.zit - 1 end
	end
	
	maths.wrap(cam.zit, 1, #cam.zsteps)
  peep_map:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  peep_map:mousereleased(x, y, button)
end

function drawCollisions()
	local scrn = {w = love.graphics.getWidth(), h = love.graphics.getHeight(), scl = 2 }
	local zoomR = maths.roundby(cam.zoom, .02)
	local centering = zoomR * scrn.scl ^ 2
	local tx = math.floor( -ara.x + scrn.w / centering - cam.ox)
	local ty = math.floor( -ara.y + scrn.h / centering + ara.h / 2 - cam.oy)
	--map:setDrawRange(tx, ty, scrn.w / zoomR, scrn.h / zoomR)
	
	-- Set for debug collision drawing
	love.graphics.push()
	love.graphics.scale(zoomR, zoomR)
	-- To draw sprite in centre of screen we re-center around the dynamic body
	love.graphics.translate(tx, ty)
	love.graphics.translate(tx, ty)
	love.graphics.scale(zoomR * scrn.scl, zoomR * scrn.scl)
	love.graphics.scale(zoomR * 1 / (zoomR * zoomR), zoomR * 1 / (zoomR * zoomR))

	--Draw level debug collision junks
	love.graphics.setColor(green)
	map:drawWorldCollision(map.collision, ara, cam)
	
	love.graphics.pop() -- kill the scaling
end