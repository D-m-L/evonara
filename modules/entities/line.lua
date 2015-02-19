local ent = ents.Derive("base")

function ent:load( x, y )
  self.x, self.y = x, y
  self.ex, self.ey = x, y
  self.thickness = 1
  self.capimg = love.graphics.newImage("gfx/fx/linecap.png")
  self.capw, self.caph = self.capimg:getWidth(), self.capimg:getHeight()
  self.lineimg = love.graphics.newImage("gfx/fx/line.png")
  self.lineh = self.lineimg:getHeight()
end

function ent:setThickness( w )
  self.thickness = w
end

function ent:setEndpoint( x, y )
  self.ex, self.ey = x, y
--  self.endp = {x, y}
end

function ent:update(dt)

end

function ent:draw(color)
    local tangentx, tangenty = self.ex - self.x, self.ey - self.y
    local tlength = math.distance( self.x, self.y, self.ex, self.ey)
    local rotation = math.atan2(tangenty, tangentx)
 
--    local imageThickness = 16;
    local thicknessScale = self.thickness / self.capw
 
    local capOrigin.x, capOrigin.y = self.capw, self.caph / 2
--    local middleOrigin.x, middleOrigin.y = 0, self.lineh / 2
--    local middleScale.x, middleScale.y = tlength, thicknessScale
 
--    spriteBatch.Draw(Art.LightningSegment, A, null, color, rotation, middleOrigin, middleScale, SpriteEffects.None, 0f);
--    spriteBatch.Draw(Art.HalfCircle, A, null, color, rotation, capOrigin, thicknessScale, SpriteEffects.None, 0f);
--    spriteBatch.Draw(Art.HalfCircle, B, null, color, rotation + MathHelper.Pi, capOrigin, thicknessScale, SpriteEffects.None, 0f);
    lg.draw(self.lineimg, self.x, self.y, rotation, tlength, thicknessScale, 0, self.lineh / 2)
    lg.draw(self.capimg, self.x, self.y, rotation, 1, thicknessScale, self.capw, self.caph / 2)
    lg.draw(self.capimg, self.ex, self.ey, rotation + math.pi, 1, thicknessScale, self.capw, self.caph / 2)
}
end

return ent

