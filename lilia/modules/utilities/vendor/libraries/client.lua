﻿function MODULE:VendorOpened(_)
    vgui.Create("Vendor")
    hook.Run("OnOpenVendorMenu", self)
end

function MODULE:VendorExited()
    if IsValid(lia.gui.vendor) then lia.gui.vendor:Remove() end
end
