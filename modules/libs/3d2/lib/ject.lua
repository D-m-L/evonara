--[[
Copyright (c) 2014-2015 Nicholas Adam Carlson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

require 'libs/3d2/lib.fun'()

local vec4 = require 'libs/3d2/lib.math.vec4'

local love = {}
local parser_router



function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

local get_path = function(path, sep)
  sep = sep or'/'
  return path:match("(.*"..sep..")")
end

local basename = function(path)
  local dir, file, ext = string.match(path, "(.-)([^\\/]-%.?([^%.\\/]*))$")
  return file
end

local function check(v, ...)
  if v then return v end
  local msg = ... and string.format(...)..'\n' or ''
  error(string.format('error reading file "%s", line %d, "%s"\n%s%s', file, line, line_str, msg, debug.traceback()), 2)
end


local function trim(s)
  return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end

local function get_lines(path)
  local f = assert(io.open(path, "r"))
  local arr = {}
  for line in f:lines() do
    trimmed_line = trim(line)
    if length(trimmed_line) > 0 and head(trimmed_line) ~= "#" then
      table.insert(arr, trimmed_line)
    end
  end
  f:close()
  return arr
end








local face_reference_prototype = {}
face_reference_prototype.__index = face_reference_prototype

local function new_face_ref(v, vt, vn)
  local o = {
    v = v;
    vt = vt;
    vn = vn;
  }
  setmetatable(o, face_reference_prototype)
  return o
end

local function is_face_ref(o)
  return getmetatable(o) == face_reference_prototype
end

function face_reference_prototype:to_string ()
  return "<"..tostring(self.v or "").."/"..tostring(self.vt or "").."/"..tostring(self.vn or "")..">"
end




local face_prototype = {}
face_prototype.__index = face_prototype

local function new_face(references)
  local o = {
    references = references or {};
  }
  setmetatable(o, face_prototype)
  return o
end

local function is_face(o)
  return getmetatable(o) == face_prototype
end

function face_prototype:to_string ()
  local output = "<" .. head(self.references):to_string()
  for _itr, r in tail(self.references) do
    assert(is_face_ref(r), "face contains references that are not of type <face_reference_prototype>")
    output = output .. ", " .. r:to_string()
  end
  output = output .. ">"
  return output
end


local ast_prototype = {}
ast_prototype.__index = ast_prototype

local function new_ast(obj_file)
  local o = {
    v = {};
    f = {};
    vn = {};
    vt = {};
    material_libs = {};
    path = get_path(obj_file);
    obj_file = obj_file;
  }
  setmetatable(o, ast_prototype)
  return o
end

local function is_ast(o)
  return getmetatable(o) == ast_prototype
end

function ast_prototype:build(lines)
  for _itr, line in iter(lines) do
    local cmd, args = line:match'^%s*(%S+) *(.*)'
    cmd = cmd and cmd:lower()
    -- is 'self = foo' dangerous. Perhaps it'd be better to clone members one-by-one
    self = parser_router[cmd](cmd, args, self)
  end
end

function ast_prototype:to_string ()
  local output = "<\n"
  output = output .. "v:\n"
  for _itr, v in iter(self.v) do
    output = output .. "\t" .. tostring(v) .. "\n"
  end
  output = output .. "f:\n"
  for _itr, f in iter(self.f) do
    assert(is_face(f), "f is not a face!!" .. tostring(type(f)))
    output = output .. "\t" .. f:to_string() .. "\n"
  end
  output = output .. ">"
  return output
end




local cmd_UNSUPPORTED = function (cmd, args, ast)
  -- error("command "..cmd.." is unsupported")
  return ast
end

local cmd_g = function (cmd, args, ast)
  return ast
end

local cmd_v = function (cmd, args, ast)
  local x,y,z,w = args:match'^(%S*) *(%S*) *(%S*) *(%S*)'
  w = tonumber(w) or 1.0
  x,y,z,w = check(tonumber(x)), check(tonumber(y)), check(tonumber(z)), check(tonumber(w))
  -- handlers.vertex(x,y,z,w)
  table.insert(ast.v, vec4(x, y, z, w))
  return ast
end

local cmd_vn = function (cmd, args, ast)
  local x,y,z,w = args:match'^(%S*) *(%S*) *(%S*) *(%S*)'
  w = tonumber(w) or 1.0
  x,y,z,w = check(tonumber(x)), check(tonumber(y)), check(tonumber(z)), check(tonumber(w))
  -- handlers.vertex(x,y,z,w)
  table.insert(ast.vn, vec4(x, y, z, w))
  return ast
end

local cmd_vt = function (cmd, args, ast)
  local x,y,z,w = args:match'^(%S*) *(%S*) *(%S*) *(%S*)'
  z = tonumber(z) or 0.0
  w = tonumber(w) or 1.0
  x,y,z,w = check(tonumber(x)), check(tonumber(y)), check(tonumber(z)), check(tonumber(w))
  -- handlers.vertex(x,y,z,w)
  table.insert(ast.vt, vec4(x, y, z, w))
  return ast
end

local cmd_f = function (cmd, args, ast)
  local f = new_face()
  for c in args:gmatch'(%S+)' do
    local v,vt,vn = c:match'^([^/]+)/?([^/]*)/?([^/]*)'
    v = check(tonumber(v))
    vt = vt ~= '' and check(tonumber(vt)) or nil
    vn = vn ~= '' and check(tonumber(vn)) or nil
    -- handlers.face_vtn(v,vt,vn)
    local face_ref = new_face_ref(v, vt, vn);
    table.insert(f.references, face_ref)
  end
  table.insert(ast.f, f)
  return ast
end



local material_prototype = {}
material_prototype.__index = material_prototype

local function new_material(name)
  local o = {
    name = name;
    map_kd = nil;
    map_kd_path = nil;
  }
  setmetatable(o, material_prototype)
  return o
end

local function is_material(o)
  return getmetatable(o) == material_prototype
end

function material_prototype:to_string ()
  local output = "{\n"
  output = output .. "\t" .. "name: " .. self.name .. "\n"
  output = output .. "\t" .. "map_kd: " .. self.map_kd .. "\n"
  output = output .. "}"
  return output
end




local material_lib_prototype = {}
material_lib_prototype.__index = material_lib_prototype

local function new_material_lib(mtl_file, filename)
  local o = {
    materials = {};
    path = get_path(mtl_file);
    mtl_file = mtl_file;
    basename = filename;
  }
  setmetatable(o, material_lib_prototype)
  return o
end

local function is_material_lib(o)
  return getmetatable(o) == material_lib_prototype
end

function material_lib_prototype:build(lines)
  for _itr, line in iter(lines) do
    local cmd, args = line:match'^%s*(%S+) *(.*)'
    cmd = cmd and cmd:lower()
    -- is 'self = foo' dangerous. Perhaps it'd be better to clone members one-by-one
    self = parser_router[cmd](cmd, args, self)
  end
end

function material_lib_prototype:to_string ()
  local output = ""
  output = output .. "path: " .. self.path .. "\n"
  output = output .. "mtl_file: " .. self.mtl_file .. "\n"
  output = output .. "basename: " .. self.basename .. "\n"
  output = output .. "materials:\n"
  output = output .. head(self.materials):to_string()
  for _itr, m in tail(self.materials) do
    assert(is_material(m), "material lib contains materials that are not of type <material_prototype>")
    output = output .. "\n" .. m:to_string()
  end
  return output
end



local cmd_map_kd = function (cmd, args, material_lib)
  local material = material_lib.materials[#material_lib.materials]
  material.map_kd = args
  material.map_kd_path = material_lib.path .. args
  return material_lib
end

local cmd_newmtl = function (cmd, args, material_lib)
  local material = new_material(args)
  table.insert(material_lib.materials, material)
  return material_lib
end

local cmd_mtllib = function (cmd, args, ast)
  -- print(ast.path, args)
  local mtl_path = ast.path .. args
  assert(file_exists(mtl_path), mtl_path .. " doesn't exist")
  local material_lib = new_material_lib(mtl_path, args)
  local lines = get_lines(material_lib.mtl_file)
  material_lib:build(lines)
  -- print(material_lib:to_string())
  table.insert(ast.material_libs, material_lib)
  return ast
end

local lazy = function (fn)
  return function(cmd, args, ast)
    return fn(cmd, args, ast) 
  end
end

parser_router = {
    -- Vertex data
    v = lazy(cmd_v);
    vt = lazy(cmd_vt);
    vn = lazy(cmd_vn);
    vp = lazy(cmd_UNSUPPORTED);

    -- Free-form curve/surface attributes:
    deg = lazy(cmd_UNSUPPORTED);
    bmat = lazy(cmd_UNSUPPORTED);
    step = lazy(cmd_UNSUPPORTED);
    cstype = lazy(cmd_UNSUPPORTED);

    -- Elements:
    p = lazy(cmd_UNSUPPORTED);
    l = lazy(cmd_UNSUPPORTED);
    f = lazy(cmd_f);
    curv = lazy(cmd_UNSUPPORTED);
    curv2 = lazy(cmd_UNSUPPORTED);
    surf = lazy(cmd_UNSUPPORTED);

    -- Free-form curve/surface body statements:
    parm = lazy(cmd_UNSUPPORTED);
    trim = lazy(cmd_UNSUPPORTED);
    hole = lazy(cmd_UNSUPPORTED);
    scrv = lazy(cmd_UNSUPPORTED);
    sp = lazy(cmd_UNSUPPORTED);
    ["end"] = lazy(cmd_UNSUPPORTED);

    -- Connectivity between free-form surfaces:
    con = lazy(cmd_UNSUPPORTED);

    -- Grouping:
    g = lazy(cmd_g);
    s = lazy(cmd_UNSUPPORTED);
    mg = lazy(cmd_UNSUPPORTED);
    o = lazy(cmd_UNSUPPORTED);

    -- Display/render attributes:
    bevel = lazy(cmd_UNSUPPORTED);
    c_interp = lazy(cmd_UNSUPPORTED);
    d_interp = lazy(cmd_UNSUPPORTED);
    lod = lazy(cmd_UNSUPPORTED);
    usemtl = lazy(cmd_UNSUPPORTED);
    mtllib = lazy(cmd_mtllib);
    shadow_obj = lazy(cmd_UNSUPPORTED);
    trace_obj = lazy(cmd_UNSUPPORTED);
    ctech = lazy(cmd_UNSUPPORTED);
    stech = lazy(cmd_UNSUPPORTED);

    -- Material related
    newmtl = lazy(cmd_newmtl);
    map_kd = lazy(cmd_map_kd);
}

local mt = {
  __index = function () 
    return lazy(cmd_UNSUPPORTED)
  end
}
setmetatable(parser_router, mt)






local function get_commands(obj_file)
  local lines = get_lines(obj_file)
  local commands = {}
  for _itr, line in iter(lines) do
    local cmd, args = line:match'^%s*(%S+) *(.*)'
    cmd = cmd and cmd:lower()
    commands[cmd] = (commands[cmd] or 0) + 1
  end
  return commands
end

local function parse_mtl(mtl_file)
  local material_lib = new_material_lib(mtl_file)
  material_lib:build()
  return material_lib
end

local function parse(obj_file)
  local ast = new_ast(obj_file)
  local lines = get_lines(obj_file)
  ast:build(lines)
  return ast
end

local function parse_fn(obj_file, get_lines_fn, file_exists_fn)
  get_lines = get_lines_fn or get_lines
  file_exists = file_exists_fn or file_exists
  local ast = new_ast(obj_file)
  local lines = get_lines(obj_file)
  ast:build(lines)
  return ast
end

local function parse_lines(lines)
  local ast = new_ast()
  for _,line in iter(lines) do
    local cmd, args = line:match'^%s*(%S+) *(.*)'
    cmd = cmd and cmd:lower()
    ast = parser_router[cmd](cmd, args, ast)
  end
  -- ast:to_string()
  return ast
end

local function parse_lines_fn(lines)
  local ast = new_ast()
  for line in lines do
    local cmd, args = line:match'^%s*(%S+) *(.*)'
    cmd = cmd and cmd:lower()
    ast = parser_router[cmd](cmd, args, ast)
  end
  -- ast:to_string()
  return ast
end


-- LOVE MOCK

love.graphics = {}

local love_mesh = {}
love_mesh.__index = love_mesh
love.graphics.newMesh = function (vertices, texture, mode)
  local o = {
    vertices = vertices;
    texture = texture;
    mode = mode or "fan";
  }
  setmetatable(o, love_mesh)
  return o
end
function love_mesh:setTexture (texture)
end
function love_mesh:setVertexMap (vertex_map)
end


love.load = function (obj_file)
  local mesh, texture = 3, 5

  return mesh, texture
end


return {
  love = {
    load = love.load;
  };
	trim = trim,
  get_lines = get_lines,
  parse = parse,
  parse_lines = parse_lines,
  parse_fn = parse_fn,
  get_commands = get_commands
}