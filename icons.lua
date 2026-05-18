local M = {}

function M.newPlus(group, x, y, size, color)
    local g = display.newGroup()
    group:insert(g)
    g.x, g.y = x, y
    
    local thickness = size * 0.2
    local r1 = display.newRect(g, 0, 0, size, thickness)
    local r2 = display.newRect(g, 0, 0, thickness, size)
    
    r1:setFillColor(unpack(color or {0, 0, 0}))
    r2:setFillColor(unpack(color or {0, 0, 0}))
    
    return g
end

function M.newMinus(group, x, y, size, color)
    local g = display.newGroup()
    group:insert(g)
    g.x, g.y = x, y
    
    local thickness = size * 0.2
    local r1 = display.newRect(g, 0, 0, size, thickness)
    
    r1:setFillColor(unpack(color or {0, 0, 0}))
    
    return g
end

function M.newBack(group, x, y, size, color)
    local g = display.newGroup()
    group:insert(g)
    g.x, g.y = x, y
    
    local thickness = size * 0.15
    local line1 = display.newRect(g, -size*0.1, 0, size*0.8, thickness)
    
    local arrow = display.newPolygon(g, -size*0.4, 0, {
        0, -size*0.4,
        -size*0.4, 0,
        0, size*0.4
    })
    
    line1:setFillColor(unpack(color or {0, 0, 0}))
    arrow:setFillColor(unpack(color or {0, 0, 0}))
    
    return g
end

function M.newRemove(group, x, y, size, color)
    local g = display.newGroup()
    group:insert(g)
    g.x, g.y = x, y
    
    local thickness = size * 0.2
    local r1 = display.newRect(g, 0, 0, size, thickness)
    r1.rotation = 45
    local r2 = display.newRect(g, 0, 0, size, thickness)
    r2.rotation = -45
    
    r1:setFillColor(unpack(color or {0, 0, 0}))
    r2:setFillColor(unpack(color or {0, 0, 0}))
    
    return g
end

function M.newCheck(group, x, y, size, color)
    local g = display.newGroup()
    group:insert(g)
    g.x, g.y = x, y
    
    local thickness = size * 0.2
    -- Checkmark path
    local line1 = display.newRect(g, -size*0.2, size*0.2, size*0.5, thickness)
    line1.rotation = 45
    local line2 = display.newRect(g, size*0.15, 0, size*0.8, thickness)
    line2.rotation = -45
    
    line1:setFillColor(unpack(color or {0, 0, 0}))
    line2:setFillColor(unpack(color or {0, 0, 0}))
    
    return g
end

return M
