RadSprt = class()

function RadSprt:init(sprt, r, x, y)
    -- you can accept and set parameters here
    self.img = sprt
    self.r = r
    self.r2 = r*2
    self.x = x or 0
    self.y = y or 0
    self.vertices = {}
    self.mesh = self:setupMesh()
end

function RadSprt:setupMesh()
    -- init a mesh object
    local radMesh = mesh()
    -- amount of triangles
    local sides = 8
    -- angle size in degrees
    local section = 360 / sides / 2
    local r = self.r
    --[[
        When calculating the vertices
        We add a padding of  r * 0.07 pixels.
        This is important becasue we are using a relatively
        Low Poly mesh with 8 triangles.
        so the padding will make sure the Rad/Circle
        will appear to be smooth and not edgy
    --]]
    local rWithPadding = r + r * 0.07

    local r2 = self.r2
    -- init verts + add cicle center (0,0)
    local verts = {vec2(0,0)}
    -- use derivitives to create circular points around (0,0)
    for i = 0, sides - 1, 1 do
        -- calculate angle per side, multiply by 2 for a full circle
        local angle = i * section * DEG_2_RAD * 2
        local x = math.cos(angle) * rWithPadding / 2 
        local y = math.sin(angle) * rWithPadding / 2
        table.insert(verts, vec2(x, y))
    end
    
    -- init triangles object (needed to align vertices into renderable triads)
    local triangles = {}
    -- uvs to map circular image on octagon
    local uv = {}
    -- caclulcate triads and uvs
    for i = 2, sides + 1, 1 do
        -- traids must be built clockwise so they are visible
        -- otherwise we'll see their backside
        local mid = verts[1]
        local snd = i == (sides + 1) and verts[2] or verts[i + 1]
        local frst = verts[i]
        table.insert(triangles, mid)
        table.insert(triangles, snd)
        table.insert(triangles, frst)
        
        -- uv calculation done dividing in actual radius 
        -- plus centering to mid of image (0.5 in this case)
        local uvMid = mid / (r)
        uvMid.x = uvMid.x + .5
        uvMid.y = uvMid.y + .5
         
        local uvSnd = snd / (r)
        uvSnd.x = uvSnd.x + .5
        uvSnd.y = uvSnd.y + .5
        
        local uvFrst = frst / (r)
        uvFrst.x = uvFrst.x + .5
        uvFrst.y = uvFrst.y + .5
        
        -- insert in same clockwise manner
        table.insert(uv, uvMid)
        table.insert(uv, uvSnd)
        table.insert(uv, uvFrst)
    end
    
    -- set data on mesh
    radMesh.vertices = triangles
    radMesh.texCoords = uv
    radMesh.texture = self.img
    -- set white tint, to keep real colors of sprite
    radMesh:setColors(255,255,255,255)
    
    return radMesh
end

function RadSprt:update()
    
end

function RadSprt:draw()
    self:update()
    pushMatrix()
    pushStyle()
    translate(self.x, self.y)
    self.mesh:draw()
    if self.debug then
         fill(255, 14, 0)
        for _,p in ipairs(self.mesh.vertices) do
            ellipse(p.x, p.y, 5)
        end
    end
    popMatrix()
    popStyle()
end

