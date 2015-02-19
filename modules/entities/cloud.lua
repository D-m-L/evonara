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
  self.image = love.graphics.newImage("gfx/skies/clound.png")
  self.birth = love.timer.getTime() + math.random( 0, 128)
  self.size = math.random (4, 60)
end

function ent:setSize( w, h )
  self.w = w
  self.h = h
end

function ent:getSize()
  return self.w, self.h
end

function ent:update(dt)
  self.y = self.fixed_y + math.sin(love.timer.getTime() - self.birth) * (self.size* 3 )
  self.x = self.x + (self.size * 9) * dt
  
  if (self.x >= scrn.w + self.size) then
      ents.Destroy( self.id )
  end
  
end

function ent:Die()
  ents.Create ( "cloud", -math.random( 128, 256), 128 )
end

function ent:draw()  
  --love.graphics.setColor( 255, 255, 255, 255)
  love.graphics.draw( self.image, math.floor(self.x), math.floor(self.y), 0, self.size/20, self.size/20, 0, 0 )
end

return ent

