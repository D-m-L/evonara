local ent = {}

function ent:load( x, y, w, h, size )
  self.chance = 0
  self.x, self.y = x or 0, y or 0
  self.active = true
  --math.randomseed(love.timer.getTime())
	--self.dir = math.random(1,8)
  --self.dir = math.random(2946) % 4
  self.size, self.tilesize = size or 1, size or 2
  self.parent = nil
end

function ent:setParent( parent )
  self.parent = parent
end

function ent:dig(parent)
  -- cave = self.parent
	local cave = parent
  if self.active == true then
    self.parent.chance = math.random(1000)
    self.parent.dir = math.random(1,4)
    
    self.x, self.y = maths.clamp(self.x, 2, cave.width - 1),  maths.clamp(self.y, 2, cave.height - 1)
    
    -- delete square of size n
    local n = self.size
    if cave.data[self.y][self.x] == 1 then
      self.x = maths.clamp(self.x, 1 + n, cave.width - n)
      self.y = maths.clamp(self.y, 1 + n, cave.height - n)
      --cave.data[self.y][self.x] = 0 cave.nscoops = cave.nscoops + 1
    
      for y = 1, n do
        for x = 1, n do
          cave.data[math.floor(self.y + y - n/2)][math.floor(self.x + x - n/2)] = 0  cave.nscoops = cave.nscoops + 1
        end
      end
    end
    
    if self.parent.dir == 1 and cave.data[self.y-self.size][self.x] == 1 then self.y = self.y - self.size 
    elseif self.parent.dir == 2 and cave.data[self.y][self.x+self.size] == 1 then self.x = self.x + self.size
    elseif self.parent.dir == 3 and cave.data[self.y+self.size][self.x] == 1 then  self.y = self.y + self.size
    elseif self.parent.dir == 4 and cave.data[self.y][self.x-self.size] == 1 then  self.x = self.x - self.size
    end
    self.x, self.y = maths.clamp(self.x, 2, cave.width - 1),  maths.clamp(self.y, 2, cave.height - 1)

    -- If we have less than X many miners, there is a chance a new miner will be born
    if cave.activeminers < 1000 then
      if self.parent.chance <= 50 then
        local randx, randy = math.random(-self.size,self.size), math.random(-self.size,self.size)
        local newx, newy = maths.clamp(self.x + randx, 2, cave.width - 1), maths.clamp(self.y + randy, 2, cave.height - 1)
--        cave.numminers = cave.numminers + 1
--        cave.miners[cave.numminers]:init(newx, newy, 0, 0, 1)
        cave:createMiner(newx, newy)
      end
    end
    
    if cave.data[self.y+1][self.x] == 0 and cave.data[self.y-1][self.x] == 0 and cave.data[self.y][self.x+1] == 0 and cave.data[self.y][self.x-1] == 0 then
      -- IF THERE'S NOTHING NEARBY
      if cave.activeminers == 1 then  -- IF WE'RE THE LAST MINER
        local n = 1
        local randx, randy = love.math.random(-self.size,self.size), love.math.random(-n,n)
        self.x, self.y = maths.clamp(self.x + randx, 1+n, cave.width - n), maths.clamp(self.y + randy, 1 + n, cave.height - n)
      else
        self:deactivate()
      end
    end
    if cave.activeminers > 1 then
      if self.y == 2 then
        self:deactivate()
      elseif self.y == cave.height - 1 then
        self:deactivate()
      elseif self.x == 2 then
        self:deactivate()
      elseif self.x == cave.width - 1 then
        self:deactivate()
      end
    end
  end
end

function ent:deactivate()
  self.active = false
  self.parent.activeminers = self.parent.activeminers - 1
end

function ent:setPos( x, y )
  self.x = x
  self.y = y
end

function ent:setSize( size )
  self.size = size
end

function ent:draw()
  if self.active == true then
    lg.setColor(255,0,0,255)
    lg.setLineWidth(1)
    love.graphics.rectangle("line", self.x * self.parent.tilesize, self.y * self.parent.tilesize, self.size * self.parent.tilesize, self.size * self.parent.tilesize)
  end
end

return ent