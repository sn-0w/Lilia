﻿function ChatboxCore:SaveData()
    self:setData(self.OOCBans)
end

function ChatboxCore:LoadData()
    self.OOCBans = self:getData()
end

function ChatboxCore:InitializedModules()
    SetGlobalBool("oocblocked", false)
end
