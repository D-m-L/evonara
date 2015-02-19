local vec3 = require 'eiga.math.vec3'
local vec4 = require 'eiga.math.vec4'
local mat4 = require 'eiga.math.mat4'
local quat = require 'eiga.math.quat'

local camera = {}
camera.__index = camera

local DEFAULTS = {
  fov = 100,
  distance = 1000,
  position = vec3( 0, 0, 0 ),
  forward = vec3( 0, 0, -1 ),
  heading = vec3( 0, 0, -1 ),
  view_matrix = mat4.identity(),
  up = vec3( 0, 1, 0),
  left = vec3( -1, 0, 0 ),
  pitch = 0,
  roll = 0,
  yaw = 0,
  strafe = 0,
  march = 0,
  fly = 0,
  rotateSpeed = 0.001,
  translateSpeed = 5
}

local M_PI = 3.1415265
local M_2_PI = M_PI * 2
local M_PI_OVER_2 = M_PI / 2
local M_PI_OVER_4 = M_PI / 4

local function new ( options )
  local v = {
    position = options.position or DEFAULTS.position,
    forward = options.forward or DEFAULTS.forward,
    left = options.left or DEFAULTS.left,
    up = options.up or DEFAULTS.up,
    heading = options.heading or DEFAULTS.heading,
    view_matrix = options.view_matrix or DEFAULTS.view_matrix,
    pitch = options.pitch or DEFAULTS.pitch,
    yaw = options.yaw or DEFAULTS.yaw,
    roll = options.roll or DEFAULTS.roll,
    strafe = options.strafe or DEFAULTS.strafe,
    march = options.march or DEFAULTS.march,
    fly = options.fly or DEFAULTS.fly,
    rotateSpeed = options.rotateSpeed or DEFAULTS.rotateSpeed,
    translateSpeed = options.translateSpeed or DEFAULTS.translateSpeed,
    fov = options.fov or DEFAULTS.fov,
    perspective_matrix = ( function ()
        return mat4.perspectiveFov(options.fov or DEFAULTS.fov,
                                   eiga.window.width / eiga.window.height,
                                   0.1,
                                   options.distance or DEFAULTS.distance)
      end )()
  }
  setmetatable(v, camera)
  return v
end

local function load ( data )
  assert( type( data ) == "table" )
  return new( {
    position = vec3.from_table( data.position ),
    forward = vec3.from_table( data.forward ),
    left = vec3.from_table( data.left ),
    up = vec3.from_table( data.up ),
    heading = vec3.from_table( data.heading ),
    pitch = data.pitch,
    yaw = data.yaw,
    roll = data.roll,
    fov = data.fov,
    distance = data.distance,
    view_matrix = data.view_matrix
    } )
end

function camera:get_save_data ()
  return {
    position = self.position,
    forward = self.forward,
    left = self.left,
    up = self.up,
    heading = self.heading,
    pitch = self.pitch,
    yaw = self.yaw,
    roll = self.roll,
    fov = self.fov,
    distance = self.distance,
    view_matrix = self.view_matrix
  }
end

function camera:printdebug()
  local view = self:getView()
  print(string.format([[
Camera:
    position:     %s
    heading:      %s
    forward:      %s
    left:         %s
    up:           %s
    pitch:        %.4f
    yaw:          %.4f
    viewview_matrix:]].."\
                  %.2f, \t%.2f, \t%.2f, \t%.2f\
                  %.2f, \t%.2f, \t%.2f, \t%.2f\
                  %.2f, \t%.2f, \t%.2f, \t%.2f\
                  %.2f, \t%.2f, \t%.2f, \t%.2f"
  , tostring(self.position),
      tostring(self.heading),
      tostring(self.forward),
      tostring(self.left),
      tostring(self.up),
      self.pitch,
      self.yaw,
      view[1], view[5], view[9], view[13],
      view[2], view[6], view[10], view[14],
      view[3], view[7], view[11], view[15],
      view[4], view[8], view[12], view[16]))
end

function camera:translateLeft(x)
  self.strafe = self.strafe + x
  return self
end

function camera:translateUp(y)
  self.fly = self.fly + y
  return self
end

function camera:translateForward(z)
  self.march = self.march + z
  return self
end

function camera:rotatePitch(xr)
  self.pitch = self.pitch + xr * self.rotateSpeed
  if self.pitch > M_PI_OVER_2 then self.pitch = M_PI_OVER_2 end
  if self.pitch < -M_PI_OVER_2 then self.pitch = -M_PI_OVER_2 end
  return self
end

function camera:rotateYaw(yr)
  self.yaw = self.yaw + yr * self.rotateSpeed
  if self.yaw > M_2_PI then self.yaw = self.yaw - M_2_PI end
  if self.yaw < 0 then self.yaw = M_2_PI + self.yaw end
  return self
end

function camera:rotateRoll()
  return self
end

function camera:update(dt)
  local pitch_quat = quat.fromeuler(self.pitch, 0, 0)
  local yaw_quat = quat.fromeuler(0, self.yaw, 0)

  local r = mat4((pitch_quat * yaw_quat):getmat4())
  local p = mat4((yaw_quat * pitch_quat):getmat4())

  -- local r = mat4.fromRotationTranslation(pitch_quat * yaw_quat, vec3(0, 0, 0))
  -- local p = mat4.fromRotationTranslation(yaw_quat * pitch_quat, vec3(0, 0, 0))

  self.left[1], self.left[2], self.left[3] = -r[1], 0, r[3]
  self.left:normalize()
  self.up[1], self.up[2], self.up[3] = p[5], p[6], -p[7]
  self.up:normalize()
  self.heading[1], self.heading[2], self.heading[3] = r[9], 0, -r[11]
  self.forward = self.left:cross(self.up)
  self.forward:normalize()
  self.forward[1] = r[9]
  self.forward[3] = -r[11]

  local displacement = (self.forward * self.march) +
                       (self.left * self.strafe) +
                       ( self.up * self.fly)

  displacement:normalize()
  displacement = displacement * self.translateSpeed * dt

  -- subtract because we want the inverse
  self.position[1] = self.position[1] - displacement[1]
  self.position[2] = self.position[2] - displacement[2]
  self.position[3] = self.position[3] - displacement[3]

  self.strafe = 0
  self.fly = 0
  self.march = 0

  self.view_matrix = r * mat4.translate(self.position[1], self.position[2], self.position[3])

  return self
end

function camera:setSlots ()
  gPubsub:sub("camera::rotatePitch", self, self.rotatePitch)
  gPubsub:sub("camera::rotateYaw", self, self.rotateYaw)
  gPubsub:sub("camera::printdebug", self, self.printdebug)
  gPubsub:sub("camera::translateForward", self, function (s) self:translateForward(1) end)
  gPubsub:sub("camera::translateBackward", self, function (s) self:translateForward(-1) end)
  gPubsub:sub("camera::translateLeft", self, function (s) self:translateLeft(1) end)
  gPubsub:sub("camera::translateRight", self, function (s) self:translateLeft(-1) end)
  gPubsub:sub("camera::translateUp", self, function (s) self:translateUp(1) end)
  gPubsub:sub("camera::translateDown", self, function (s) self:translateUp(-1) end)
  return self
end

return setmetatable({
  new = new,
  load = load
  },
  {__call = function(_,...) return new(...) end})
