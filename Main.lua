-- AxisPad


function setup()
    --print(MOVING, CHANGED)
    axisPad = AxisPad{}
    -- axisPad.bodyColor = color(213, 34, 70)
    -- axisPad.edgeColor = color(255)
    -- axisPad.img = nil
    parameter.boolean('smoothResults', false, function(bool)
        axisPad.smoothResults = bool
    end)
    parameter.boolean('clipRange', false, function(bool)
        axisPad.clipRange = bool
    end)
    parameter.color('bodyColor', axisPad.bodyColor, function(col)
        axisPad.bodyColor = col
    end)
    parameter.color('edgeColor', axisPad.edgeColor, function(col)
        axisPad.edgeColor = col
    end)
    parameter.action('apply changes',function() 
        axisPad.img = nil
        sprt = nil
    end)
    parameter.watch('axisPad.angle')
end

function update()
    if sprt == nil then
        sprt = axisPad:createSprite()
    end
end

function draw()
    update()
    -- set background
    background(40, 40, 50)
    -- show current sprite and axis values in mid of screen
    pushMatrix() pushStyle()
    translate(WIDTH // 2 , HEIGHT // 2)
    local x, y = axisPad:getXY()
    text('x: ' .. x)
    text('y: ' .. y, 0, -20)
    translate(0, axisPad.r)
    sprite(sprt)
    popMatrix() popStyle()
    
    -- draw pad
    axisPad:draw()
    
end

function touched(touch)
    axisPad:touched(touch)
end
