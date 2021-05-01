
RAD_2_DEG = 180 / math.pi
DEG_2_RAD = math.pi / 180

function clamp(val, min, max)
    if type(val) == 'number' then
        return math.max(min, math.min(max, val))
    end
    error(('type ' .. tostring(val) .. ' is not supported'))
end

function smoothOut(exact, quantum)
    local quant,frac = math.modf(exact/quantum)
    local val = quantum * (quant + (frac > 0.5 and 1 or 0))
    return val
end