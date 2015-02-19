    --- Returns the future position assuming no external forces are acting on the body
    -- @x, @y Current position at the beginning of the time step
    -- @lvx, lvy Current linear velocity at the beginning of the time step
    -- @damping Linear damping
    -- @gx, gy Gravity
    -- @dt Time step
    -- @return Future position at the end of the time step
    function math.futurePos(x, y, lvx, lvy, damping, gx, gy, dt)
      -- integrate gravity
      local fpx = lvx + gx*dt
      local fpy = lvy + gy*dt
      -- apply damping
      local d = 1 - dt*damping
      if d < 0 then
        d = 0
      elseif d > 1 then
        d = 1
      end
      return fpx*d + x, fpy*d + y
    end

    --- Returns the future angle assuming no external forces are acting on the body
    -- @x, @y Current angle at the beginning of the time step
    -- @lvx, lvy Current angular velocity at the beginning of the time step
    -- @damping Angular damping
    -- @dt Time step
    -- @return Future angle at the end of the time step
    function math.futureAng(a, av, damping, dt)
      -- apply damping
      local d = 1 - dt*damping
      if d < 0 then
        d = 0
      elseif d > 1 then
        d = 1
      end
      return av*d + a
    end
    
       --- Compensates for the effects of gravity
    -- @lvx, lvy Desired linear velocity at the end of the time step
    -- @gx, gy Gravity
    -- @dt Time step
    -- @return Target linear velocity at the beginning of the time step
    function math.compG(lvx, lvy, gx, gy, dt)
      return lvx - gx*dt, lvy - gy*dt
    end

    --- Compensates for the effects of linear damping
    -- @lvx, lvy Desired linear velocity at the end of the time step
    -- @damping Linear damping
    -- @maxLV Maximum linear velocity
    -- @dt Time step
    -- @return Target linear velocity at the beginning of the time step
    function math.compLD(lvx, lvy, damping, maxLV, dt)
      local d = 1 - dt*damping
      if d <= 0 then
        local lv = math.sqrt(lvx*lvx + lvy*lvy)
        local nx, ny = lvx/lv, lvy/lv
        return nx*maxLV, ny*maxLV
      elseif d > 1 then
        d = 1
      end
      return lvx/d, lvy/d
    end

    --- Compensates for the effects of angular damping
    -- @av Desired angular velocity at the end of the time step
    -- @damping Linear damping
    -- @maxAV Maximum angular velocity
    -- @dt Time step
    -- @return Target angular velocity at the beginning of the time step
    function math.compAD(av, damping, maxAV, dt)
      local d = 1 - dt*damping
      if d <= 0 then
        if av < 0 then
          return -maxAV
        else
          return maxAV
        end
      elseif d > 1 then
        d = 1
      end
      return av/d
    end
    
        --- Returns the force required to reach a given linear velocity
    --- force = ( change in velocity / time ) * mass
    -- @ivx, @ivy Initial linear velocity at the beginning of the time step
    -- @fvx, @fvy Final linear velocity at the end of the time step
    -- @mass Mass
    -- @dt Time step
    -- @return Force
    function math.force(ivx, ivy, fvx, fvy, mass, dt)
      return (fvx - ivx)/dt*mass, (fvy - ivy)/dt*mass
    end

    --- Returns the torque required to reach a given angular velocity
    --- inertia = mass * initial velocity
    --- torque = ( change in velocity / time ) * inertia
    -- @iv Initial angular velocity at the beginning of the time step
    -- @fv Final angular velocity at the end of the time step
    -- @mass Mass
    -- @dt Time step
    -- @return Torque
    function math.torque(iv, fv, mass, dt)
      local inertia = mass*iv
      return (fv - iv)/dt*inertia
    end
    
        --- Returns the time required to accelerate to a given linear velocity
    --- time = change in velocity * mass / force
    -- @ivx, @ivy Initial linear velocity
    -- @fvx, @fvy Final linear velocity
    -- @mass Mass
    -- @force Maximum force
    -- @return Time
    function math.atime(ivx, ivy, fvx, fvy, mass, force)
      -- change in velocity
      local dx, dy = fvx - ivx, fvy - ivy
      local d = math.sqrt(dx*dx + dy*dy)
      return d*mass/force
    end

    --- Returns the time required to accelerate to a given angular velocity
    --- inertia = mass * initial velocity
    --- time = change in velocity * inertia / torque
    -- @iv Initial angular velocity
    -- @fv Final angular velocity
    -- @mass Mass
    -- @force Maximum torque
    -- @return Time
    function math.aatime(iv, fv, mass, torque)
      local inertia = mass*iv
      return (fv - iv)*inertia/torque
    end