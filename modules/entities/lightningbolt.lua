local ent = {}



function ent:load( x, y, ex, ey, thickness )
  self.dest = vector(ex, ey)
  self.source = vector(x, y)
  self.results = {}
  self.tangent = self.dest - self.source
  self.normal = self.tangent:perpendicular():normalize_inplace()
  self.length = self.tangent:len()
  self.sway = 80
  self.jaggedness = 1 / self.sway
  
  self.positions = self:buildPositions()

  local prevPoint = self.source
  local prevDisplacement = 0.0
  for i = 1, #self.positions do
    local pos = self.positions[i]
    -- used to prevent sharp angles by ensuring very close positions also have small perpendicular variation.
    local scale = (self.length * self.jaggedness) * (pos - (self.positions[i - 1] or 0))
    local envelope = pos > 0.95 and 20 * (1 - pos) or 1    -- keeps points near the ends close

    local displacement = math.random(-self.sway, self.sway)
    displacement = displacement - ((displacement - prevDisplacement) * (1 - scale))
    displacement = displacement * envelope

    point = self.source + pos * self.tangent + displacement * self.normal
    local px, py = point:unpack()
    local lx, ly = prevPoint:unpack()
    self.results[#self.results + 1] = ents.Create( "linesegment", px, py, lx, ly, thickness)
    prevPoint = point
    prevDisplacement = displacement
  end
--  results.Add(new Line(prevPoint, dest, thickness));
  local xx, yy = prevPoint:unpack()
  self.results[#self.results + 1] = ents.Create( "linesegment", xx, yy, ex, ey, thickness)
end

function ent:buildPositions()
  local positions = {}
  positions[1] = 0
--  for i = 2, self.length / 8 do
  for i = 2, 12 do
--    if not self.positions[math.ceil(self.length / 4)] then
      positions[i] = math.random(1, 100)/100
--    end
  end
  table.sort(positions)
  return positions
end

function ent:setPos(x, y)
  self.source = vector(x,y)
end

function ent:setDest(x, y)
--  self.y = self.fixed_y + math.sin(love.timer.getTime() * self.bouncespeed) * self.bounceheight


  self.dest = vector(x, y)
end

function ent:update(dt)
--  self:load()
--  self.positions = self:buildPositions()
end

function ent:draw()
  for i = 1, #self.results do
    self.results[i]:drawSegment()
  end
end

return ent