enems = {}
enems.objects = {}
enems.objpath = "modules/enemies/"
local register = {}
local id = 0

function enems.Startup()
  register["mech"] = love.filesystem.load(enems.objpath .. "mech.lua" )
  register["bat"] = love.filesystem.load(enems.objpath .. "bat.lua" )
end

function enems.Derive(name)
  return love.filesystem.load(enems.objpath .. name .. ".lua" )()
end

function enems.Create(name, x, y, size, facing, health, r)
  if register[name] then
    id = id + 1
    local ent = register[name]()
    ent:load( name, x, y, size, facing, health, r)
    ent.id = id
    enems.objects[#enems.objects + 1] = ent
    return enems.objects[#enems.objects]
  else
    print("Erreur - " .. name .. "n'existe pas.")
    return false
  end
end

function enems.Destroy( id )
  if enems.objects[id] then
    if enems.objects[id].Die then
      enems.objects[id]:Die()
    end
    enems.objects[id] = nil
  end
end

function enems:update(dt, player)
  for i, ent in pairs(enems.objects) do
    if ent.update then
      ent:update(dt, player)
    end
  end
end

function enems:drawCollisions()
  for i, ent in pairs(enems.objects) do
    if ent.drawCollisions then
      enems:drawCollisions()
    end
  end
end

function enems:draw(player, cam)
  for i, ent in pairs(enems.objects) do
    if ent.draw then
      ent:draw(player, cam)
    end
  end
end
