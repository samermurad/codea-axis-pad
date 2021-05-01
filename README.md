# AxisPad

Simple Touch pad for Codea.


![Example](https://github.com/samermurad/codea-axis-pad/blob/9a33152c68faf98ad6713c6c538c62379b248234/example.jpeg)


### Usage

```lua

function setup()
    axisPad = AxisPad{}
end

function draw()
    — float values ranging from -1 to 1, stepped by 0.1
    local x = axisPad:getX()
    local y = axisPad:getY()
    x, y = axisPad:getXY()

    axisPad:draw()
end

—- optional, otherwise import the Codea “Touches” project
function touched(touch)
    axisPad:touched(touch)
end

```


### Customization

In order to be a bit more performant, the AxisPad creates a small sprite from it’s values and saves it locally, the sprite is later used for both body and the thumb.

So after setting the axisPad.bodyColor and axisPad.edgeColor, you’ll need to set the axisPad.img to nil so a new sprite will be generated on next frame
