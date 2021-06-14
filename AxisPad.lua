AxisPad = class()

function AxisPad:init(opt)
    opt = opt or {}
    local useTouches = opt.useTouches ~= nil and opt.useTouches or true
    self.touchStart = vec2(0,0)
    self.touchMoved = vec2(0,0)
    self.touchDis = vec2(0,0)
    self.range = opt.range or 28
    self.threshold = 0.5
    self.bodyColor = opt.bodyColor or color(59)
    self.edgeColor = opt.edgeColor or color(207, 241, 44)
    self.x, self.y = 0,0
    self.r = opt.r or 85
    self.innerR = opt.innerR or 65
    self.sprtPath = opt.sprtPath or ( asset .. 'padd_sheet.png' )
    self.clipRange = opt.clipRange or true
    self.smoothResults = opt.smoothResults or false
    self.img = nil
    self.baseMesh = nil
    self.thumbMesh = nil


    if touches and useTouches then touches.addHandler(self, 0, false) end
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
    local dim = color(self.bodyColor.r, self.bodyColor.g, self.bodyColor.b, self.bodyColor.a)
    
    fill(self.bodyColor)
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
    saveImage(self.sprtPath, img)

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

-- might be null
function AxisPad:getAngle()
    return self.angle
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
    if touch.id == self.touchId and touch.pos ~= nil then
        local n = (touch.pos - self.touchStart)

        local x = touch.pos.x - self.touchStart.x
        local y = touch.pos.y - self.touchStart.y

        
        local angle = math.atan2(n.y, n.x)
        self.angle = angle

        
        local maxX = math.abs(math.cos(angle) * (self.range))
        local maxY = math.abs(math.sin(angle) * (self.range))
        local clippingX = self.range
        local clippingY = self.range
        
        if self.clipRange then
            clippingX = maxX
            clippingY = maxY
        end
        
        local factorX = self.range
        local factorY = self.range

        x = clamp(x, -clippingX, clippingX)
        y = clamp(y, -clippingY, clippingY)

        self.touchMoved = vec2(x, y)
        self.x = self.smoothResults and smoothOut(x / (factorX), 0.001) or (x / (factorX))
        self.y = self.smoothResults and smoothOut(y / (factorY), 0.001) or (y / (factorY))
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
        self.angle = nil
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
