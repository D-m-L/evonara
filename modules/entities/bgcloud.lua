local ent = ents.Derive("base")

function ent:load( x, y )
  self.x = x
  self.y = y
  self.z = math.random(-1, 4)
  if self.z == 0 then self.z = 1 end
  self.img = love.graphics.newImage("gfx/skies/clound.png")
  self.imgw = self.img:getWidth()
  self.size = math.random (4, 60)
  self.name = ""
end

function ent:update(dt)
  local px, py
--  self.y = self.y
  if player then px, py = -player.x/ 8 else px, py = 0,0 end
  if forces.wind then self.x = self.x + forces.wind * self.z * dt
  else self.x = self.x + (self.size * 9) * self.z * dt end
  self.y = (self.y + scrn.h/8 + py * cam.zoom * self.z / 4 ) * dt
  
--  if math.abs(self.x) >= scrn.w + self.size then
  if math.abs(self.x) >= 1000 then
--      self.x, self.y, self.z = -self.size * self.imgw, math.random(1 - self.size, scrn.h), math.random(-1, 4)
      self.x = -500
  end
end

function ent:Die()
  --return ents.Create( "bgcloud", -math.random( 128, 256), 128 )
end

function ent:skydraw()
  love.graphics.draw( self.img, math.floor(self.x), math.floor(self.y), 0, self.size/20, self.size/20, 0, 0 )
end

return ent

--  local px
  --From here we actually draw the clounds.  Step through the pairs, unpack the values, and do magic numbers
--  if player then px = -player.x/ 8 else px = 0 end
--  for i,v in pairs(self.ct) do
--    local x, y, z = unpack(v)
--    if wind > 500 then wind = -500 end
--    self.ct[i].x = x + px * z + wind * z
--    lg.draw(self.cloud, math.floor(self.ct[i].x) , math.floor(y + scrn.h/8 * cam.zoom * z / 4),
--      0, 1 / cam.zoom * cam.zoom / 2 * math.abs(z) * math.abs(z), 1 / cam.zoom * cam.zoom / 2 * math.abs(z) * math.abs(z))
--  end

