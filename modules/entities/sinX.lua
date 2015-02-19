local ent = ents.Derive("base")

function ent:setPos (x, y )
  self.x = x
  self.y = y
  self.fixed_y = y
end

function ent:load( x, y )
  self:setPos( x, y )
  self.w = 48
  self.h = 48
  --self.image = love.graphics.newImage(gfx/ents/zepp.png")
  self.birth = love.timer.getTime() + math.random( 0, 128)
  self.size = math.random (4, 6)
end

function ent:setSize( w, h )
  self.w = w
  self.h = h
end

function ent:getSize()
  return self.w, self.h
end

function ent:update(dt)
  self.y = self.y + 32*dt
end

function ent:draw()
  local x, y = self:getPos()
  local w, h = self:getSize()
  
  love.graphics.setColor( 255, 255, 255, 255)
  love.graphics.rectangle("fill", x, y, w, h )
end

return ent

