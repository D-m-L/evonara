local base = {}

base.x = 0
base.y = 0
base.health = 100

function base:setPos( x, y )
  base.x = x
  base.y = y
end

function base:getPos()
  return base.x, base.y
end

function base:load()
end

function base:drawCollisions()
	lg.setColor(green)
	lg.polygon("line", self.body:getWorldPoints(self.originSh:getPoints()))
end

function base:getDistanceTo(target)
  local tx, ty = 0, 0
--  if s.body then
--    x1, y1 = s.body:getPosition()
--  else x1, y1 = 0, 0 end
--  if target.body then tx, ty = target.body:getPosition() end
--  else x2, y2 = 0, 0 end
  
  return maths.distance(self.x, self.y, target.x, target.y)
end

return base