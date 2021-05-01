AxisPad = class()

function AxisPad:init(opt)
    -- you can accept and set parameters here
    opt = opt or {}
    self.touchStart = vec2(0,0)
    self.touchMoved = vec2(0,0)
    self.touchDis = vec2(0,0)
    self.range = opt.range or 25
    self.threshold = 0.5
    self.bodyColor = color(101)
    self.edgeColor = color(241, 166, 44)
    self.x, self.y = 0,0
    self.r = opt.r or 85
    self.innerR = opt.innerR or 65
    
    self.img = nil
    self.baseMesh = nil
    self.thumbMesh = nil
    if touches then touches.addHandler(self, 0, false) end
end

-- Circle Sprite Gen
function AxisPad:circle(w,h)
    pushStyle()

    noFill()
    strokeWidth(1)
    stroke(self.edgeColor)
    fill(self.bodyColor)
    -- outer edge
    ellipse(0,0, w, h)
    strokeWidth(2)
    -- inner edge
    ellipse(0,0, w * .85,h * .85)

    popStyle()
end

function AxisPad:createSprite()
    pushStyle()
    pushMatrix()
    resetStyle()
    resetMatrix()
    local max = math.max(self.r, self.innerR)
    local img = image(max, max)
    setContext(img)
    ellipseMode(CENTER)
    background(0, 0)
    translate(max / 2, max / 2)
    self:circle(self.r, self.r)

    setContext()
    saveImage(asset.documents.AxisPad .. 'padd_sheet.png', img)

    popMatrix()
    popStyle()
    return img
end

-- Rendering Pipeline
function AxisPad:update()
    if self.img == nil then
        self.img = self:createSprite()
        self.baseMesh = RadSprt(self.img, self.r)
        self.thumbMesh = RadSprt(self.img, self.innerR)
    end
    self.baseMesh.x = self.touchStart.x
    self.baseMesh.y = self.touchStart.y
    
    self.thumbMesh.x = self.touchStart.x + self.touchMoved.x
    self.thumbMesh.y = self.touchStart.y + self.touchMoved.y
end

function AxisPad:draw()
    self:update()
    
    pushStyle()
    pushMatrix()
    
    if self.touchId then
     self.baseMesh:draw()
     self.thumbMesh:draw()
    end
    
    popStyle()
    popMatrix()
end

-- Getters
function AxisPad:getX()
    return self.x
end

function AxisPad:getY()
    return self.y
end

function AxisPad:getXY()
    return self.x, self.y
end

function AxisPad:len()
   return vec2(self.x, self.y):len()
end

-- Touches handling
function AxisPad:began(touch)
    if not self.touchId then
        self.touchId = touch.id
        self.touchStart = touch.pos
        self.touchMoved = vec2(0,0)
        return true
    end
    return false
end

function AxisPad:moved(touch)
    if touch.id == self.touchId then
        local n = (touch.pos - self.touchStart)
        
        local x = touch.pos.x - self.touchStart.x
        local y = touch.pos.y - self.touchStart.y
        
        local angle = math.atan2(n.y, n.x)
        local maxX = math.abs(math.cos(angle) * (self.range))
        local maxY = math.abs(math.sin(angle) * (self.range))
        
        x = math.max(-maxX, math.min(maxX, x))
        y = math.max(-maxY, math.min(maxY, y))
        
        self.touchMoved = vec2(x,y) 
        self.x = smoothOut(x / self.range * 2, 0.1)
        self.y = smoothOut(y / self.range * 2, 0.1)
        self.x = clamp(self.x, -1.0, 1.0)
        self.y = clamp(self.y, -1.0, 1.0)
        return true
    end
    return false
end

function AxisPad:ended(touch)
    if touch.id == self.touchId then
        self.touchId = nil
        self.x = 0
        self.y = 0
        return true
    end
    return false
end

function AxisPad:touched(touch)
    if touch.state == BEGAN then
       return self:began(touch)
    elseif touch.state == CHANGED then
       return self:moved(touch)
    elseif touch.state == ENDED or touch.state == CANCELLED then
       return self:ended(touch)
    end
end
