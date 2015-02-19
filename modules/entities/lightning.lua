local ent = {}

function ent:isComplete()
--    { get { return Alpha <= 0; } }
  return self.Alpha <= 0
end

function ent:load(x, y, ex, ey, thickness)
  self.dest = vector(ex, ey)
  self.source = vector(x, y)

  local Segments = {}

--  public float Alpha { get; set; }
--  public float FadeOutRate { get; set; }
--  public Color Tint { get; set; }

  
--  public LightningBolt(Vector2 source, Vector2 dest) : this(source, dest, new Color(0.9f, 0.8f, 1f)) { }

  local lightningBolt = {}
  lightningBolt.Segments = self:createBolt(source, dest, 2)
  lightningBolt.tint = { 255 * 0.9, 255 * 0.8, 255 * 1 }
  lightningBolt.alpha = 255 * 1
  lightningBolt.fadeOutRate = 0.03
  
  -- ...
end

function ent:createBolt( source, dest, thickness )
--    self.dest = vector(ex, ey)
--    self.source = vector(x, y)
  self.results = {}
  self.tangent = dest - source
  self.normal = self.tangent:perpendicular():normalize_inplace()
  self.length = self.tangent:len()
  self.sway = 80
  self.jaggedness = 1 / self.sway
  
  self.positions = self:buildPositions()

  local prevPoint = source
  local prevDisplacement = 0.0
  for i = 1, #self.positions do
    local pos = self.positions[i]
    -- used to prevent sharp angles by ensuring very close positions also have small perpendicular variation.
    local scale = (self.length * self.jaggedness) * (pos - (self.positions[i - 1] or 0))
    local envelope = pos > 0.95 and 20 * (1 - pos) or 1    -- keeps points near the ends close

    local displacement = math.random(-self.sway, self.sway)
    displacement = displacement - ((displacement - prevDisplacement) * (1 - scale))
    displacement = displacement * envelope

    point = source + pos * self.tangent + displacement * self.normal
--      local px, py = point:unpack()
--      local lx, ly = prevPoint:unpack()
    self.results[#self.results + 1] = ents.Create( "linesegment", point, prevPoint, thickness)
    prevPoint = point
    prevDisplacement = displacement
  end
--  results.Add(new Line(prevPoint, dest, thickness));
--    local xx, yy = prevPoint:unpack()
  self.results[#self.results + 1] = ents.Create( "linesegment", prevPoint, dest, thickness)
  return self.results
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
  self.dest = vector(x, y)
end

function ent:update(dt)
  self.alpha =  self.alpha - self.fadeOutRate
end

function ent:draw()
  if self.alpha <= 0 then return end
  for i = 1, #self.results do
    self.results[i]:drawSegment(self.tint * (self.alpha * 0.6))
  end
end

return ent