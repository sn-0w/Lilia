﻿
local playerMeta = FindMetaTable("Entity")

function playerMeta:getParts()
    return self:getNetVar("parts", {})
end

