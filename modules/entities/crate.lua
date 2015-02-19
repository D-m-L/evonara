local ent = ents.Derive("base")

function ent:load( x, y )
  self:setPos( x, y )
  self.w = 48
  self.h = 48
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
  
  local prev = love.graphics.getColor()
  
  love.graphics.setColor( 255, 255, 255, 255)
  love.graphics.rectangle("fill", x, y, w, h )
  love.graphics.setColor( prev)
end

return ent

