local ffi = require "ffi"

local nimble = {
  alias = {}
}

do
  local def = love.filesystem.read("libs/3d2/ffi_SDL203.h")
  ffi.cdef(def)
  local sdl
  if ffi.os == "Windows" then
    sdl = ffi.load("SDL2")
  else
    sdl = ffi.C
  end
  -- local sdl = ffi.load("SDL2")

  nimble.ffi = { sdl = sdl }
  local sdlLookup = function(t, n) 
    return function(t, n) return sdl['SDL_'..n] or nil end
  end
  
  nimble.alias.sdl = 
    setmetatable( { LoadBMP = 
      function(path) 
        return sdl["SDL_LoadBMP_RW"](sdl["SDL_RWFromFile"](path, "rb"), 1)
      end
    }, { __index = sdlLookup(t, n) } )  
end

-- do
--   local def = love.filesystem.read("ffi_GL.h")
--   ffi.cdef(def)
--   local gl = ffi.load("GL")

--   nimble.ffi = { gl = gl }
--   local glLookup = function(t, n) 
--     return function(t, n) return gl['GL_'..n] or nil end
--   end
  
--   nimble.alias.sdl = 
--     setmetatable( {
--     }, { __index = glLookup(t, n) } )  
-- end

return nimble.alias.sdl
