function screenFadeIn(color, dur, delay)
  finished = false
  local r, g, b = unpack(color)
  flux.to(cam, dur, {fade = 0}):delay(delay):ease("quadout"):oncomplete(function() math.increment(state.event, 2) end)
  lg.setColor(r, g, b, cam.fade)
  lg.rectangle("fill",0,0,scrn.w,scrn.h)
  
  return finished
end

function nextEvent(eventNum)
  eventNum = eventNum + 1
end