function drawMode7orig(x, y, tex, ox, oy, r, s, w, h)
  for i = 1, h, 1 do
    love.graphics.setScissor(0, i, w, 1)
    love.graphics.draw(tex, w/2 + ox , h/2 + oy, r, i * s, i * s, x, y)
  end
  love.graphics.setScissor()
end

function drawMode7tile(map, layer, x, y, ox, oy, r, s, w, h)
  local bw = layer.batches.width
	local bh = layer.batches.height
--  local sx = 1
--	local sy = 1
	local ex = math.ceil((map.drawRange.ex - layer.x / map.tilewidth	+ 1) / bw)
	local ey = math.ceil((map.drawRange.ey - layer.y / map.tileheight	+ 1) / bh)
  for i = 1, h, 1 do
    love.graphics.setScissor(0, i + pitch, w, 1)
    for by=1, ey do
      for bx=1, ex do
        for _, batches in pairs(layer.batches.data) do
          local batch = batches[by] and batches[by][bx]
--        for y = 1, #layer.batches[y] do
          lg.draw(batch, w/2 + ox , h/2 + oy, r, i * s, i * s, x, y)
        end
      end
    end
  end
  love.graphics.setScissor()
end

function drawMode7floor(x, y, tex, ox, oy, r, s, w, h)
  for i = h/2, h, 1 do
    love.graphics.setScissor(0, i + pitch, w, 1)
    love.graphics.draw(tex, w/2 + ox * x, h/2 + oy, 0, i * s * 8, i * s, x + i, y)
  end
  love.graphics.setScissor()
end

function rasterScroll(x, y, tex, ox, oy, r, s, w, h)
    for i = 1, h, 1 do
      love.graphics.setScissor(0, i, w, 1)
      love.graphics.draw(tex, w/2 + ox , h/2 + oy, r, s, s, -x * i / 100, y)
    end
    love.graphics.setScissor()
end

-- function rasterScroll(x, y, tex, offset, height, width, sliceSize, scale)
	-- local slices = math.ceil(height / sliceSize)
    -- for i = y, height, slices do
        -- love.graphics.setScissor(x + i * offset, y + i * sliceSize, width, i * sliceSize)
        -- love.graphics.draw(tex, w/2 + ox, h/2 + oy, 0, scale, scale, x, y)
    -- end
    -- love.graphics.setScissor()
-- end

function rasterScrollh(x, y, tex, offset, scale)
	love.graphics.draw(tex, x, y, 0, scale, scale, offset, 0)
end

function drawMode7floorEx(x, y, tex, ox, oy, r, s, w, h)
    for i = h/2, h, 1 do
        love.graphics.setScissor(0, i + pitch, w, 1)
        love.graphics.draw(tex, w/2 + ox, h/2 + oy, 0, i ^ 1.33 * s , i * s, x + i * something, y)
    end
    love.graphics.setScissor()
end

function drawMode7(x, y, tex, ox, oy, r, s, w, h)
    for i = 1, ssplit1, 1 do
        love.graphics.setScissor(0, i + pitch, w, 1)
        love.graphics.draw(tex, w/2 + ox, h/2 + oy, maths.round(r, 2), maths.round(i * s, 2), maths.round(i * s, 2), x, y)
    end
    love.graphics.setScissor()
end

--player.x, player.y, track texture, offset x, offset y (FOV, basically), player.rotation, scale... height sort of,
--  screen.w, screen.h

function drawMode7_2(x, y, tex, ox, oy, r, s, w, h)
    for i = ssplit1, ssplit2 , 2 do
        love.graphics.setScissor(0, i + pitch, w, 2)
		--drawable, x pos, y pos, orientation, x scale, y scale, origin offset x, origin offset y, shear x, shear y
        love.graphics.draw(tex, w/2 + ox, h/2 + oy, maths.round(r, 2), maths.round(i * s, 2), maths.round(i * s, 2), x, y)
    end
    love.graphics.setScissor()
end

function drawMode7_4(x, y, tex, ox, oy, r, s, w, h)
    for i =  ssplit2, ssplit3, 4 do
        love.graphics.setScissor(0, i + pitch, w, 4)
        love.graphics.draw(tex, w/2 + ox, h/2 + oy, maths.round(r, 2), maths.round(i * s, 2), maths.round(i * s, 2), x, y)
    end
    love.graphics.setScissor()
end

function drawMode7_6(x, y, tex, ox, oy, r, s, w, h)
    for i = ssplit3, ssplit4, 6 do
        love.graphics.setScissor(0, i + pitch, w, 6)
        love.graphics.draw(tex, w/2 + ox, h/2 + oy, maths.round(r, 2), maths.round(i * s, 2), maths.round(i * s, 2), x, y)
    end
    love.graphics.setScissor()
end

function drawMode7_8(x, y, tex, ox, oy, r, s, w, h)
    for i = ssplit4, h, 8 do
        love.graphics.setScissor(0, i + pitch, w, 8)
        love.graphics.draw(tex, w/2 + ox, h/2 + oy, maths.round(r, 2), maths.round(i * s, 2), maths.round(i * s, 2), x, y)
    end
    love.graphics.setScissor()
end

function drawMode7x(x, y, tex, ox, oy, r, s, w, h)
    for i = 1 + love.graphics.getHeight() / 2,h,1 do
        love.graphics.setScissor(0, i, w, 1)
        love.graphics.draw(tex, w/2 + ox, h/2 + oy, r, maths.round(i * s, 2), maths.round(i * s, 2), x , y)
    end
    love.graphics.setScissor()
end