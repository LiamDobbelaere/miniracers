AddCSLuaFile()

ENT.PrintName = "Miniracer Test"
ENT.Author = "Digaly"
ENT.Information = "Movement keys = control, E = change camera, R = reset"
ENT.Category = "Miniracers"

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Editable = true
ENT.Spawnable = false
ENT.AdminOnly = false

properties.Add("mrcarai", {
    Type = "toggle",
	MenuLabel = "AI driver", -- Name to display on the context menu
	Order = 999, -- The order to display this property relative to other properties
	MenuIcon = "icon16/computer.png", -- The icon to display next to the property

	Filter = function(self, ent, ply) -- A function that determines whether an entity is valid for this property
		if (!IsValid(ent)) then return false end
        if (not string.match(ent:GetClass(), "sent_miniracer")) then return false end
		if (!gamemode.Call("CanProperty", ply, "mrai", ent)) then return false end

		return true
    end,
    Checked = function(self, ent, tr)
        return ent:GetAI()
    end,
	Action = function(self, ent) -- The action to perform upon using the property (Clientside)
		self:MsgStart()
			net.WriteEntity(ent)
		self:MsgEnd()
	end,
	Receive = function(self, length, player) -- The action to perform upon using the property (Serverside)
		local ent = net.ReadEntity()
		if (!self:Filter(ent, player)) then return end
        
        ent:SetAI(!ent:GetAI())
        
        if ent:GetAI() then
            ent:AIInit()
            ent:SetRandomName()
        else
            ent:SetOwnerName(ent:GetCreator():Name())
        end
	end 
})

properties.Add("mrcaraiwait", {
    Type = "toggle",
	MenuLabel = "AI waits for race", -- Name to display on the context menu
	Order = 999, -- The order to display this property relative to other properties
	MenuIcon = "icon16/flag_yellow.png", -- The icon to display next to the property

	Filter = function(self, ent, ply) -- A function that determines whether an entity is valid for this property
		if (!IsValid(ent)) then return false end
        if (not string.match(ent:GetClass(), "sent_miniracer")) then return false end
		if (!gamemode.Call("CanProperty", ply, "mrai", ent)) then return false end

		return true
    end,
    Checked = function(self, ent, tr)
        return ent:GetAIWaitForRace()
    end,
	Action = function(self, ent) -- The action to perform upon using the property (Clientside)
		self:MsgStart()
			net.WriteEntity(ent)
		self:MsgEnd()
	end,
	Receive = function(self, length, player) -- The action to perform upon using the property (Serverside)
		local ent = net.ReadEntity()
		if (!self:Filter(ent, player)) then return end
        
        ent:SetAIWaitForRace(!ent:GetAIWaitForRace())        
	end 
})

function ENT:SpawnFunction(ply, tr, ClassName)
    if not tr.Hit then return end

    local ent = ents.Create(ClassName)
    ent:SetPos(tr.HitPos + tr.HitNormal * 25)
    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:Initialize()
    if (CLIENT) then return end

    self.engineSound = CreateSound(self, "ambient/energy/electric_loop.wav")
    self.engineSound:Play()

    self:SetModel(self:GetMRModel())
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    self.stats = self:GetMRStats()
    
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then 
        phys:Wake() 
        phys:EnableDrag(false)
        --phys:EnableGravity(false)
        phys:SetDamping(1 - self.stats.drift, 0)
        phys:SetAngleDragCoefficient(0)
    end

    self.thinkOnce = false

    self.cam = ents.Create("sent_mrcamera")
    self.cam.target = self;
    self.cam:SetPos(self:GetPos())
    self.cam:Spawn()
    self.cam:Activate()
    self:SetMrCamera(self.cam)

    self.keyCamPressed = false
    self.keyResetPressed = false

    self.softImpactSounds = { 
        "miniracers/mrimpact_soft.wav",
        "miniracers/mrimpact_soft2.wav",
        "miniracers/mrimpact_soft3.wav",
        "miniracers/mrimpact_soft4.wav"
    }
    self.hardImpactSounds = {
        "miniracers/mrimpact_hard.wav",
        "miniracers/mrimpact_hard2.wav",
        "miniracers/mrimpact_hard3.wav",
        "miniracers/mrimpact_hard4.wav",
        "miniracers/mrimpact_hard5.wav"
    }

    self:SetAI(false)
    self:AIInit()
end 

function ENT:AIInit()
    self.markers = ents.FindByClass("sent_mraiwaypoint")
    self.markerMemory = {}
    self.startingMarker = nil
    self:AINextMarker()
end

function ENT:GetMRModel()
    return "models/Gibs/HGIBS.mdl"
end

function ENT:GetMRStats()
    return {
        acceleration = 1000,
        steer = 15000,
        drift = 1,
        pitchMin = 50,
        pitchBase = 80,
        pitchVelocityMultiplier = 1
    }
end

function ENT:OnRemove()
    if (CLIENT) then return end

    self.engineSound:Stop()

    if IsValid(self.cam) then
        self.cam:Remove()
    end

    if IsValid(self:GetCreator()) then
        self:GetCreator():SetViewEntity(NULL)
    end
end

function ENT:PhysicsCollide(colData, collider)
    if colData.Speed > 200 then
        self:EmitSound(self.hardImpactSounds[math.random(1,#self.hardImpactSounds)], math.random(50, 75), math.random(90, 120))
    elseif colData.Speed > 40 then
        self:EmitSound(self.softImpactSounds[math.random(1,#self.softImpactSounds)], math.random(50, 75), math.random(90, 120))
    end
end

function ENT:SetRandomName()
    local names = {
        "[COM] The Spy",
        "[COM] Car goes BRRRR",
        "[COM] Max Damage",
        "[COM] Gotta go fast",
        "[COM] I am speed",
        "[COM] Sonic",
        "[COM] Crispy",
        "[COM] Strider",
        "[COM] Chopper",
        "[COM] Wheeli Vance",
        "[COM] Vomitboy"
    }

    self:SetOwnerName(names[math.random(1,#names)])
end

function ENT:Think()
    if (CLIENT) then return end
    
    if not IsValid(self:GetCreator()) then
        return
    end

    local forwardNoUp = Vector(self:GetForward().x, 0, self:GetForward().z) 

    if not self.thinkOnce then
        if self:GetAI() then
            self:SetRandomName()
        else
            self:SetOwnerName(self:GetCreator():Name())
        end


        self.cam.player = self:GetCreator()
        self.cam:InitializeMode()
        self.thinkOnce = true
    end

    local owner = self:GetCreator()

    local inputForward, inputReverse, inputLeft, inputRight, inputCam, inputReset

    if self:GetAI() then
        local inputs = self:AIThink()

        inputForward = inputs["inputForward"]
        inputReverse = inputs["inputReverse"]
        inputLeft = inputs["inputLeft"]
        inputRight = inputs["inputRight"]
        inputCam = inputs["inputCam"]
        inputReset = inputs["inputReset"]
    else
        inputForward = owner:KeyDown(IN_FORWARD)
        inputReverse = owner:KeyDown(IN_BACK)
        inputLeft = owner:KeyDown(IN_MOVELEFT)
        inputRight = owner:KeyDown(IN_MOVERIGHT)
        inputCam = owner:KeyDown(IN_USE)
        inputReset = owner:KeyDown(IN_RELOAD)
    end

    -- Camera switching
    if inputCam && not self.keyCamPressed then
        if not self:IsPlayerHolding() then
            self.cam:NextMode()
        end

        self.keyCamPressed = true
    end

    if not inputCam && self.keyCamPressed then
        self.keyCamPressed = false
    end

    -- Car resetting
    if inputReset && not self.keyResetPressed then
        local currentAngles = self:GetAngles()
        self:SetAngles(Angle(0, currentAngles.y, 0))

        self.keyResetPressed = true
    end

    if not inputReset && self.keyResetPressed then
        self.keyResetPressed = false
    end

    local phy = self:GetPhysicsObject()

    self.cam.distance = phy:GetVelocity():Length() * 0.5 + 150
    
    if inputForward || inputReverse then
        self.engineSound:ChangePitch(self.stats.pitchBase + phy:GetVelocity():Length() * self.stats.pitchVelocityMultiplier, 0.2)
        self.engineSound:ChangeVolume(1, 0.2)
    else
        self.engineSound:ChangePitch(self.stats.pitchMin, 0.5)
        self.engineSound:ChangeVolume(0, 0.2)
    end

    -- Help with going up slopes
    local slopeAdjust = 0
    if self:GetAngles().x < 0 then
        slopeAdjust = self:GetAngles().x * -40
    end

    local accForce = self.stats.acceleration + slopeAdjust
    if (inputForward) then
        phy:ApplyForceCenter(self:GetForward() * accForce * FrameTime())
    elseif (inputReverse) then
        phy:ApplyForceCenter(self:GetForward() * accForce * -0.5 * FrameTime())
    else
        phy:SetVelocity(phy:GetVelocity() * 0.98)
    end

    local avForce = self.stats.steer
    if (inputLeft) then
        phy:AddAngleVelocity(-phy:GetAngleVelocity() + Vector(0, 0, avForce * FrameTime()))
    elseif (inputRight) then
        phy:AddAngleVelocity(-phy:GetAngleVelocity() + Vector(0, 0, -avForce * FrameTime()))
    else
        phy:AddAngleVelocity(-phy:GetAngleVelocity())
    end

    self:NextThink(CurTime())

	return true
end

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "OwnerName")
    self:NetworkVar("Bool", 0, "AI")
    self:NetworkVar("Bool", 1, "AIWaitForRace")
    self:NetworkVar("Entity", 0, "MrCamera")

    if SERVER then
        self:SetAIWaitForRace(false)
    end
end

function ENT:Draw3DText(pos, ang, scale, text, flipView)
	if (flipView) then
		ang:RotateAroundAxis(Vector( 0, 0, 1 ), 180)
	end

    cam.Start3D2D(pos, ang, scale)
        local color = Color(0, 0, 255, 255)
        if self:GetAI() then
            color = Color(255, 0, 0, 255)
        end

		draw.DrawText(text, "DermaLarge", 0, 0, color, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end

function ENT:Draw()
    self:DrawModel()

    if GetViewEntity() == self:GetMrCamera() then
        return
    end

    local playerAngles = LocalPlayer():GetAngles()

    if LocalPlayer():GetActiveWeapon():GetClass() == 'gmod_camera' then
        return
    end

    self:Draw3DText(
        self:GetPos() + Vector(0, 0, 16), 
        Angle(0, GetViewEntity():GetAngles().y + 90, 90),
        0.2, 
        self:GetOwnerName(), 
        true
    )
end

function ENT:IsMemorizedMarker(val)
    for _, v in pairs(self.markerMemory) do
        if v == val then
            return true
        end
    end

    return false
end

function ENT:AINextMarker()
    local closestDistance = -1
    local closest = nil

    if IsValid(self.targetMarker) then
        if #self.markerMemory == 0 then
            self.startingMarker = self.targetMarker
        end
    
        table.insert(self.markerMemory, self.targetMarker)
    end

    if #self.markerMemory > 4 then
        table.remove(self.markerMemory, 1)
    end

    for k, v in pairs(ents.FindByClass("sent_mraiwaypoint")) do
        if not self:IsMemorizedMarker(v) then
            local sqrDist = v:GetPos():DistToSqr(self:GetPos())
            if sqrDist < closestDistance or closestDistance == -1 then
                closest = v
                closestDistance = sqrDist
            end
        end
    end

    self.targetMarker = closest
end

function ENT:AIThink()
    local forward, reverse, left, right, cam, reset
    forward = false
    reverse = false
    left = false
    right = false
    cam = false
    reset = false

    if self:GetAIWaitForRace() then
        return {
            inputForward = forward,
            inputReverse = reverse,
            inputLeft = left,
            inputRight = right,
            inputCam = cam,
            inputReset = reset
        }
    end

    if not IsValid(self.targetMarker) then
        forward = true
        left = true

        self:AINextMarker()
    else
        local vectorToMarker = (self.targetMarker:GetPos() - self:GetPos()):GetNormalized();
        local angleToMarker = self:GetForward():AngleEx(vectorToMarker)
        local distanceToMarker = self:GetPos():DistToSqr(self.targetMarker:GetPos())
    
        if angleToMarker.z > 0 then
            right = true
        else
            left = true
        end
    
        if distanceToMarker > 4096 then
            forward = true
        else
            self:AINextMarker()
        end    
    end

    return {
        inputForward = forward,
        inputReverse = reverse,
        inputLeft = left,
        inputRight = right,
        inputCam = cam,
        inputReset = reset
    }
end