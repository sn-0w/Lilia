﻿function VCModCompatibility:VC_canAddMoney(client, amount)
    client:getChar():giveMoney(amount)
    return false
end

function VCModCompatibility:VC_canRemoveMoney(client, amount)
    client:getChar():takeMoney(amount)
    return false
end
