AddCSLuaFile()

ENT.PrintName = "AI Marker"
ENT.Author = "Digaly"
ENT.Information = "Use this to guide the AI"
ENT.Category = "Miniracers"

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Editable = false
ENT.Spawnable = true
ENT.AdminOnly = false

properties.Add("mraimarkreset", {
	MenuLabel = "Reset to zero", -- Name to display on the context menu
	Order = 999, -- The order to display this property relative to other properties
	MenuIcon = "icon16/arrow_refresh.png", -- The icon to display next to the property

	Filter = function(self, ent, ply) -- A function that determines whether an entity is valid for this property
		if (!IsValid(ent)) then return false end
        if (not string.match(ent:GetClass(), "sent_mraiwaypoint")) then return false end
		if (!gamemode.Call("CanProperty", ply, "mraiwaypointreset", ent)) then return false end

		return true
    end,
	Action = function(self, ent) -- The action to perform upon using the property (Clientside)
		self:MsgStart()
			net.WriteEntity(ent)
		self:MsgEnd()
	end,
	Receive = function(self, length, player) -- The action to perform upon using the property (Serverside)
		local ent = net.ReadEntity()
		if (!self:Filter(ent, player)) then return end
        
        ent:SetMarkerIndex(0)
        player.lastMarkerIndex = 0
	end 
})

properties.Add("mraimarkstart", {
	MenuLabel = "Start from here", -- Name to display on the context menu
	Order = 999, -- The order to display this property relative to other properties
	MenuIcon = "icon16/control_fastforward_blue.png", -- The icon to display next to the property

	Filter = function(self, ent, ply) -- A function that determines whether an entity is valid for this property
		if (!IsValid(ent)) then return false end
        if (not string.match(ent:GetClass(), "sent_mraiwaypoint")) then return false end
		if (!gamemode.Call("CanProperty", ply, "mraiwaypointstart", ent)) then return false end

		return true
    end,
	Action = function(self, ent) -- The action to perform upon using the property (Clientside)
		self:MsgStart()
			net.WriteEntity(ent)
		self:MsgEnd()
	end,
	Receive = function(self, length, player) -- The action to perform upon using the property (Serverside)
		local ent = net.ReadEntity()
		if (!self:Filter(ent, player)) then return end
        
        player.lastMarkerIndex = ent:GetMarkerIndex(0)
	end 
})

function ENT:SpawnFunction(ply, tr, ClassName)
    if not tr.Hit then return end

    local ent = ents.Create(ClassName)
    ent:SetPos(tr.HitPos + tr.HitNormal * 50)
    ent:Spawn()
    ent:Activate()

    if IsValid(ply) then
        if ply.lastMarkerIndex != nil then
            ply.lastMarkerIndex = ply.lastMarkerIndex + 1
        else
            ply.lastMarkerIndex = 0
        end
    end

    return ent
end

function ENT:Initialize()
    if (CLIENT) then return end

    self:SetModel("models/props_junk/PopCan01a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMaterial("models/debug/debugwhite")
    self:SetColor(Color(255, 255, 0, 255))

    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then 
        phys:Wake()
        phys:EnableGravity(false)
        phys:EnableMotion(false)
    end
    
    self.groundTrace = nil
    self:UpdateGround()
    self.thinkOnce = false
end 

function ENT:Think()    
    if CLIENT then 
        self:UpdateGround()
        return
    end
    
    if not self.thinkOnce then
        if IsValid(self:GetCreator()) then
            self:SetMarkerIndex(self:GetCreator().lastMarkerIndex)
        end

        self.thinkOnce = true
    end

    self:SetAngles(Angle(0, 0, 0))
end

function ENT:UpdateGround()
    self.groundTrace = util.QuickTrace(self:GetPos(), self:GetPos() - (self:GetPos() + Vector(0, 0, 1) * 1000), { self })
end

function ENT:GetTargetPos()
    local targetPos = self:GetPos()
    if self.groundTrace != nil and self.groundTrace.Hit then
        targetPos = self.groundTrace.HitPos
    end

    return targetPos
end

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "MarkerIndex")

    if SERVER then
        self:SetMarkerIndex(0)
    end
end

function ENT:Draw3DText(pos, ang, scale, text, flipView)
	if (flipView) then
		ang:RotateAroundAxis(Vector( 0, 0, 1 ), 180)
	end

    cam.Start3D2D(pos, ang, scale)
        local color = Color(255, 255, 0, 255)

        draw.DrawText(text, "DermaLarge", 2, 2, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
        draw.DrawText(text, "DermaLarge", 0, 0, color, TEXT_ALIGN_CENTER)

	cam.End3D2D()
end

function ENT:Draw()    
    if IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() != 'weapon_physgun'
        and LocalPlayer():GetActiveWeapon():GetClass() != 'gmod_tool'
    then
        return
    end

    self:DrawModel()

    if self.groundTrace.Hit then
        local oldPos = self:GetPos()
        self:SetModel('models/props_junk/TrafficCone001a.mdl')
        self:SetPos(self.groundTrace.HitPos)
        self:SetupBones()
        self:DrawModel()
        self:Draw3DText(
            self:GetPos() + Vector(0, 0, 30), 
            Angle(0, GetViewEntity():GetAngles().y + 90, 90), 
            0.25, 
            tostring(self:GetMarkerIndex()), 
            true
        )

        self:SetPos(oldPos) 
        self:SetupBones()
        self:SetModel("models/props_junk/PopCan01a.mdl")
    end
end

