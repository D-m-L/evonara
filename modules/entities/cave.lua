local ent = {}

function ent:load( x, y, w, h, tilesize )
  self.tilesets = {}
  self.tilesets[1] = {
    image = lg.newImage('gfx/cave1.png'),
    name = "cave1",
    firstgid = 1,
    tilewidth = 24,
    tileheight = 24,
    spacing = 0,
    margin = 0,
    imagewidth = 128,
    imageheight = 64,
    tileoffset = { x = 0, y = 0 },
    properties = {},
    tiles = {
    { id = 1, properties = { ["kind"] = "empty" } },
    { id = 2, properties = { ["kind"] = "wall" } },
    { id = 3, properties = { ["kind"] = "westwall" } },
    { id = 4, properties = { ["kind"] = "floor" } },
    { id = 5, properties = { ["kind"] = "eastwall" } },
    { id = 6, properties = { ["kind"] = "waterfall" } },
    { id = 7, properties = { ["kind"] = "water" } },
    { id = 8, properties = { ["kind"] = "none" } },
    { id = 9, properties = { ["kind"] = "ceiling" } },
    { id = 10, properties = { ["kind"] = "none" } },
    { id = 11, properties = { ["kind"] = "none" } },
    }
  }
  self.tilesize = tilesize
  self.width = w
  self.height = h
  self.x = x
  self.y = y
  self.tiles = {}
  self.tileInstances = {}
  self.data = {}
	self.layers = {}
  -- Set tiles, images
  local gid = 1
  for i, tileset in ipairs(self.tilesets) do
    gid = self:setTiles(i, tileset, gid)
  end
  
  self.randomseed = 44
  self.dir = math.random(1,4)
  self.chance = math.random(1,1000)
  
  self.totaldrawn = 0
  self.miners = {}
  self.numminers = 1
  self.activeminers = 0
  self.nscoops = 0
  self.scooppcent = .25
  self.tscoops = math.floor(self.width * self.height * self.scooppcent)
  self.finished = false
  self.processed = false
  self.lowpoint = 1
  self.startx, self.starty = w/2 * tilesize + x, h/2 * tilesize + y
  self.collision = {}
  	self.drawRange = {
		sx = 1,
		sy = 1,
		ex = self.width,
		ey = self.height,
	}
  
  math.randomseed(self.randomseed)
  self:setPos( x, y)
  self:setSize ( w, h )

  
  for i=1, 100 do
    local x, y = math.random(1, self.width), math.random(1, self.height)
    self:createMiner(x, y)
  end
    
--  self.miners[self.numminers] = love.filesystem.load('entities/miner.lua')
--  self.miners[self.numminers]:init( self.width/2, self.height/2, 0, 0, 1 )
end

function ent:update(dt, player)
  if self.finished == false then
    if self.nscoops < self.tscoops then
      if self.miners then 
        for i = 1, #self.miners do
          self.miners[i]:dig(self)
        end
      end
    else
      for i = 1, #self.miners do
        self.miners[i].active = false
      end
      self.finished = true
      self.startx, self.starty = self:findStartLocation()
    end
  elseif self.processed == false then
    self:beautify()
--    	-- Set tiles, images
--    local gid = 1
--    for i, tileset in ipairs(self.tilesets) do
--      gid = self:setTiles(i, tileset, gid)
--    end
--    self:setTileData()
--		self:setSpriteBatches()
    self.processed = true
  end
end

function ent:draw(player, cam)
  if arastarted == true then
    local vtx, vty = math.ceil(16 / cam.zoom) + 8, math.ceil(9 / cam.zoom) + 5
    for y = maths.clamp(player.ty - vty, 1, self.height), maths.clamp(player.ty + vty, 1, self.height) do
      for x = maths.clamp(player.tx - vtx, 1, self.width), maths.clamp(player.tx + vtx, 1, self.width) do
        local m, n = x * self.tilesize + self.tilesize / 2 + self.x, y * self.tilesize + self.tilesize / 2 + self.y
        if self.data[y][x] == 1 then -- wall
          lg.setColor(79,30,11,255)
          lg.rectangle("fill", m, n, self.tilesize, self.tilesize)
        elseif self.data[y][x] == 2 then --westwall
          lg.setColor(66,73,14,255)
          lg.rectangle("fill", m, n, self.tilesize, self.tilesize)
          self.totaldrawn = self.totaldrawn + 1
        elseif self.data[y][x] == 3 then --floor
          lg.setColor(113,72,9,255)
          lg.rectangle("fill", m, n, self.tilesize, self.tilesize)
          self.totaldrawn = self.totaldrawn + 1
        elseif self.data[y][x] == 4 then --eastwall
          lg.setColor(127,22,8,255)
          lg.rectangle("fill", m, n, self.tilesize, self.tilesize)
          self.totaldrawn = self.totaldrawn + 1
        elseif self.data[y][x] == 5 then --waterfalls
          lg.setColor(50,170,255,75)
          lg.rectangle("fill", m, n, self.tilesize, self.tilesize)
          self.totaldrawn = self.totaldrawn + 1
        elseif self.data[y][x] == 6 then --pools
          lg.setColor(50,170,255,150)
          lg.rectangle("fill", m, n, self.tilesize, self.tilesize)
          self.totaldrawn = self.totaldrawn + 1
        elseif self.data[y][x] == 7 then -- nothing
          lg.setColor(150,80,255,255)
          lg.rectangle("fill", m, n, self.tilesize, self.tilesize)
          self.totaldrawn = self.totaldrawn + 1
        elseif self.data[y][x] == 8 then -- ceilings
          lg.setColor(55,20,39,255)
          lg.rectangle("fill", m, n, self.tilesize, self.tilesize)
          self.totaldrawn = self.totaldrawn + 1
        elseif self.data[y][x] == 9 then -- nothing
          lg.setColor(50,50,125,255)
          lg.rectangle("fill", m, n, self.tilesize, self.tilesize)
          self.totaldrawn = self.totaldrawn + 1
        elseif self.data[y][x] == 10 then -- nothing
          lg.setColor(100,40,120,255)
          lg.rectangle("fill", m, n, self.tilesize, self.tilesize)
          self.totaldrawn = self.totaldrawn + 1
        end
      end
    end
  end
  if self.processed == true then
--    self:drawTileBatches()
  end
end

function ent:drawTileBatches()
	local bw = self.batches.width
	local bh = self.batches.height
	local sx = math.ceil((self.drawRange.sx - self.x / self.tilesize	- 1) / bw)
	local sy = math.ceil((self.drawRange.sy - self.y / self.tilesize	- 1) / bh)
	local ex = math.ceil((self.drawRange.ex - self.x / self.tilesize	+ 1) / bw)
	local ey = math.ceil((self.drawRange.ey - self.y / self.tilesize	+ 1) / bh)
	local mx = math.ceil(self.width / bw)
	local my = math.ceil(self.height / bh)

	for by=sy, ey do
		for bx=sx, ex do
			if bx >= 1 and bx <= mx and by >= 1 and by <= my then
				for _, batches in pairs(self.batches.data) do
					local batch = batches[by] and batches[by][bx]

					if batch then
						lg.draw(batch, math.floor(self.x), math.floor(self.y))
					end
				end
			end
		end
	end
end

function ent:setTiles(index, tileset, gid)
	local function getTiles(i, t, m, s)
		i = i - m
		local n = 0

		while i >= t do
			i = i - t
			if n ~= 0 then i = i - s end
			if i >= 0 then n = n + 1 end
		end

		return n
	end

	local quad	= lg.newQuad
	local mw	= self.tilesize
	local iw	= tileset.imagewidth
	local ih	= tileset.imageheight
	local tw	= tileset.tilewidth
	local th	= tileset.tileheight
	local s		= tileset.spacing
	local m		= tileset.margin
	local w		= getTiles(iw, tw, m, s)
	local h		= getTiles(ih, th, m, s)

	for y = 1, h do
		for x = 1, w do
			local id = gid - tileset.firstgid
			local qx = (x - 1) * tw + m + (x - 1) * s
			local qy = (y - 1) * th + m + (y - 1) * s
			local properties
			local terrain
			local animation

			for _, tile in pairs(tileset.tiles) do
				if tile.id == id then
					properties = tile.properties
					animation = tile.animation
					if tile.terrain then
						terrain = {}
						for i=1,#tile.terrain do
							terrain[i] = tileset.terrains[tile.terrain[i] + 1]
						end
					end
				end
			end

			local tile = {
				id 			= id,
				gid			= gid,
				tileset		= index,
				quad		= quad(qx, qy, tw, th, iw, ih),
				properties	= properties,
				terrain     = terrain,
				animation   = animation,
				frame       = 1,
				time        = 0,
				width		= tileset.tilewidth,
				height		= tileset.tileheight,
				sx			= 1,
				sy			= 1,
				r			= 0,
				offset		= {
					x = -mw + tileset.tileoffset.x,
					y = -th + tileset.tileoffset.y,
				},
			}
			self.tiles[gid] = tile
			gid = gid + 1
		end
	end
	return gid
end

function ent:setTileData()
	local i = 1
	local map = {}

	for y = 1, self.height do
		map[y] = {}
		for x = 1, self.width do
--			local gid = layer.data[i]
			local gid = self.data[y][x]

			if gid > 0 then
				local tile = self.tiles[gid]

				if tile then
					map[y][x] = tile
				else
					local bit31		= 2147483648
					local bit30		= 1073741824
					local bit29		= 536870912
					local flipX		= false
					local flipY		= false
					local flipD		= false
					local realgid	= gid

					if realgid >= bit31 then realgid = realgid - bit31  flipX = not flipX end
					if realgid >= bit30 then realgid = realgid - bit30  flipY = not flipY end
					if realgid >= bit29 then realgid = realgid - bit29  flipD = not flipD end

					local tile = self.tiles[realgid]
					local data = {
						id			    = tile.id,
						gid			    = tile.gid,
						tileset		  = tile.tileset,
						offset		  = tile.offset,
						quad		    = tile.quad,
						properties	= tile.properties,
						terrain     = tile.terrain,
						animation   = tile.animation,
						sx			    = tile.sx,
						sy			    = tile.sy,
						r			      = tile.r,
					}

					if flipX then
						if flipY then
							data.sx = -1
							data.sy = -1
						elseif flipD then
							data.r = math.rad(90)
						else
							data.sx = -1
						end
					elseif flipY then
						if flipD then
							data.r = math.rad(-90)
						else
							data.sy = -1
						end
					elseif flipD then
						data.r = math.rad(90)
						data.sy = -1
					end

					self.tiles[gid] = data
					map[y][x] = self.tiles[gid]
				end
			else
				map[y][x] = false
			end

			i = i + 1
		end
	end

	self.data = map
end

function ent:setSpriteBatches()
	local newBatch	= lg.newSpriteBatch
	local w			= lw.getWidth()
	local h			= lw.getHeight()
	local tw		= self.tilesize
	local th		= self.tilesize
	local bw		= math.ceil(w / tw)
	local bh		= math.ceil(h / th)

	-- Minimum of 400 tiles per batch
	if bw < 20 then bw = 20 end
	if bh < 20 then bh = 20 end

	local size		= bw * bh
	local batches	= {
		width	= bw,
		height	= bh,
		data	= {},
	}

	for y = 1, self.height do
		local by = math.ceil(y / bh)
		for x = 1, self.width do
			local tile	= self.data[y][x]
			local bx	= math.ceil(x / bw)
			local id

			if tile then
				local ts = tile.tileset
				local image = self.tilesets[tile.tileset].image

				batches.data[ts] = batches.data[ts] or {}
				batches.data[ts][by] = batches.data[ts][by] or {}
				batches.data[ts][by][bx] = batches.data[ts][by][bx] or newBatch(image, size)

				local batch = batches.data[ts][by][bx]
				local tx, ty
        tx = x * tw + tw / 2
        ty = y * th + tw / 2

				id = batch:add(tile.quad, tx, ty)
				self.tileInstances[tile.gid] = self.tileInstances[tile.gid] or {}
				table.insert(self.tileInstances[tile.gid], { batch=batch, id=id, gid=tile.gid, x=tx, y=ty })
			end
		end
	end

	self.batches = batches
end

function ent:createMiner( x, y )
  self.x, self.y = x or self.width/2, y or self.height/2
  self.numminers = self.numminers + 1
  self.activeminers = self.activeminers + 1
  self.miners[#self.miners + 1] = ents.Create( "miner", x, y )
  self.miners[#self.miners]:setSize(1)
  self.miners[#self.miners]:setParent(self)
end

function ent:setPos( x, y )
  self.x, self.y = x, y
end

function ent:setScoopPercent(n)
  self.scooppcent = n
  self.tscoops = math.floor(self.width * self.height * self.scooppcent)
end

function ent:setSize( w, h )
  self.width, self.height = w, h
  for y = 1, self.height do
    self.data[y] = {}
    for x = 1, self.width do
      self.data[y][x] = 1
    end
  end
end

function ent:tileToScreen(x, y)
  return x * self.tilesize + self.tilesize/2 + self.x, y * self.tilesize + self.tilesize/2 + self.y
end

function ent:convertScreenToTile(x, y)
	local tw, th = self.tilewidth, self.tileheight

	local tx = x / tw
	local ty = y / th

	return tx, ty
end

function ent:findStartLocation()
  local x, y = self:findEmptyTile()
  x,y = self:getFloor(x,y)
  return self:tileToScreen(x, y)
end

function ent:getFloor(x,y)
  for y = y, self.height do
    local isFloor = self:isFloor(x,y)
    if isFloor == true then
      return x, y
    end
  end
end

function ent:findEmptyTile()
  local found = false
  local buffer = math.floor(self.height/2)
  local x, y = buffer, buffer
  while found == false do
    for y = buffer, self.height - buffer do
      for x = buffer, self.width - buffer do
        if self.data[y][x] == 0 then found = true x = x + 1 end
      end
      y = y + 1
    end
  end
  return x, y
end

function ent:findEmptySpot()
  local found = false
  local buffer = math.floor(self.height/2)
  local x, y = buffer, buffer
  while found == false do
    for y = buffer, self.height - buffer do
      for x = buffer, self.width - buffer do
        if self.data[y][x] == 0 then found = true x = x + 1 end
      end
      y = y + 1
    end
  end
  return x * self.tilesize + self.tilesize/2 + self.x, y * self.tilesize + self.tilesize/2 + self.y
end

function ent:beautify()
  self:cleanStrands()
  self:cleanSingles()
  self.collision = self:initWorldCollision(world)
  self:createPools( math.floor(self.height/6) )
  self:createFalls(8)
  self:findELedges()
  self:findWLedges()
  self:findEastWalls()
  self:findWestWalls()
  self:findCeilings()
  self:findFloors()
  self:findCorners()
  --self:trimColumns()
end

function ent:cleanSingles()
  for y = 2, self.height - 1 do
    for x = 2, self.width - 1 do
      if self.data[y][x] == 1 then
                    if self.data[y+1][x] == 0
       and self.data[y][x-1] == 0 and self.data[y][x+1] == 0
                   and self.data[y-1][x] == 0 then
         self.data[y][x] = 0
       end
     end
    end
  end
  self.cleanedsingles = true
end

function ent:cleanStrands()
   for y = 2, self.height - 1 do
    for x = 2, self.width - 1 do
      if self.data[y][x] == 1 then
        if self.data[y  ][x-1] == 0                            and self.data[y  ][x+1] == 0
       and self.data[y+1][x-1] == 0 and self.data[y+1][x] == 1 and self.data[y+1][x+1] == 0 then
         self.data[y][x] = 0
         self.data[y+1][x] = 0
       end
     end
   end
 end
end

function ent:cleanIslands()
   for y = 2, self.height - 1 do
    for x = 2, self.width - 1 do
      
    end
  end
end

function ent:createPools( height )
  local function clearPools()
    for y = 2, self.height - 1 do
      for x = 2, self.width - 1 do
        if self.data[y][x] == 2 then
          self.data[y][x] = 0
        end
      end
    end
  end
  
  local function findBottom()
    local bottom = 1
    for y = 2, self.height - 1 do
      for x = 2, self.width - 1 do
        if self.data[y][x] == 0 then
          bottom = y
        end
      end
    end
    return bottom
  end

  clearPools()
  self.lowpoint = findBottom()
  for y = self.lowpoint - height, self.lowpoint do
    for x = 2, self.width - 1 do
      if self.data[y][x] == 0 then
        self.data[y][x] = 6
      end
    end
  end
end

function ent:isSurrounded( x, y )
  if self.data[y+1][x] == 1 and self.data[y-1][x] == 1 and self.data[y][x+1] == 1 and self.data[y][x-1] == 1 then
    return true
  else
    return false
  end
end

--function ent:isEdgeTile( xx, yy)
--  local x, y = maths.clamp(xx, 1, self.width), maths.clamp(yy, 1, self.height)
--  if self.data[y+1][x] == 0 or self.data[y-1][x] == 0 or self.data[y][x+1] == 0 or self.data[y][x-1] == 0 then
--    return true
--  elseif self.data[y+1][x] == 2 or self.data[y-1][x] == 2 or self.data[y][x+1] == 2 or self.data[y][x-1] == 2 then
--    return true
--  elseif self.data[y+1][x] == 3 or self.data[y-1][x] == 3 or self.data[y][x+1] == 3 or self.data[y][x-1] == 3 then
--    return true
--  else
--    return false
--  end
--end

function ent:isCeiling( x, y )
  if self.data[y-1][x] == 1 then -- is this an overhang?
    return true
  else
    return false
  end
end

function ent:isFloor( x, y )
  if self.data[y+1][x] == 0 then -- is there empty space?
    return true
  else
    return false
  end
end

function ent:createFalls(num)
  local function newFall( x, y )
    self.data[y][x] = 5
    if self.data[y+1][x] == 0 then
      newFall ( x, y + 1 )
    elseif self.data[y+1][x] == 1 then
      if self.data[y][x+1] == 0 then
        --self.data[y][x+1] = 5
        newFall( x+1, y)
      end
      if self.data[y][x-1] == 0 then
        --self.data[y][x-1] = 5
        newFall( x-1, y)
      end
    end
  end
  
  local found = 0
  while found < num do
    local x, y = math.random(2, self.width - 1), math.random(2, self.height - 1)
    if self.data[y][x] == 0 then
      local _ = self:isCeiling( x, y )
      if self:isCeiling( x, y ) == true then found = found + 1  newFall(x, y) end
    end
  end
end

function ent:findELedges()
  for y = 2, self.height - 1 do
    for x = 2, self.width - 1 do
      if self.data[y][x] == 1 then
        if  self.data[y+1][x] == 0 and self.data[y+1][x+1] == 0
                                       and self.data[y  ][x+1] == 0
        and self.data[y-1][x] == 0 and self.data[y-1][x+1] == 0 then
          self.data[y][x] = 4
        end
      end
    end
  end
end

function ent:findWLedges()
  for y = 2, self.height - 1 do
    for x = 2, self.width - 1 do
      if self.data[y][x] == 1 then
        if  self.data[y+1][x-1] == 0 and self.data[y+1][x] == 0
        and self.data[y  ][x-1] == 0
        and self.data[y-1][x-1] == 0 and self.data[y-1][x] == 0 then
          self.data[y][x] = 2
        end
      end
    end
  end
end

function ent:findEastWalls()
  for y = 2, self.height - 1 do
    for x = 2, self.width - 1 do
      if self.data[y][x] == 1 then
        if  (self.data[y+1][x] == 1 or self.data[y+1][x] == 4) and self.data[y+1][x+1] == 0
                                                              and self.data[y  ][x+1] == 0
        and (self.data[y-1][x] == 1 or self.data[y-1][x] == 4) and self.data[y-1][x+1] == 0 then
          self.data[y][x] = 4
        end
      end
    end
  end
end

function ent:findWestWalls()
  for y = 2, self.height - 1 do
    for x = 2, self.width - 1 do
      if self.data[y][x] == 1 then
        if  self.data[y+1][x-1] == 0 and (self.data[y+1][x] == 1 or self.data[y+1][x] == 2)
        and self.data[y  ][x-1] == 0
        and self.data[y-1][x-1] == 0 and (self.data[y-1][x] == 1 or self.data[y-1][x] == 2) then
          self.data[y][x] = 2
        end
      end
    end
  end
end

function ent:findCeilings()
  for y = 2, self.height - 1 do
    for x = 2, self.width - 1 do
      if self.data[y][x] == 1 then
        if  (self.data[y  ][x-1] == 1 or self.data[y  ][x-1] == 8)                          and (self.data[y  ][x+1] == 1 or self.data[y  ][x+1] == 8)
        and  self.data[y+1][x-1] == 0                             and self.data[y+1][x] == 0 and  self.data[y+1][x+1] == 0 then
          self.data[y][x] = 8
        end
      end
    end
  end
end

function ent:findFloors()
  for y = 2, self.height - 1 do
    for x = 2, self.width - 1 do
      if self.data[y][x] == 1 then
        if  (self.data[y-1][x-1] == 0 or self.data[y-1][x-1] == 1)  and self.data[y-1][x] == 0 and (self.data[y-1][x+1] == 0 or self.data[y-1][x+1] == 1)
        and (self.data[y  ][x-1] == 1 or self.data[y  ][x-1] == 3)                                and (self.data[y  ][x+1] == 1 or self.data[y  ][x+1] == 3) then
          self.data[y][x] = 3
        end
      end
    end
  end
end

function ent:findCorners()
  
end

function ent:trimColumns()
  local count = 0
  for y = 1, self.height do
    for x = 1, self.width do
    --if self.data[y] then
      --if self.data[y][x] then
    if self.data[y][x] == 1 then count = count + 1 end
      --end
    --end
    --end
    if count == self.height then table.remove(self.data, y) self.width = self.width - 1 break end
    -- remove column, then decrement the width of the table--
    end
  end
end

function ent:setDrawRange(tx, ty, w, h)
	tx = -tx
	ty = -ty
	local tw, th = self.tilesize, self.tilesize
	local sx, sy, ex, ey

  sx = math.ceil(tx / tw)
  sy = math.ceil(ty / th)
  ex = math.ceil(sx + w / tw)
  ey = math.ceil(sy + h / th)

	self.drawRange = {
		sx = sx,
		sy = sy,
		ex = ex,
		ey = ey,
	}
end

function ent:initWorldCollision(world)
	local body = lp.newBody(world)
	local collision = {
		body = body,
	}
  
  local function addObjectToWorld(name, x, y)
		local shape
--    local v1, v2 = unpack(vertices)
    --v1, v2 = self:convertScreenToTile(v1, v2)
    
    if name == nil then name = "block" .. x .. "," .. y end
		shape = lp.newRectangleShape( (x * self.tilesize) + self.x + self.tilesize, (y * self.tilesize) + self.y + self.tilesize, self.tilesize, self.tilesize, 0 )

		local fixture = lp.newFixture(body, shape)
		local obj = {
			shape = shape,
			fixture = fixture,
      name = name,
      verts = verts,
		}
    fixture:setUserData(obj)

		table.insert(collision, obj)
	end

  
  for y = 2, self.height - 1 do
    for x = 2, self.width - 1 do
      local isSurrounded = self:isSurrounded(x, y)
      if self.data[y][x] == 1 and isSurrounded == false then
          addObjectToWorld(name, x, y)
        --end
      end
    end
  end       
  
	return collision
end

function ent:drawWorldCollision(collision, player, cam)
  for _, obj in ipairs(collision) do
    lg.polygon("line", collision.body:getWorldPoints(obj.shape:getPoints()))
  end
end

return ent