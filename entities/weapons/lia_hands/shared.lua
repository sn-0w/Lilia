CARRY_STRENGTH_NERD = 1
CARRY_STRENGTH_CHAD = 2
CARRY_STRENGTH_TERMINATOR = 3
CARRY_STRENGTH_GOD = 4
CARRY_FORCE_LEVEL = {16500, 40000, 100000, 0,}
CARRY_WEIGHT_LIMIT = 100
THROW_VELOCITY_CAP = 150
PLAYER_PICKUP_RANGE = 200
CARRY_FORCE_LIMIT = CARRY_FORCE_LEVEL[CARRY_STRENGTH_CHAD] -- default strength level is CHAD.
--------------------------------------------------------------------------------------------------------
SWEP.Author = "Cheesenut / Black Tea"
SWEP.Instructions = "Primary Fire: [RAISED] Punch\nSecondary Fire: Knock/Pickup"
SWEP.Purpose = "Hitting things and knocking on doors."
SWEP.Drop = false
SWEP.ViewModelFOV = 45
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "rpg"
SWEP.ViewTranslation = 4
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Primary.Damage = 5
SWEP.Primary.Delay = 0.75
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
SWEP.ViewModel = Model("models/weapons/c_arms_cstrike.mdl")
SWEP.WorldModel = ""
SWEP.UseHands = false
SWEP.LowerAngles = Angle(0, 5, -14)
SWEP.LowerAngles2 = Angle(0, 5, -22)
SWEP.FireWhenLowered = true
SWEP.HoldType = "fist"
SWEP.holdingEntity = nil
SWEP.carryHack = nil
SWEP.constr = nil
SWEP.prevOwner = nil
--------------------------------------------------------------------------------------------------------
--[[
	CARRY_STRENGTH_NERD: 16500 - You can't push player with prop on this strength level.
								the grabbing fails kinda often. the most minge safe strength.
	CARRY_STRENGTH_CHAD: 40000 - You might push player with prop on this strength level.
								the grabbing barley fails.
	CARRY_STRENGTH_TERMINATOR:100000 - You can push player with prop on this strength level.
								the grabbing fail is almost non-existent.
								the the strength is too high, players might able to kill other players
								with prop pushing.
	CARRY_STRENGTH_GOD: 0 - You can push player with prop on this strength levle.
							the grabbing never fails.
							Try this if you're playing with very trustful community.
]]
--
--------------------------------------------------------------------------------------------------------
function SWEP:SetSubPhysMotionEnabled(entity, enable)
    if not IsValid(entity) then return end
    for i = 0, entity:GetPhysicsObjectCount() - 1 do
        local subphys = entity:GetPhysicsObjectNum(i)
        if IsValid(subphys) then
            subphys:EnableMotion(enable)
            if enable then
                subphys:Wake()
            end
        end
    end
end

--------------------------------------------------------------------------------------------------------
function SWEP:removeVelocity(entity, normalize)
    if normalize then
        local phys = entity:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetVelocity(Vector(0, 0, 0))
        end

        entity:SetVelocity(vector_origin)
        self:SetSubPhysMotionEnabled(entity, false)
        timer.Simple(
            0,
            function()
                self:SetSubPhysMotionEnabled(entity, true)
            end
        )
    else
        local phys = entity:GetPhysicsObject()
        local vel = IsValid(phys) and phys:GetVelocity() or entity:GetVelocity()
        local len = math.min(THROW_VELOCITY_CAP, vel:Length2D())
        vel:Normalize()
        vel = vel * len
        self:SetSubPhysMotionEnabled(entity, false)
        timer.Simple(
            0,
            function()
                self:SetSubPhysMotionEnabled(entity, true)
                if IsValid(phys) then
                    phys:SetVelocity(vel)
                end

                entity:SetVelocity(vel)
                entity:SetLocalAngularVelocity(Angle())
            end
        )
    end
end

--------------------------------------------------------------------------------------------------------
function SWEP:throwVelocity(entity, client, power)
    local phys = entity:GetPhysicsObject()
    local vel = client:GetAimVector()
    vel = vel * power
    self:SetSubPhysMotionEnabled(entity, false)
    timer.Simple(
        0,
        function()
            if IsValid(entity) then
                self:SetSubPhysMotionEnabled(entity, true)
                if IsValid(phys) then
                    phys:SetVelocity(vel)
                end

                entity:SetVelocity(vel)
                entity:SetLocalAngularVelocity(Angle())
            end
        end
    )
end

--------------------------------------------------------------------------------------------------------
function SWEP:reset(throw)
    if IsValid(self.carryHack) then
        self.carryHack:Remove()
    end

    if IsValid(self.constr) then
        self.constr:Remove()
    end

    if IsValid(self.holdingEntity) then
        local owner = self:GetOwner()
        if not self.holdingEntity:IsWeapon() then
            if not IsValid(self.prevOwner) then
                self.holdingEntity:SetOwner(nil)
            else
                self.holdingEntity:SetOwner(self.prevOwner)
            end
        end

        local phys = self.holdingEntity:GetPhysicsObject()
        if IsValid(phys) then
            phys:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
            phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
            phys:EnableCollisions(true)
            phys:EnableGravity(true)
            phys:EnableDrag(true)
            phys:EnableMotion(true)
        end

        if not throw then
            self:removeVelocity(self.holdingEntity)
        else
            self:throwVelocity(self.holdingEntity, owner, 300)
        end

        hook.Run("GravGunOnDropped", owner, self.holdingEntity, throw)
    end

    self.dt.carried_rag = nil
    self:SetNW2Bool("holdingObject", nil)
    self.holdingEntity = nil
    self.carryHack = nil
    self.constr = nil
end

--------------------------------------------------------------------------------------------------------
function SWEP:drop(throw)
    if not self:checkValidity() then return end
    if not self:allowEntityDrop() then return end
    if SERVER then
        self.constr:Remove()
        self.carryHack:Remove()
        local entity = self.holdingEntity
        local phys = entity:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableCollisions(true)
            phys:EnableGravity(true)
            phys:EnableDrag(true)
            phys:EnableMotion(true)
            phys:Wake()
            phys:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
            phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
        end

        if entity:GetClass() == "prop_ragdoll" then
            self:removeVelocity(entity)
        end

        entity:SetPhysicsAttacker(self:GetOwner())
    end

    self:reset(throw)
end

--------------------------------------------------------------------------------------------------------
function SWEP:checkValidity()
    if (not IsValid(self.holdingEntity)) or (not IsValid(self.carryHack)) or (not IsValid(self.constr)) then
        if self.holdingEntity or self.carryHack or self.constr then
            self:reset()
        end

        return false
    else
        return true
    end
end

--------------------------------------------------------------------------------------------------------
function SWEP:isPlayerStandsOn(entity)
    for _, client in pairs(player.GetAll()) do
        if client:GetGroundEntity() == entity then return true end
    end

    return false
end

--------------------------------------------------------------------------------------------------------
function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end
    local owner = self:GetOwner()
    if IsValid(self.holdingEntity) then
        self:doPickup(not self.isWepRaised or owner:isWepRaised())

        return
    end

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    if hook.Run("CanPlayerThrowPunch", owner) == false then return end
    local staminaUse = lia.config.PunchStamina
    if staminaUse > 0 then
        local value = owner:getLocalVar("stamina", 0) - staminaUse
        if value < 0 then
            return
        elseif SERVER then
            owner:setLocalVar("stm", value)
        end
    end

    if SERVER then
        owner:EmitSound("npc/vort/claw_swing" .. math.random(1, 2) .. ".wav")
    end

    self:doPunchAnimation()
    owner:SetAnimation(PLAYER_ATTACK1)
    owner:ViewPunch(Angle(self.LastHand + 2, self.LastHand + 5, 0.125))
    self:SetNW2Float("startTime", CurTime())
    self:SetNW2Bool("startPunch", true)
end

--------------------------------------------------------------------------------------------------------
function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end
    local client = self:GetOwner()
    local entity = client:GetTracedEntity()
    if SERVER and IsValid(entity) then
        if entity:isDoor() then
            if hook.Run("PlayerCanKnock", client, entity) == false then return end
            client:ViewPunch(Angle(-1.3, 1.8, 0))
            client:EmitSound("physics/wood/wood_crate_impact_hard" .. math.random(2, 3) .. ".wav")
            client:SetAnimation(PLAYER_ATTACK1)
            self:doPunchAnimation()
            self:SetNextSecondaryFire(CurTime() + 0.4)
            self:SetNextPrimaryFire(CurTime() + 1)
        elseif not entity:IsPlayer() and not entity:IsNPC() then
            self:doPickup(false, entity, client:GetTrace())
        elseif IsValid(self.heldEntity) and not self.heldEntity:IsPlayerHolding() then
            self.heldEntity = nil
        end
    else
        if IsValid(self.holdingEntity) then
            self:doPickup(false, nil, client:GetTrace())
        end
    end
end

--------------------------------------------------------------------------------------------------------
function SWEP:dragObject(phys, targetpos)
    if not IsValid(phys) then return end
    local owner = self:GetOwner()
    local point = owner:GetShootPos() + owner:GetAimVector() * 50
    local physDirection = targetpos - point
    local length = physDirection:Length2D()
    physDirection:Normalize()
    phys:SetVelocity(physDirection * math.min(length, 250))
end

--------------------------------------------------------------------------------------------------------
function SWEP:getRange(target)
    if IsValid(target) and target:GetClass() == "prop_ragdoll" then
        return 75
    else
        return 100
    end
end

--------------------------------------------------------------------------------------------------------
function SWEP:allowPickup(target)
    local phys = target:GetPhysicsObject()
    local client = self:GetOwner()

    return IsValid(phys) and IsValid(client) and client:getChar() and (not phys:HasGameFlag(FVPHYSICS_NO_PLAYER_PICKUP)) and phys:GetMass() <= CARRY_WEIGHT_LIMIT and (not self:isPlayerStandsOn(target)) and (target.CanPickup ~= false) and hook.Run("GravGunPickupAllowed", client, target) ~= false and (target.GravGunPickupAllowed and (target:GravGunPickupAllowed(client) ~= false) or true)
end

--------------------------------------------------------------------------------------------------------
function SWEP:doPickup(throw, entity, trace)
    self:SetNextPrimaryFire(CurTime() + .1)
    self:SetNextSecondaryFire(CurTime() + .1)
    if IsValid(self.holdingEntity) then
        self:drop(throw)
        self:SetNextSecondaryFire(CurTime() + 0.1)

        return
    end

    local client = self:GetOwner()
    if IsValid(entity) then
        local phys = entity:GetPhysicsObject()
        if not IsValid(phys) or not phys:IsMoveable() or phys:HasGameFlag(FVPHYSICS_PLAYER_HELD) then
            hook.Run("OnPickupObject", false, client, entity)

            return
        end

        if SERVER and (client:EyePos() - (entity:GetPos() + entity:OBBCenter())):Length() < self:getRange(entity) and self:allowPickup(entity) then
            self:pickup(entity, trace)
            self:SendWeaponAnim(ACT_VM_HITCENTER)
            local delay = (entity:GetClass() == "prop_ragdoll") and 0.8 or 0.1
            hook.Run("OnPickupObject", true, client, entity)
            self:SetNextSecondaryFire(CurTime() + delay)

            return
        end
    end
end

--------------------------------------------------------------------------------------------------------
function SWEP:pickup(entity, trace)
    if CLIENT or IsValid(self.holdingEntity) then return end
    local client = self:GetOwner()
    self.holdingEntity = entity
    local entphys = entity:GetPhysicsObject()
    if IsValid(entity) and IsValid(entphys) then
        self.carryHack = ents.Create("prop_physics")
        if IsValid(self.carryHack) then
            local pos, obb = self.holdingEntity:GetPos(), self.holdingEntity:OBBCenter()
            pos = pos + self.holdingEntity:GetForward() * obb.x
            pos = pos + self.holdingEntity:GetRight() * obb.y
            pos = pos + self.holdingEntity:GetUp() * obb.z
            self.carryHack:SetPos(pos)
            self.carryHack:SetModel("models/weapons/w_bugbait.mdl")
            self.carryHack:SetColor(Color(50, 250, 50, 240))
            self.carryHack:SetNoDraw(true)
            self.carryHack:DrawShadow(false)
            self.carryHack:SetHealth(999)
            self.carryHack:SetOwner(client)
            self.carryHack:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
            self.carryHack:SetSolid(SOLID_NONE)
            local preferredAngles = hook.Run("GetPreferredCarryAngles", self.holdingEntity)
            if client:KeyDown(IN_RELOAD) and not preferredAngles then
                preferredAngles = Angle()
            end

            if preferredAngles then
                local entAngle = self.holdingEntity:GetAngles()
                self.carryHack.preferedAngle = self.holdingEntity:GetAngles()
                local grabAngle = self.holdingEntity:GetAngles()
                grabAngle:RotateAroundAxis(entAngle:Right(), preferredAngles[1]) -- pitch
                grabAngle:RotateAroundAxis(entAngle:Up(), preferredAngles[2]) -- yaw
                grabAngle:RotateAroundAxis(entAngle:Forward(), preferredAngles[3]) -- roll
                self.carryHack:SetAngles(grabAngle)
            else
                self.carryHack:SetAngles(client:GetAngles())
            end

            self.carryHack:Spawn()
            if not self.holdingEntity:IsWeapon() then
                self.prevOwner = self.holdingEntity:GetOwner()
                self.holdingEntity:SetOwner(client)
            end

            local phys = self.carryHack:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetMass(200)
                phys:SetDamping(0, 1000)
                phys:EnableGravity(false)
                phys:EnableCollisions(false)
                phys:EnableMotion(false)
                phys:AddGameFlag(FVPHYSICS_PLAYER_HELD)
            end

            entphys:AddGameFlag(FVPHYSICS_PLAYER_HELD)
            local bone = math.Clamp(0, 0, 1)
            local max_force = CARRY_FORCE_LIMIT
            if entity:GetClass() == "prop_ragdoll" then
                self.dt.carried_rag = entity
                bone = trace.PhysicsBone
                max_force = 0
            else
                self.dt.carried_rag = nil
            end

            self:SetNW2Bool("holdingObject", true)
            self.constr = constraint.Weld(self.carryHack, self.holdingEntity, 0, bone, max_force, true)
            client:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 3) .. ".wav", 75)
            hook.Run("GravGunOnPickedUp", client, self.holdingEntity)
        end
    end
end

--------------------------------------------------------------------------------------------------------
local down = Vector(0, 0, -1)
--------------------------------------------------------------------------------------------------------
function SWEP:allowEntityDrop()
    local client = self:GetOwner()
    local ent = self.carryHack
    if (not IsValid(client)) or (not IsValid(ent)) then return false end
    local ground = client:GetGroundEntity()
    if ground and (ground:IsWorld() or IsValid(ground)) then return true end
    local diff = (ent:GetPos() - client:GetShootPos()):GetNormalized()

    return down:Dot(diff) <= 0.75
end

--------------------------------------------------------------------------------------------------------
function SWEP:SetupDataTables()
    self:DTVar("Entity", 0, "carried_rag")
end

--------------------------------------------------------------------------------------------------------
function SWEP:Initialize()
    if SERVER then
        self.dt.carried_rag = nil
    end

    self:SetHoldType(self.HoldType)
    self.LastHand = 0
end

--------------------------------------------------------------------------------------------------------
function SWEP:OnRemove()
    self:reset()
end

--------------------------------------------------------------------------------------------------------
ACT_VM_FISTS_DRAW = 3
ACT_VM_FISTS_HOLSTER = 2
--------------------------------------------------------------------------------------------------------
function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    self:reset()
    local viewModel = owner:GetViewModel()
    if IsValid(viewModel) then
        viewModel:SetPlaybackRate(1)
        viewModel:ResetSequence(ACT_VM_FISTS_DRAW)
    end

    return true
end

--------------------------------------------------------------------------------------------------------
function SWEP:Holster()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    self:reset()
    local viewModel = owner:GetViewModel()
    if IsValid(viewModel) then
        viewModel:SetPlaybackRate(1)
        viewModel:ResetSequence(ACT_VM_FISTS_HOLSTER)
    end

    return true
end

--------------------------------------------------------------------------------------------------------
function SWEP:Precache()
    util.PrecacheSound("npc/vort/claw_swing1.wav")
    util.PrecacheSound("npc/vort/claw_swing2.wav")
    util.PrecacheSound("physics/plastic/plastic_box_impact_hard1.wav")
    util.PrecacheSound("physics/plastic/plastic_box_impact_hard2.wav")
    util.PrecacheSound("physics/plastic/plastic_box_impact_hard3.wav")
    util.PrecacheSound("physics/plastic/plastic_box_impact_hard4.wav")
    util.PrecacheSound("physics/wood/wood_crate_impact_hard2.wav")
    util.PrecacheSound("physics/wood/wood_crate_impact_hard3.wav")
end

--------------------------------------------------------------------------------------------------------
function SWEP:doPunchAnimation()
    self.LastHand = math.abs(1 - self.LastHand)
    local sequence = 4 + self.LastHand
    local viewModel = self:GetOwner():GetViewModel()
    if IsValid(viewModel) then
        viewModel:SetPlaybackRate(0.5)
        viewModel:SetSequence(sequence)
    end

    if self:GetNW2Bool("startPunch", false) and (CurTime() > self:GetNW2Float("startTime", CurTime()) + 0.055) then
        self:doPunch()
        self:SetNW2Bool("startPunch", false)
        self:SetNW2Float("startTime", 0)
    end
end

--------------------------------------------------------------------------------------------------------
function SWEP:doPunch()
    local owner = self:GetOwner()
    if IsValid(self) and IsValid(owner) then
        local damage = self.Primary.Damage
        local context = {
            damage = damage
        }

        local result = hook.Run("PlayerGetFistDamage", owner, damage, context)
        if result ~= nil then
            damage = result
        else
            damage = context.damage
        end

        owner:LagCompensation(true)
        local data = {}
        data.start = owner:GetShootPos()
        data.endpos = data.start + owner:GetAimVector() * 96
        data.filter = owner
        local trace = util.TraceLine(data)
        if SERVER and trace.Hit then
            local entity = owner:GetTracedEntity()
            if IsValid(entity) then
                local damageInfo = DamageInfo()
                damageInfo:SetAttacker(owner)
                damageInfo:SetInflictor(self)
                damageInfo:SetDamage(damage)
                damageInfo:SetDamageType(DMG_SLASH)
                damageInfo:SetDamagePosition(trace.HitPos)
                damageInfo:SetDamageForce(owner:GetAimVector() * 10000)
                entity:DispatchTraceAttack(damageInfo, data.start, data.endpos)
                owner:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", 80)
            end
        end

        hook.Run("PlayerThrowPunch", owner, trace)
        owner:LagCompensation(false)
    end
end
--------------------------------------------------------------------------------------------------------