local function split(self, pat)
    local st, g = 1, self:gmatch("()("..pat..")")
    local function getter(self, segs, seps, sep, cap1, ...)
        st = sep and seps + #sep
        return self:sub(segs, (seps or 0) - 1), cap1 or sep, ...
    end
    local function splitter(self)
        if st then return getter(self, st, g()) end
    end

    return splitter, self
end

local mesh = {}

function mesh.loadObj(filename,texture)
    local vertices = {}
    local uvs = {}
    local tris = {}
    local normals = {}
    local n = tonumber
    for line in love.filesystem.lines(filename) do
        local data = {}
        for str in split(line, " ") do
            data[#data+1]=str
        end
        if data[1] == "v" then
            vertices[#vertices+1] = {n(data[2]),n(data[3]),n(data[4])}
        elseif data[1]=="vt" then
            uvs[#uvs+1] = {n(data[2]),-n(data[3]) }
        elseif data[1] == "vn" then
            normals[#normals+1] = {-n(data[2]),-n(data[3]),-n(data[4]) }
        elseif data[1] == "f" then
            local faceVertices = {}
            for v=2, #data do
                local fdata = {}
                for str in split(data[v], "/") do
                    fdata[#fdata+1]=str
                end
                faceVertices[#faceVertices+1] = {vertexID=n(fdata[1]),uvID=n(fdata[2]),normalID=n(fdata[3]) }
                --print(#tris+1,fdata[1])
            end
            tris[#tris+1] = faceVertices
        end
    end

    print("Finished loading "..filename)
    print(#vertices.." Vertices")
    print(#uvs.." UVs")
    print(#tris.." Tris")
    print(#normals.." Normals")

    return mesh.new(texture and love.graphics.newImage(texture) or nil,vertices,uvs,tris,normals)
end


function mesh.new(Texture,Vertices,UVs,Tris,Normals)
    --Store Data
		
    local texture = Texture
    if Texture then texture:setWrap("repeat") end
    --texture:setFilter("nearest")
    local tris = Tris
    local vertices3d = Vertices
    local projected3d = {} --stores 2d coordinates of a 3d vertex of the same index ([1][2]) and the distance to camera([3])
    local mesh --love 2d mesh object used for drawing
    local lookupv2d = {} --stores id of the actual vertex in a love2d mesh, indexed by its corresponding 3dvertex index and its uv coordinate index
    local normals = Normals
    local uvs = UVs
    local zbuffer = {} --will hold a tri id and a the median triangle distance to camera (NOT A REAL Z-BUFFER)

    --Identify 2d Vertices
    local vertices2d = {}
    for triID=1, #tris do --iterate tris
        lookupv2d[triID] = {}
        for vertex=1, #tris[triID] do --iterate vertices
            local v = tris[triID][vertex]
            if not projected3d[v.vertexID] then projected3d[v.vertexID] = {} end
            vertices2d[#vertices2d+1] = {0,0,uvs[v.uvID][1],uvs[v.uvID][2],0,0,0,255}
            lookupv2d[triID][vertex] = #vertices2d
        end
    end

    --Initialization
    mesh = love.graphics.newMesh(vertices2d,texture,"triangles")
    print(#vertices2d.." 2D Vertices were created (I'm sorry)")
    vertices2d = nil --we no longer need it. It's stored in the mesh
    print("Using Vertex Colors:",mesh:hasVertexColors( ))
    --Class
    local i = {}
    i.culling = true
		i.sorting = true
    i.drawAxis = false
    local debug = {["3d Vertices"]=#vertices3d,["2d Vertices"]=#tris*3,["Triangles"]=#tris,["Current Triangles"]=0,["Culling enabled"]=true}

		local light = {}
		function i:updateLight()
				for t=1, #tris do
					for v=1, 3 do
						if not light[tris[t][v].vertexID] then light[tris[t][v].vertexID] = {} end
						local normal = normals[tris[t][v].normalID]
						local ldot = (-0.7)*normal[1] + (0.7)*normal[2] + (0)*normal[3]
						ldot = ldot > -1 and ldot or -1
						ldot = ldot < 1 and ldot or 1
						local l = (ldot+1)/2*255
						light[tris[t][v].vertexID][#light[tris[t][v].vertexID]+1] = l
					end
				end
				for i=1, #light do
					local sum, amount = 0, #light[i]
					for l=1, amount do
						sum = sum+light[i][l]
					end
					light[i] = sum/amount
				end
		end
		
    local sort = table.sort --localize sort for a little extra speed
		local sortfunc = function(a,b) return zbuffer[a] > zbuffer[b] end
    function i:update(cam)
				local drawfaces = {} --faces to draw in this cycle
				local visited3d = {} --make sure you update every 3d point only once
        for t=1, #tris do
            --compute dot product between camera direction and triangle normal (all vertices on a triangle share the same normal)
            local normal = normals[tris[t][1].normalID]
            local cv = cam:getVector()
            local dot = (-cv[1])*normal[1] + (-cv[2])*normal[2] + (-cv[3])*normal[3]
            if not i.culling or dot <0 then -- face is visible
                --get light level
                --local ldot = (-0.7)*normal[1] + (0.7)*normal[2] + (0)*normal[3]
                --ldot = ldot > -1 and ldot or -1
                --ldot = ldot < 1 and ldot or 1
                --local light = (ldot+1)/2*255
								for v=1, 3 do
                    if not visited3d[tris[t][v].vertexID] then
                        --project all visisble points, that haven't been projected yet into the projected table
                        cam:project(vertices3d[tris[t][v].vertexID],projected3d[tris[t][v].vertexID])
                        visited3d[tris[t][v].vertexID] = true
                    end
                    --update the 2d point that fits the vertex/uv combination
                    local v2id = lookupv2d [t] [v]
                    --update the coordiantes, and uvs of the 2d mesh point
                    mesh:setVertex( v2id, projected3d[tris[t][v].vertexID][1], projected3d[tris[t][v].vertexID][2], uvs[tris[t][v].uvID][1], uvs[tris[t][v].uvID][2],light[tris[t][v].vertexID],light[tris[t][v].vertexID],light[tris[t][v].vertexID])
                    if v==3 then -- calculate tri median distance to camera
                        local z1,z2,z3
                        z1 = projected3d[tris[t][v].vertexID][3]
                        z2 = projected3d[tris[t][v-1].vertexID][3]
                        z3 = projected3d[tris[t][v-2].vertexID][3]
                        zbuffer[t] = (z1+z2+z3)/3
                    end
                end
                drawfaces[#drawfaces+1] = t
            end
        end
        --Sort face by their camera distance, farthest first
        if self.sorting then sort(drawfaces,sortfunc) end

        local vmap = {} --vertex map, tells the mesh in which order to draw the triangles
        for i=1,#drawfaces do
            vmap[#vmap+1] = lookupv2d[drawfaces[i]][1]
            vmap[#vmap+1] = lookupv2d[drawfaces[i]][2]
            vmap[#vmap+1] = lookupv2d[drawfaces[i]][3]
        end
        debug["Current Triangles"]=#vmap/3
        if #vmap == 0 then vmap = {1,1,1} end
        mesh:setVertexMap(vmap)
    end

    function i:draw(x,y,cam)
        love.graphics.draw(mesh,x,y)
        if self.drawAxis then
            local axis,proaxis = {{1000,0,0},{0,1000,0},{0,0,1000}},{{},{},{} }
            cam:project(axis[1],proaxis[1])
            cam:project(axis[2],proaxis[2])
            cam:project(axis[3],proaxis[3])
            love.graphics.setColor(255,0,0)
            love.graphics.line(0,0,proaxis[1][1],proaxis[1][2])
            love.graphics.setColor(0,255,0)
            love.graphics.line(0,0,proaxis[2][1],proaxis[2][2])
            love.graphics.setColor(0,0,255)
            love.graphics.line(0,0,proaxis[3][1],proaxis[3][2])
            love.graphics.setColor(255,255,255)
        end
    end

    function i:getNormal(id)
        return normals[id]
    end

    function i:setFilter(arg)
        if texture then texture:setFilter(arg) end
    end

    function i:getDebug()
        debug["Culling enabled"] = self.culling and "true" or "false"
        debug["Sorting enabled"] = self.sorting and "true" or "false"
				return debug
    end
		
		function i:release()
			mesh:setTexture()
		end

    return i
end

return mesh