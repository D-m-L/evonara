-- Let's play with some effects...
local iterator = 1
local dist = 15
local ratio = .9
local x1,y1 = 0, 0
local x2,y2 = scrn.w, 0 + dist

function drawWithRelStencil( image, stencil, scale, x, y, quad )
  local w, h = image:getDimensions()
  x, y = 0, 0
  scale = scale or 40

  love.graphics.push()
  love.graphics.setStencil( stencil )
  love.graphics.push()
  love.graphics.origin()
  love.graphics.draw( image, quad or util.screenquad, (x or 0)-w*scale, (y or 0)-h*scale, 0, scale, scale )
  love.graphics.pop()
  love.graphics.setStencil()
  love.graphics.pop()

  if x > w*scale then x = x - (w*scale) end
  if y > w*scale then y = y - (h*scale) end
  return x, y
end

function multvec2byscalar(vec, scalar)
  local a,b = unpack(vec)
  a = a * scalar
  b = b * scalar
  
  return {a,b}  
end

function getvectorlen(vec)
  local magx, magy = unpack(vec)
  c = magx^2 + magy^2
  
  return math.sqrt(c)
end

function subtractvectorfromvector(vec1, vec2)
  local a,b = unpack(vec1)
  local c,d = unpack(vec2)
  
  return {a - c, b - d}
  
end

function drawvector(origin, direction)
  local x1,y1 = unpack(origin)
  local a,b = unpack(direction)
    
  
  love.graphics.line( x1, y1, x2, y2)
end

function findlinevectorbypoints( x1, y1, x2, y2 )
--  a = getOriginVecA()
--  b = getDirVec()
  
  return
  
end

function updateLines()
  if iterator == 1 then
    x1 = x2
    y1 = y2
    x2 = x2 - dist
    y2 = scrn.h - y2
  
    iterator = iterator + 1
  end
--  if iterator == 2 then
--    x1 = x2
--    y1 = y2
--    x2 = scrn.w - x2
--    y2 = y2 - d
  
--    iterator = iterator + 1
--  end
--  if iterator == 3 then
--    x1 = x2
--    y1 = y2
--    x2 = x2 + d
--    y2 = y2 + y2
  
--    iterator = iterator + 1
--  end
--  if iterator == 4 then
--    x1 = x2
--    y1 = y2
--    x2 = x2 + x2
--    y2 = y2 + d
  
--    iterator = 1
--  end

end

function love.draw()
  love.graphics.setCanvas(canvas)
  
  love.graphics.line( x1, y1, x2, y2)
  updateLines()
  
  love.graphics.setCanvas()
  love.graphics.draw(canvas)
  
end

function love.keypressed(k)
	if ( k == "escape" ) then
		state.switch("mainmenu")
    collectgarbage()
	end
end