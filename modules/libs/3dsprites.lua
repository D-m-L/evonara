-- screen.x = x / distance; IOW -- u = x / z;  ??
-- screen.y = y / distance; IOW -- v = y / z;  ??
--function drawSpritePersp(worldx, worldy, image, referencex, referencey, scale)
--end

local dotscene = {}

dotscene[1] = { x = 0, y = 0, z = 0 }

 for i = 2, 50 do
	 dotscene[i] = {
		 x = math.random(1, 20),
		 y = 0,
		 z = -math.random(1, 20),
	 }
 end

local polyscene = {}
for i = 1, 50 do
	polyscene[i] = {
		a = { x = -1, y = -1, z = -1 },
		b = { x =  0, y =  1, z = -1 },
		c = { x =  1, y = -1, z = -1 },
	}
end

function rotateY(r)
	local cosR = math.cos(r)
	local sinR = math.sin(r)
	for _, vertex in pairs(dotscene) do
		local x = vertex.x
		local z = vertex.z
			vertex.x = x*cosR + z*sinR
			vertex.z = x*-sinR + z*cosR
	end
end

function rotateZ(r)
	local cosR = math.cos(r)
	local sinR = math.sin(r)
	for _, vertex in pairs(dotscene) do
		local x = vertex.x
    local y = vertex.y
		local z = vertex.z
			vertex.x = x*cosR + z*sinR
			vertex.y = y*sinR + z*cosR
	end
end

function project(vertex)
	local x = vertex.x / -vertex.z
	local y = vertex.y / -vertex.z * -1 --flip y for conversion
	
	x = x * 10 + scrn.w/ 4 
	y = y * 10 + scrn.h/ 8 
	
	return x, y, vertex.z
end

function drawSprite3d(x, y, tex, ox, oy, r, s, w, h)
--  local render = {}
  
	for _, poly in pairs(polyscene) do
		local ax, ay, az = project(poly.a)
		local bx, by, bz = project(poly.b)
		local cx, cy, cz = project(poly.c)
    
--    if az < 0 or bz < 0 or cz < 0 then
--      render[#render + 1] = {
        
--      }
--    end
		
--		love.graphics.polygon("fill", ax, ay, bx, by, cx, cy)
	end

	for _, vertex in pairs(dotscene) do
		if vertex.z < 0 then
			local x, y, z = project(vertex)
			
			love.graphics.setColor(darkorange)
--			love.graphics.circle("fill", x, y, 6/ -z, 10)
      lg.draw(tree.tex, x, y - tree.h / 2 + pitch, 0, 1/ -z, 1/ -z)
		end
	end
end

function translateSprites(x,y,z)
	for _, vertex in pairs(dotscene) do
		vertex.x = vertex.x + x / 200
		vertex.y = vertex.y + y / 200
		vertex.z = vertex.z + z / 200
	end
end

function translatePolys(x,y,z)
  for _, poly in pairs(polyscene) do
    for _, vertex in pairs(poly.a, poly.b, poly.c) do
      vertex.x = vertex.x + x
      vertex.y = vertex.y + y
      vertex.z = vertex.z + z
    end
  end
end

function updateSprite3d(dt)
	local moveSpeed = dt
	
	--if 
end
	
	-- local t = love.timer.getTime()

    -- sort(drawCalls)

	-- for j, c in pairs(drawCalls) do
		-- local i = #drawPool + 1
		-- drawPool[i] = c.id
	-- end

	-- for i = 0, #drawPool do
		-- local spr = drawCalls[i]
		-- if spr ~= nil then
			-- if spr.type == "sprite" then

				-- local halfWidth = (spr.sx*tileSize)/2
				-- setColor(255*spr.lum,255*spr.lum,255*spr.lum)
				-- draw(spriteObj.img, spriteObj.quad[spr.img], spr.x-halfWidth, spr.y + spr.sy * tileSize, 0, spr.sx, spr.sy, 0, tileSize * spr.tall)

		-- end
	-- end

	-- debugger.time.world = love.timer.getTime() - t
-- end
--end