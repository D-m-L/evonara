--[[
	ZED.LUA BY Alesan99
	GIVE CREDIT IF USED
	BIG THANKS TO:
	http://petercollingridge.appspot.com/3D-tutorial
]]

local zed = {}
local pointcolor = {0, 0, 0, 255}
local edgecolor = {0, 0, 0, 255}

function zed.setPointColor(...)
	pointcolor = {...}
end

function zed.setEdgeColor(...)
	edgecolor = {...}
end

function zed.newCube(x, y, z, facesize)
	local facesize = facesize/2
	local nodes = {{-facesize+x,-facesize+y, facesize+z},  {-facesize+x, facesize+y, facesize+z},
				{ facesize+x, facesize+y, facesize+z},  { facesize+x,-facesize+y, facesize+z},
				{-facesize+x,-facesize+y, -facesize+z}, {-facesize+x, facesize+y, -facesize+z},
				{ facesize+x, facesize+y, -facesize+z}, { facesize+x,-facesize+y, -facesize+z}}
	local edges = {{1, 2}, {2, 4}, {4, 3}, {3, 1},
				{5, 6}, {6, 8}, {8, 7}, {7, 5},
				{1, 5}, {2, 6}, {3, 7}, {4, 8}}
	local faces = {{1, 2, 3, 4, i = 1},{8, 7, 6, 5, i = 2},
                    {1, 4, 8, 5, i = 3},{3, 2, 6, 7, i = 4},
                    {4, 3, 7, 8, i = 5}, {2, 1, 5, 6, i = 6}}
	local facecolors = {{150, 150, 150}, {150, 150, 150},
						{100, 100, 100}, {100, 100, 100},
						{150, 150, 150}, {200, 200, 200}}
	local form = {n = nodes, e = edges, f = faces, fc = facecolors, rotx = 0, roty = 0, rotz = 0}
	return form
end

function zed.newRectangularPrism(x, y, z, w, h, d)
	local w, h, d = w/2, h/2, d/2
	local nodes = {{-w+x,-h+y, d+z},  {-w+x, h+y, d+z},
				{ w+x, h+y, d+z},  { w+x,-h+y, d+z},
				{-w+x,-h+y, -d+z}, {-w+x, h+y, -d+z},
				{ w+x, h+y, -d+z}, { w+x,-h+y, -d+z}}
	local edges = {{1, 2}, {2, 4}, {4, 3}, {3, 1},
				{5, 6}, {6, 8}, {8, 7}, {7, 5},
				{1, 5}, {2, 6}, {3, 7}, {4, 8}}
	local faces = {{1, 2, 3, 4, i = 1},{8, 7, 6, 5, i = 2},
                    {1, 4, 8, 5, i = 3},{3, 2, 6, 7, i = 4},
                    {4, 3, 7, 8, i = 5}, {2, 1, 5, 6, i = 6}}
	local facecolors = {{150, 150, 150}, {150, 150, 150},
						{100, 100, 100}, {100, 100, 100},
						{150, 150, 150}, {200, 200, 200}}
	local form = {n = nodes, e = edges, f = faces, fc = facecolors, rotx = 0, roty = 0, rotz = 0}
	return form
end

function zed.newForm(n, e, f, fc)
	local form = {n = n, e = e, f = f, fc = fc, rotx = 0, roty = 0, rotz = 0}
	return form
end

function zed.setFaceColors(obj, colors)
	obj.fc = colors
end

function zed.setFaceColor(obj, face, color)
	obj.fc[face] = color
end

--Draw functions
local function subtractVectors(v1, v2)
    return {v1[1] - v2[1],
            v1[2] - v2[2],
            v1[3] - v2[3]}
end
local function normalizeVector(v)
    local d = math.sqrt(v[1]*v[1]+v[2]*v[2]+v[3]*v[3])
    return {v[1]/d, v[2]/d, v[3]/d}
end
local function normalOfPlane(face, nodes)
    local n1 = nodes[face[1]]
    local n2 = nodes[face[2]]
    local n3 = nodes[face[3]]
    local v1 = subtractVectors(n1, n2)
    local v2 = subtractVectors(n1, n3)
    local v3 = {v1[2]*v2[3] - v1[3]*v2[2],
              v1[3]*v2[1] - v1[1]*v2[3],
              v1[1]*v2[2] - v1[2]*v2[1]}
    return v3
end
local function dotProduct(v1, v2)
    return v1[1]*v2[1] + v1[2]*v2[2] + v1[3]*v2[3]
end

local lightVector = normalizeVector({0,0,-1})
local lvc = {0,0,-1}

function zed.setLightVector(...)
	lvc = {...}
	lightvector = normalizeVector(lvc)
end

function zed.getLightVector(...)
	return lvc, lightvector
end

local camera = {0, 0, 0}

function zed.setCamera(...)
	camera = {...}
end

function zed.getCamera()
	return camera
end

local fov = 0

function zed.setFOV(a)
	fov = a/100
end

function zed.getFOV()
	return fov*100
end

function zed.drawForm(obj, tasks)
	assert(obj, "No object")
	if not tasks then
		tasks = {faces = true, shadows = true}
	end
	--draw faces
    local i, o
    local face
    local nodes = {}
	for j, w in pairs(obj.n) do
		table.insert(nodes, {w[1], w[2], w[3]})
	end
    local node1
    local node2
	
	--perspective
	for j, w in pairs(nodes) do
		w[1] = w[1]+((camera[1]-w[1])*(camera[3]-w[3]*fov))
		w[2] = w[2]+((camera[2]-w[2])*(camera[3]-w[3]*fov))
	end
        
	if tasks.faces then
		local faces = {}
		for i = 1, #obj.f do
			face = obj.f[i]
			local fnorm = normalOfPlane(face, nodes)
			if fnorm[3] < 0 then
				if tasks.shadows then
					local l = dotProduct(lightVector, normalizeVector(fnorm))
					love.graphics.setColor(math.min(255, math.max(l*obj.fc[face.i][1], 0)), math.min(255, math.max(l*obj.fc[face.i][2], 0)), math.min(255, math.max(l*obj.fc[face.i][3], 0)))
				else
					love.graphics.setColor(obj.fc[face.i][1], obj.fc[face.i][2], obj.fc[face.i][3])
				end
				local mode = "fill"
				if #face == 3 then
					love.graphics.polygon(mode, nodes[face[1]][1], nodes[face[1]][2],
												nodes[face[2]][1], nodes[face[2]][2],
												nodes[face[3]][1], nodes[face[3]][2])
				else
					love.graphics.polygon(mode, nodes[face[1]][1], nodes[face[1]][2],
												nodes[face[2]][1], nodes[face[2]][2],
												nodes[face[3]][1], nodes[face[3]][2],
												nodes[face[4]][1], nodes[face[4]][2])
				end
				if tasks.faceOutline then
					mode = "line"
					if #face == 3 then
						love.graphics.polygon(mode, nodes[face[1]][1], nodes[face[1]][2],
													nodes[face[2]][1], nodes[face[2]][2],
													nodes[face[3]][1], nodes[face[3]][2])
					else
						love.graphics.polygon(mode, nodes[face[1]][1], nodes[face[1]][2],
													nodes[face[2]][1], nodes[face[2]][2],
													nodes[face[3]][1], nodes[face[3]][2],
													nodes[face[4]][1], nodes[face[4]][2])
					end
				end
			end
		end
	end
	--draw edges
	love.graphics.setColor(unpack(edgecolor))
	if tasks.edges then
		for e = 1, #obj.e do
			local n1 = obj.e[e][1]
			local n2 = obj.e[e][2]
			local node1 = nodes[n1]
			local node2 = nodes[n2]
			love.graphics.line(node1[1], node1[2], node2[1], node2[2])
		end
	end
	--draw nodes
	love.graphics.setColor(unpack(pointcolor))
	if tasks.nodes then
		for n = 1, #nodes do
			local node = nodes[n]
			love.graphics.point(node[1], node[2])
		end
	end
	if tasks.ids then
		for n = 1, #nodes do
			local node = nodes[n]
			love.graphics.print(n, node[1]-6, node[2]-20)
		end
	end
end

function zed.getNodes(obj)
	return obj.n
end

function zed.getEdges(obj)
	return obj.e
end

function zed.getFaces(obj)
	return obj.f
end

function zed.rotateFormX(obj, theta)
	local sin_t = math.sin(theta)
	local cos_t = math.cos(theta)
	
	for n = 1, #obj.n do
		local node = obj.n[n]
		local x = node[1]
		local z = node[3]
		node[1] = x * cos_t - z * sin_t
		node[3] = z * cos_t + x * sin_t
	end
	obj.roty = obj.roty + math.deg(theta)
	while obj.roty >= 360 do
		obj.roty = obj.roty - 360
	end
	while obj.roty < 0 do
		obj.roty = obj.roty + 360
	end
end

function zed.rotateFormY(obj, theta)
	local sin_t = math.sin(theta)
	local cos_t = math.cos(theta)
	
	for n = 1, #obj.n do
		local node = obj.n[n]
		local y = node[2]
		local z = node[3]
		node[2] = y * cos_t - z * sin_t
		node[3] = z * cos_t + y * sin_t
	end
	obj.rotx = obj.rotx + math.deg(theta)
	while obj.rotx >= 360 do
		obj.rotx = obj.rotx - 360
	end
	while obj.rotx < 0 do
		obj.rotx = obj.rotx + 360
	end
end

function zed.rotateFormZ(obj, theta)
	local sin_t = math.sin(theta)
	local cos_t = math.cos(theta)
		
	for n = 1, #obj.n do
		local node = obj.n[n]
		local x = node[1]
		local y = node[2]
		node[1] = x * cos_t - y * sin_t
		node[2] = y * cos_t + x * sin_t
	end
	obj.rotz = obj.rotz + math.deg(theta)
	while obj.rotz >= 360 do
		obj.rotz = obj.rotz - 360
	end
	while obj.rotz < 0 do
		obj.rotz = obj.rotz + 360
	end
end

function zed.rotateForm(obj, thetax, thetay, thetaz)
	zed.rotateFormX(obj, thetax or 0)
	zed.rotateFormY(obj, thetay or 0)
	zed.rotateFormZ(obj, thetaz or 0)
end

function zed.getFormRotation(obj)
	return obj.rotx, obj.roty, obj.rotz
end

function zed.translateForm(obj, x, y, z)
	local nodes = obj.n
	for i = 1, #obj.n do
		nodes[i] = {nodes[i][1]+x, nodes[i][2]+y, nodes[i][3]+z}
	end
end

return zed