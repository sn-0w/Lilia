﻿netstream.Hook("RequestPlayxURL", function() Derma_StringRequest("Izzies Palace", "Input a URL that is compatible with PlayX...", "Media URL...", function(url) netstream.Start("MediaRequest", url) end) end)