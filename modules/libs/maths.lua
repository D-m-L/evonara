maths = {}
isect = {}

function maths.distance(x1, y1, x2, y2, squared)
	local dx = x1 - x2
	local dy = y1 - y2
	local s = dx * dx + dy * dy
	--return squared and s or math.sqrt(s)
	--return s
  return math.sqrt(s)
end

function maths.angle(x1, y1, x2, y2)
	return math.atan2(y2 - y1, x2 - x1)
end

function maths.findAngle(x1, y1, x2, y2)
	return (math.atan2(y1 - y2, x2 - x1)) % twoPI
end

function maths.round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function maths.roundby(x, increment)
  if increment then return maths.roundby(x / increment) * increment end
  return x > 0 and math.floor(x + .5) or math.ceil(x - .5)
end

function maths.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end

-- function maths.clamp(input, lo, hi)
	-- if input < lo then
		-- input = lo
	-- elseif input > hi then
		-- input = hi
	-- end
	-- return input
-- end

function maths.softclamp(input, lo, hi, strength, dt)
    if input > hi then
        return input - dt * strength
    elseif input < lo then
        return input + dt * strength
    end
    return input
end

function maths.wrap(input, lo, hi)
    if input > hi then
        input = input - (hi - lo)
    elseif input < lo then
        input = input + (hi - lo)
    end
	return input
end

--function maths.checkCollision(ax1,ay1,aw,ah, bx1,by1,bw,bh)
--  local ax2,ay2,bx2,by2 = ax1 + aw, ay1 + ah, bx1 + bw, by1 + bh
--  return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
--end

function maths.sign(input)
--Turns any number into it's sign
    if input > 0 then return 1 else return -1 end
end

function maths.bolsig(bol)
--Turns a boolean into a sign
    if bol then return 1 else return -1 end
end

function maths.randPairsTable( numItems, xExtent, yExtent )
  local t = {}
  for i=1, numItems, 1 do
    local xval = math.random(0, xExtent)
    local yval = math.random(0, xExtent)
    table.insert( t, {xval, yval } )
  end
  return t
end

function maths.randXYZtable( numItems, xExtent, yExtent )
  local t = {}
  for i=1, numItems, 1 do
    local xval = math.random(-xExtent/2, xExtent/2)
    local yval = math.random(-yExtent/2, yExtent/2)
    local zval = math.random(-1, 4)
    table.insert( t, {xval, yval, zval } )
  end
  return t
end

function maths.createScatter( x, y, w, h, rows, cols)
local xd, yd = w / cols, h / rows
  for ix = 1, ix < cols do
    for iy = 1, iy < rows do
      local p = 0.4
      --CreatePoint( Vector2(x+xd*ix+rndf(-p,p)*xd,y+yd*iy+rndf(-p,p)*yd));
      return 
    end
  end
end

function maths.increment ( num, val )
  num = num + val
  return num
end

function isect.SegmentCircleIntersect(a, b, c)
  local ac2 = (c.x - a.x)^2 + (c.y - a.y)^2
  local cr2 = c.r * c.r
  if ac2 <= cr2 then
    return a
  end
   
  local bc2 = (c.x - b.x)^2 + (c.y - b.y)^2
  if bc2 <= cr2 then
  return b
end
 
local abx = b.x-a.x
  local aby = b.y-a.y
  local e = {x = c.x - aby, y = c.y + abx}
  local f = {x = c.x + aby, y = c.y - abx}
  local point = SegmentLineIntersect(a, b, e, f)
  if point and (point.x - c.x)^2 + (point.y - c.y)^2 <= cr2 then
    return point
  end
end
 
function isect.LineCircleIntersect(a, b, c)
  local abx = b.x-a.x
  local aby = b.y-a.y
  local e = {x = c.x - aby, y = c.y + abx}
  local f = {x = c.x + aby, y = c.y - abx}
  local point = LineLineIntersect(a, b, e, f)
  if point and (point.x - c.x)^2 + (point.y - c.y)^2 <= c.r^2 then
    return point
  end
end
 
function isect.LineLineIntersect(p, p2, q, q2)
  local rx,ry = p2.x-p.x, p2.y-p.y
  local sx,sy = q2.x-q.x, q2.y-q.y
  local qmpx,qmpy = q.x -p.x, q.y -p.y
  local rxs = rx*sy - ry*sx
  local qmpxs = qmpx*sy - qmpy*sx
  if rxs == 0 then
  if qmpxs == 0 then
  -- then the lines are equal!
  return p
  end
  else
  -- then the lines intersect at exactly one point
  local t = qmpxs / rxs
  return {x=p.x+t*rx, y=p.y+t*ry}
  end
end
 
function isect.SegmentLineIntersect(p, p2, q, q2)
  local rx,ry = p2.x-p.x, p2.y-p.y
  local sx,sy = q2.x-q.x, q2.y-q.y
  local qmpx,qmpy = q.x -p.x, q.y -p.y
  local rxs = rx*sy - ry*sx
  local qmpxs = qmpx*sy - qmpy*sx
  if rxs == 0 then
  if qmpxs == 0 then
  -- then the segment is collinear with the line!
  return p
  end
  else
  -- then the segments is not collinear or parallel with the line
  local t = qmpxs / rxs
  if 0 <= t and t <= 1 then
  return {x=p.x+t*rx, y=p.y+t*ry}
  end
  end
end
 
function isect.SegmentSegmentIntersect(p, p2, q, q2)
  local rx,ry = p2.x-p.x, p2.y-p.y
  local sx,sy = q2.x-q.x, q2.y-q.y
  local qmpx,qmpy = q.x -p.x, q.y -p.y
  local rxs = rx*sy - ry*sx
  local qmpxs = qmpx*sy - qmpy*sx
  if rxs == 0 then
  if qmpxs == 0 then
  -- then the segments are collinear!
  -- do something dumb!
  local which = "x"
  -- this fails in some cases where p has length 0
  -- segments should have positive length, please
  if p.x == p2.x then which = "y" end
  if p[which] > p2[which] then p,p2 = p2,p end
  if q[which] > q2[which] then q,q2 = q2,q end
  if p[which] > q[which] then p,p2,q,q2 = q,q2,p,p2 end
  if p[which] <= q[which] and q[which] <= p2[which] then
  return q
  end
  end
  else
  -- then the segments are not collinear or parallel
  local qmpxr = qmpx*ry - qmpy*rx
  local t = qmpxs / rxs
  local u = qmpxr / rxs
  if 0 <= t and t <= 1 and 0 <= u and u <= 1 then
  return {x=p.x+t*rx, y=p.y+t*ry}
  end
  end
end
 
function isect.CircleCircleIntersect(a, b)
  local abx = b.x-a.x
  local aby = b.y-a.y
  local dist2 = abx^2 + aby^2
  local tr = a.r + b.r
  if dist2 <= tr^2 then
  local scale = a.r/tr
  return {x=a.x+scale*abx, y=a.y+scale*aby}
  end
end