local ent = ents.Derive("base")

-- Testing front projection
--tvoff, tuoff, txoff, tyoff = 0, 0, 0, 0
-- local grscreen = lg.newImage('gfx/lofi/greenscreen.png')
-- local triangle = lg.newMesh( {{0,0, 0,0},{scrn.w,0, 1,0},{scrn.w,scrn.h, 1,1},{0,scrn.h, 0,1}} , grscreen, strip )
-- --triangle:setWrap("repeat")

function ent:setPos (x, y )
  self.x = x
  self.y = y
  self.fixed_y = y
end

function ent:load( x, y )
	self.mesh = lg.newMesh( {{0,0, 0,0},{scrn.w,0, 1,0},{scrn.w,scrn.h, 1,1},{0,scrn.h, 0,1}} , grscreen, strip )
	self.mesh:setWrapMode("repeat")
  self:setPos( x, y )
  self.w = 48 * 4
  self.h = 48 * 4
  self.image = lg.newImage('gfx/lofi/greenscreen.png')
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
  self.y = self.fixed_y + math.sin(love.timer.getTime() * self.bouncespeed) * self.bounceheight
end

function ent:draw()
--  local x, y = self:getPos()
--  local w, h = self:getSize()
  love.graphics.draw( self.mesh, math.floor(self.x), math.floor(self.y), 0, 1, 1, 0, 0 )
end

return ent

