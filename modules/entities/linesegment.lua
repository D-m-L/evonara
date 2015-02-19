local ent = {}

function ent:load( source, dest, thickness )
  local atan2 = math.atan2
--  self.x, self.y = x, y
--  self.source = vector(x, y)
  self.source = source
--  self.dest = vector(w, h)
  self.dest = dest
--  self.ex, self.ey = w, h
  self.thickness = thickness or 1
  self.capimg = love.graphics.newImage("gfx/fx/linecap.png")
  self.capw, self.caph = self.capimg:getWidth(), self.capimg:getHeight()
  self.lineimg = love.graphics.newImage("gfx/fx/line.png")
  self.lineh = self.lineimg:getHeight()
  self.tangent = self.dest - self.source
  self.length = self.tangent:len()
  local tx, ty = self.tangent:unpack()
--  tx, ty = math.cos(tx), math.sin(ty)
--  local theta = ty/tx
--  local c, s = math.cos(theta), math.sin(theta)
  self.rotation = atan2(ty, tx)
  --    local imageThickness = 16;
  self.thicknessScale = self.thickness / self.capw
end

function ent:drawSegment(color)
  local sx, sy = self.source:unpack()
  local ex, ey = self.dest:unpack()
  lg.setBlendMode("additive")
  lg.draw(self.lineimg, sx, sy, self.rotation, self.length, self.thicknessScale, 0, self.lineh / 2)
  lg.draw(self.capimg, sx, sy, self.rotation, self.thicknessScale / 2, self.thicknessScale, self.capw, self.caph / 2)
  lg.draw(self.capimg, ex, ey, self.rotation + math.pi, self.thicknessScale / 2, self.thicknessScale, self.capw, self.caph / 2)
  lg.setBlendMode("alpha")
end

return ent

