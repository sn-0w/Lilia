﻿
netstream.Hook("ChangeSpeakMode", function(client, mode) client:setNetVar("VoiceType", mode) end)

