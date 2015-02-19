function beginContact(a, b, coll)
    x,y = coll:getNormal()
    x = maths.round(x, 4)  y = maths.round(y, 4)
    
    local aname, bname = a:getUserData().name, b:getUserData().name
    anamesub = string.sub(aname,1,3)   bnamesub = string.sub(bname,1,3)
    if aname == nil then aname = "Unknown" end if bname == nil then bname = "Unknown" end 
    cbtxt = cbtxt.."\n"..aname.." collided with "..bname.." with a vector normal of: "..x..", "..y
    
    if anamesub == "bat" and (bname == "Ara" or bname == "Evo") then
      a:getUserData().state = "dying"
      cbtxt = cbtxt.. "\n bat got whacked! Is now " .. a:getUserData().state
--      deademies[#deademies] = a:getUserData()
      --killEnemy(a:getUserData())
    elseif bnamesub == "bat" and (aname == "Ara" or aname == "Evo") then
      b:getUserData().state = "dying"
      cbtxt = cbtxt .. "\n bat got whacked! Is now " .. b:getUserData().state
      --killEnemy(b:getUserData())
--      deademies[#deademies] = b:getUserData()
    end
    
    
end

function endContact(a, b, coll)
  local aname, bname = a:getUserData().name, b:getUserData().name
    if aname == nil then aname = "Unknown" end if bname == nil then bname = "Unknown" end 
    cbpersists = 0
    cbtxt = cbtxt.."\n"..aname.." seperated from "..bname
end

function preSolve(a, b, coll)
  local aname, bname = a:getUserData().name, b:getUserData().name
    if aname == nil then aname = "Unknown" end if bname == nil then bname = "Unknown" end 
    if cbpersists == 0 then    -- only say when they first start touching
        cbtxt = cbtxt.."\n"..aname.." touched "..bname
    elseif cbpersists < 21 then    -- then just start counting
        cbtxt = cbtxt.." "..cbpersists
    end
    cbpersists = cbpersists + 1    -- keep track of how many updates they've been touching for
end

function postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)
end