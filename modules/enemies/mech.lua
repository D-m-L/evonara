local ent = ents.Derive("base")

function ent:setPos (x, y )
  self.x = x
  self.y = y
end

function ent:load( name, x, y, size, facing, health, r )
  self.size = size or 500
  self.spr = Spriter:loadSpriter( "gfx/enem/mech/", "mech" )
  self.barm = Spriter:loadSpriter( "gfx/enem/mech/", "barm" )
  mechAnims = self.spr:getAnimationNames()
  armAnims = self.spr:getAnimationNames()
--Set the first animation found as the active animation
  self.spr:setCurrentAnimationName( mechAnims[1] )
  self.barm:setCurrentAnimationName( armAnims[1] )
  self.spr:setOffset(0,self.size)
  self.barm:setOffset(0,self.size)
  self:setPos( x, y )
end

function ent:setSize( w, h )
  self.w = w
  self.h = h
end

function ent:getSize()
  return self.w, self.h
end

function ent:update(dt)
  self.spr:update( dt )
  self.barm:update( dt )
end

function ent:draw()
    lg.setColor(100,100,100,255)
    self.barm:draw( self.x, self.y )
    lg.setColor(white)
    self.spr:draw( self.x, self.y )
end

return ent

