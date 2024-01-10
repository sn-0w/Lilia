﻿function VendorCore:VendorOpened(_)
    vgui.Create("liaVendor")
    hook.Run("OnOpenVendorMenu", self)
end

function VendorCore:VendorExited()
    if IsValid(lia.gui.vendor) then lia.gui.vendor:Remove() end
end
