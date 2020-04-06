AddCSLuaFile()

ENT.PrintName = "Race Marker"
ENT.Author = "Digaly"
ENT.Information = "Use this to create a race"
ENT.Category = "Miniracers"

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Editable = true
ENT.Spawnable = true
ENT.AdminOnly = false

properties.Add("mrreset", {
	MenuLabel = "Start Race", -- Name to display on the context menu
	Order = 999, -- The order to display this property relative to other properties
	MenuIcon = "icon16/flag_green.png", -- The icon to display next to the property

	Filter = function(self, ent, ply) -- A function that determines whether an entity is valid for this property
		if (!IsValid(ent)) then return false end
        if (not string.match(ent:GetClass(), "sent_mrrace")) then return false end
		if (!gamemode.Call("CanProperty", ply, "mrreset", ent)) then return false end

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
        
        ent.raceCountDown = 6
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

    self:SetModel("models/miniracers/mr_racemarker.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    --self:SetTrigger(true)
    --self:SetNotSolid(true)

    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then 
        phys:Wake() 
    end

    self.checkpoint = ents.Create("sent_mrcheckpoint")
    self.checkpoint.race = self;
    self.checkpoint:SetPos(self:GetPos() + self:GetForward() * 35)
    self.checkpoint:Spawn()
    self.checkpoint:Activate()

    self.laps = {}
    self.passedCheckpoint = {}
    self.raceCountDownTimer = 0
    self.raceCountDown = 0
end 

function ENT:OnRemove()
    if (CLIENT) then return end

    if IsValid(self.checkpoint) then
        self.checkpoint:Remove()
    end
end

function ENT:SetupDataTables()
	self:NetworkVar( "Int",	0, "MaxLaps",   { KeyName = "maxlaps",	Edit = { type = "Int",		order = 1, min = 0, max = 15 } } )

    if SERVER then
		self:SetMaxLaps(3)
	end
end

function ENT:Think()
    if (CLIENT) then return end

    if self.raceCountDown > 0 then
        self.raceCountDownTimer = self.raceCountDownTimer + FrameTime()
        if self.raceCountDownTimer > 1 then
            self.raceCountDown = self.raceCountDown - 1

            if self.raceCountDown == 0 then
                self:EmitSound("buttons/button10.wav", 75, 100)
                for k, ply in pairs(player.GetAll()) do
                    self.laps = {}
                    self.passedCheckpoint = {}            
                    ply:ChatPrint(
                        self:GetRaceName().."GO !!!"
                    )
                end                
            else
                for k, ply in pairs(player.GetAll()) do
                    ply:ChatPrint(
                        self:GetRaceName()..self.raceCountDown..".."
                    )
                end                
                self:EmitSound("buttons/button18.wav", 75, 150 - self.raceCountDown * 10)
            end

            self.raceCountDownTimer = 0
        end
    end

    local racers = ents.FindInSphere(self:GetPos() + self:GetForward() * 35 , 30)
    for k, v in pairs(racers) do
        if IsValid(v) && self.raceCountDown == 0 && string.match(v:GetClass(), "sent_miniracer") then
            --print(v)
            --print(v:GetCreator())
            if self.passedCheckpoint[v:GetCreator()] then

                if self.checkpoint:GetPos():Distance(self:GetPos()) < 150 then
                    return
                end

                if not self.laps[v:GetCreator()] then
                    self.laps[v:GetCreator()] = 0
                end
                self.laps[v:GetCreator()] = self.laps[v:GetCreator()] + 1

                if self.laps[v:GetCreator()] == self:GetMaxLaps() then
                    self:EmitSound("ambient/alarms/klaxon1.wav")
                    v:GetCreator():ChatPrint(
                        self:GetRaceName()..v:GetCreator():Nick().." completed the race!"
                    )    
                elseif self.laps[v:GetCreator()] < self:GetMaxLaps() then
                    self.passedCheckpoint[v:GetCreator()] = false
                    self:EmitSound("buttons/button3.wav")
                    v:GetCreator():ChatPrint(
                        self:GetRaceName()..v:GetCreator():Nick().." completed lap "..self.laps[v:GetCreator()]
                    )    
                end
            end
        end
    end

    local currentAngles = self:GetAngles()
    self:SetAngles(Angle(0, currentAngles.y, 0))

    self:NextThink(CurTime())
	return true
end

function ENT:GetRaceName()
    return "["..self:GetCreator():Nick().."'s Race] "
end