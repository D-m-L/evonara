ents = {}
ents.objects = {}
ents.objpath = "modules/entities/"
local register = {}
local id = 0

function ents.Startup()
  register["crate"] = love.filesystem.load(ents.objpath .. "crate.lua" )
  register["sinX"] = love.filesystem.load(ents.objpath .. "sinX.lua" )
  register["cloud"] = love.filesystem.load(ents.objpath .. "cloud.lua" )
  register["bgcloud"] = love.filesystem.load(ents.objpath .. "bgcloud.lua" )
  register["water"] = love.filesystem.load(ents.objpath .. "water.lua" )
  register["mech"] = love.filesystem.load(ents.objpath .. "mech.lua" )
  
  register["pointcloud"] = love.filesystem.load(ents.objpath .. "pointcloud.lua" )
  register["lightning"] = love.filesystem.load(ents.objpath .. "lightning.lua" )
  register["linesegment"] = love.filesystem.load(ents.objpath .. "linesegment.lua" )
  register["mesh"] = love.filesystem.load(ents.objpath .. "mesh.lua" )
  
  register["cave"] = love.filesystem.load(ents.objpath .. "cave.lua" )
  register["miner"] = love.filesystem.load(ents.objpath .. "miner.lua" )
end

function ents.Derive(name)
  return love.filesystem.load(ents.objpath .. name .. ".lua" )()
end

function ents.Create(name, x, y, w, h, size)
  if register[name] then
    id = id + 1
    local ent = register[name]()
    ent:load( x, y, w, h, size)
    ent.id = id
    ents.objects[#ents.objects + 1] = ent
    return ents.objects[#ents.objects]
  else
    print("Erreur - " .. name .. "n'existe pas.")
    return false
  end
end

function ents.Destroy( id )
  if ents.objects[id] then
    if ents.objects[id].Die then
      ents.objects[id]:Die()
    end
    ents.objects[id] = nil
  end
end

function ents:update(dt, player)
  for i, ent in pairs(ents.objects) do
    if ent.update then
      ent:update(dt, player)
    end
  end
end

function ents:draw(player, cam)
  for i, ent in pairs(ents.objects) do
    if ent.draw then
      ent:draw(player, cam)
    end
  end
end
