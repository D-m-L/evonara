local camera = {}

function camera.new()
    local cos,sin,f = math.cos, math.sin,math.floor
    local i = {}
    i.a,i.b,i.c = 0,0,0

    local maB={
    {1,     0,       0},
    {0,     nil,    nil},
    {0,     nil,    nil},
    }
    local maA={
    {nil, nil, 0},
    {nil, nil, 0},
    {0,   0,   1}
    }
    local rotMat = {
        {},
        {},
        {}
    }

    function i:project(p,pp)
        local x,y,z = p[1],-p[2],-p[3]
        pp[1] = x*rotMat[1][1]+y*rotMat[1][2]+z*rotMat[1][3]
        pp[2] = x*rotMat[2][1]+y*rotMat[2][2]+z*rotMat[2][3]
        pp[3] = x*rotMat[3][1]+y*rotMat[3][2]+z*rotMat[3][3]
    end

    local base = {0,0,-1}
    local vector = {}

    function i:getVector()
        return vector
    end

    local function matrixMul(a,b,c)
        for row=1, 3 do
            for coll=1, 3 do
                c[row][coll] = a[row][1] * b[1][coll] + a[row][2] * b[2][coll] + a[row][3] * b[3][coll]
            end
        end
    end

    function i:update()
        --precalculate sin/cos values
        local sina,cosa,sinb,cosb = sin(self.a),cos(self.a),sin(self.b),cos(self.b)
        --update matrices
        maB[2][2],maB[2][3] = cosb, sinb
        maB[3][2],maB[3][3] = -sinb,cosb
        maA[1][1],maA[1][2] = cosa,-sina
        maA[2][1],maA[2][2] = sina,cosa
        --calculate rotation matrix
        matrixMul(maB,maA,rotMat)
        --local sina,cosa,sinb,cosb = sin(-self.a),cos(-self.a),sin(-self.b),cos(-self.b)

        --rotate vector around x
        local x,y,z
        x = base[1]
        y = base[2]*cosb - base[3]*sinb
        z = base[2]*sinb + base[3]*cosb
        vector[1] = cosa*x - sina*y
        vector[2] = sina*x + cosa*y
        vector[3] = z
        --self:project(base,vector)
    end

    return i
end

return camera