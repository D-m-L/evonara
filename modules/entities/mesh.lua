local ent = ents.Derive("base")

-- Testing front projection
--tvoff, tuoff, txoff, tyoff = 0, 0, 0, 0
-- local grscreen = lg.newImage('gfx/lofi/greenscreen.png')
-- local triangle = lg.newMesh( {{0,0, 0,0},{scrn.w,0, 1,0},{scrn.w,scrn.h, 1,1},{0,scrn.h, 0,1}} , grscreen, strip )
-- --triangle:setWrap("repeat")

--  for i=1, triangle:getVertexCount() do
--    local tx, ty, tu, tv = triangle:getVertex( i )
--    tx, ty, tu, tv = tx + txoff, ty - tyoff, tu + tuoff, tv + tvoff
--    triangle:setVertex(i, tx, ty, tu, tv)
--  end
--  lg.setColor(white)
	-- lg.draw(triangle)
  
function ent:newSurface(...)
--	local surface = lg.newImage("gfx/"..MODE.theme.."/surface.png");
--	surface:setWrap("repeat", "repeat");

	local tri = love.math.triangulate({...});
	local mpoint = {};
	for i,v in pairs(tri) do
		local d = 70;
		table.insert(mpoint, {{v[1], v[2], v[1]/d, v[2]/d}, {v[3], v[4], v[3]/d, v[4]/d}, {v[5], v[6], v[5]/d, v[6]/d}});
	end

	for i,v in pairs(mpoint) do
		local m = love.graphics.newMesh(v, self.image, "triangles");
		table.insert(mesh, {mesh = m, points = {...}});
	end
  
  return mesh
end

function ent:setPos(x, y )
  self.x = x
  self.y = y
end

function ent:load( x, y )
	self.x, self.y = x, y
  self.image = lg.newImage('gfx/lofi/greenscreen.png')
	self.image:setWrap("repeat", "repeat")
	self.ih = self.image:getHeight()
	self.iw = self.image:getWidth()
--  self.mesh = {}
	self.points = {{0,0},{20,0},{20,20}}

  self.mesh = self.newSurface(unpack(self.points))

  self:setPos( x, y )
  self.w = 48 * 4
  self.h = 48 * 4
  self.bouncespeed = 8
  self.bounceheight = 16
end

function ent:setSize( w, h )
  self.w = w
  self.h = h
end

function ent:getSize()
  return self.w, self.h
end

function ent:update(dt)
	local down = love.keyboard.isDown
  -- self.y = self.fixed_y + math.sin(love.timer.getTime() * self.bouncespeed) * self.bounceheight
	  if lalt == true then
    if down("kp8") then
      self:setPos(self.x, self.y - 100 * dt)
		elseif down("kp6") then
      self:setPos(self.x + 100 * dt, self.y)
		elseif down("kp2") then
      self:setPos(self.x, self.y + 100 * dt)
		elseif down("kp4") then
      self:setPos(self.x - 100 * dt, self.y)
    end
  
  end
end

function ent:draw()
--  local x, y = self:getPos()
--  local w, h = self:getSize()
--  for i = 1, #self.mesh do
    love.graphics.draw( self.mesh, math.floor(self.x), math.floor(self.y), self.r, self.sx, self.xy, 0, 0 )
--  end
end

return ent

