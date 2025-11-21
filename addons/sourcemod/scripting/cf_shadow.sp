#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>
#include <fakeparticles>
#include <worldtext>

#define Zero(%1)		ResetToZero(%1, sizeof(%1))
#define Zero2(%1)	ResetToZero2(%1, sizeof(%1), sizeof(%1[]))

stock void ResetToZero(any[] array, int length)
{
	for(int i; i<length; i++)
	{
		array[i] = 0;
	}
}
stock void ResetToZero2(any[][] array, int length1, int length2)
{
	for(int a; a<length1; a++)
	{
		for(int b; b<length2; b++)
		{
			array[a][b] = 0;
		}
	}
}


#define MAXTF2PLAYERS 					32
#define MAXENTITIES 					2048

#define M3 								CF_AbilityType_M3
#define M2 								CF_AbilityType_M2
#define REL 							CF_AbilityType_Reload

#define SHADOW							"cf_shadow"
#define BOMB 							"plantable_bomb"
#define CLOAK							"cloak"
#define UAV								"uav_drone"
#define PENETRATOR						"ult_laser_penetrator"
#define BACKSTAB						"backstab"
#define STEALTH							"stealth"

#define DRONE_MODEL						"models/chaos_fortress/drone_model/drone.mdl"
#define DRONE_DESTROYED_1				"weapons/sentry_explode.wav"
#define DRONE_DESTROYED_2				"player/medic_charged_death.wav"
#define DRONE_GIB_1						"models/player/gibs/gibs_gear2.mdl"
#define DRONE_GIB_2						"models/player/gibs/gibs_gear3.mdl"
#define DRONE_GIB_3						"models/player/gibs/gibs_gear4.mdl"
#define DRONE_GIB_4						"models/player/gibs/gibs_spring1.mdl"
#define DRONE_GIB_5						"models/player/gibs/gibs_spring2.mdl"
#define DRONE_PLACED					"player/recharged.wav"

#define SOUND_UAV_FOUND 				"weapons/sentry_spot_client.wav"
#define SOUND_UAV_FOUND_CLIENT 			"weapons/sentry_spot.wav"
#define SOUND_CLOAK_BLOCKED				"buttons/combine_button_locked.wav"
#define SOUND_STAB_NONLETHAL			"player/spy_shield_break.wav"
#define SOUND_BOMB_PLANTED				"chaos_fortress/agent/plant_bomb.mp3"

static const char DroneGear_Gib[][255] =
{
	DRONE_GIB_1,
	DRONE_GIB_2,
	DRONE_GIB_3,
	DRONE_GIB_4,
	DRONE_GIB_5
};

static const char DroneDamaged[][] = {
	"weapons/sentry_damage1.wav",
	"weapons/sentry_damage2.wav",
	"weapons/sentry_damage3.wav",
	"weapons/sentry_damage4.wav",
};

static int TETracker[MAXTF2PLAYERS];

static int Generic_Laser_BEAM_HitDetected[MAXENTITIES];

static int Text_Owner[MAXENTITIES] = { -1, ... };

static int BeamLaser;

static int GlowId[MAXENTITIES]={-1,...};
static int BlueGlow[4] = {88, 150, 185, 255};
static int RedGlow[4] = {185, 75, 59, 255};

static float OutlineFadeTime[MAXTF2PLAYERS]={0.0,...};
static float OutlineCurrentFadeTime[MAXTF2PLAYERS]={0.0,...};
static bool TargetOutlined[MAXTF2PLAYERS][MAXTF2PLAYERS];

static bool M2Pressed[MAXTF2PLAYERS];
static bool M3Pressed[MAXTF2PLAYERS];

public void OnMapStart()
{
	PrecacheModel(DRONE_MODEL, true);
	for (int i = 0; i < sizeof(DroneGear_Gib); i++) { PrecacheModel(DroneGear_Gib[i]); }
	BeamLaser = PrecacheModel("materials/sprites/laser.vmt");

	PrecacheSound(DRONE_DESTROYED_1, true);
	PrecacheSound(DRONE_DESTROYED_2, true);
	PrecacheSound(SOUND_UAV_FOUND, true);
	PrecacheSound(SOUND_UAV_FOUND_CLIENT, true);
	PrecacheSound(SOUND_CLOAK_BLOCKED, true);
	PrecacheSound(DRONE_PLACED, true);
	PrecacheSound(SOUND_STAB_NONLETHAL, true);
	PrecacheSound(SOUND_BOMB_PLANTED, true);
	for (int i = 0; i < sizeof(DroneDamaged); i++) { PrecacheSound(DroneDamaged[i]); }

	Zero(Generic_Laser_BEAM_HitDetected);
	Zero(TETracker);
}

public void OnPluginStart()
{
	HookEvent("player_carryobject", OnObjectCarry);
}

////////////////////////
//////   BOMB	///////
//////////////////////

static bool BombActive[MAXTF2PLAYERS]={false,...};
static bool HasABomb[MAXENTITIES]={false,...};
static int BombOwner[MAXENTITIES]={-1,...};
static int BombPlantedOn[MAXENTITIES]={-1,...};
static int BombsToPlace[MAXTF2PLAYERS]={0,...};
static int BombsAmount[MAXTF2PLAYERS];
static int BombOnNPC[MAXTF2PLAYERS]={0,...};
static int BombPhase[MAXTF2PLAYERS]={0,...};
static float BombDetonationTime[MAXTF2PLAYERS]={0.0,...};
static float BombCooldown[MAXTF2PLAYERS]={0.0,...};
static float BombDamage[MAXTF2PLAYERS]={0.0,...};
static float BombDamage_AoE[MAXTF2PLAYERS]={0.0,...};
static float BombDamage_Buildings_AoE[MAXTF2PLAYERS]={0.0,...};
static float BombRadius[MAXTF2PLAYERS]={0.0,...};

enum
{
	BOMB_IDLE = 0,
	BOMB_PLANTED = 1,
	BOMB_DETONATING = 2,
	BOMB_EXPLODING
}

static void PrepareBombs(int client, char abilityName[255])
{
	BombActive[client] = true;
	BombsToPlace[client] = 0;
	BombPhase[client] = BOMB_IDLE;
	CF_UnblockAbilitySlot(client, M3);

	BombsAmount[client] = CF_GetArgI(client, SHADOW, abilityName, "bombs_amount", 1);
	BombDamage[client] = CF_GetArgF(client, SHADOW, abilityName, "bomb_damage", 250.0);
	BombDamage_AoE[client] = CF_GetArgF(client, SHADOW, abilityName, "bomb_damage_aoe", 100.0);
	BombDamage_Buildings_AoE[client] = CF_GetArgF(client, SHADOW, abilityName, "bomb_damage_aoe_buildings", 300.0);
	BombRadius[client] = CF_GetArgF(client, SHADOW, abilityName, "bomb_radius", 100.0);
	BombOnNPC[client] = CF_GetArgI(client, SHADOW, abilityName, "plant_on_npc", 0);
	BombCooldown[client] = CF_GetArgF(client, SHADOW, abilityName, "bomb_cooldown", 12.0);
}

static void Bombs_Spawn(int client, char abilityName[255])
{
	BombsToPlace[client] = CF_GetArgI(client, SHADOW, abilityName, "bombs_amount", 1);
	CF_BlockAbilitySlot(client, M3);
}

static void Bombs_PlantOnEntity(int entity, int owner)
{
	if(HasABomb[entity] || !BombActive[owner] || GetTeam(entity) == GetTeam(owner))
		return;
	
	float Origin[3], EntLoc[3];
	CF_WorldSpaceCenter(owner, Origin);
	CF_WorldSpaceCenter(entity, EntLoc);
	
	float dist = GetVectorDistance(Origin, EntLoc);
	float radius = CF_GetArgF(owner, SHADOW, BOMB, "plant_range", 350.0);
	if(dist > radius)
		return;

	if(BombsToPlace[owner] > 0)
	{
		EmitSoundToAll(SOUND_BOMB_PLANTED, owner);
		HasABomb[entity] = true;
		BombsToPlace[owner]--;
		
		BombPhase[owner] = BOMB_PLANTED;

		BombOwner[entity] = owner;
		BombPlantedOn[owner] = EntIndexToEntRef(entity);

		if(TF2_GetClientTeam(owner) == TFTeam_Blue)
		{
			SetEntityRenderColor(entity, 3, 204, 255, 255);
		}
		else
		{
			SetEntityRenderColor(entity, 255, 65, 84, 255);
		}
		
		DataPack pack = new DataPack();
		pack.WriteCell(owner);
		pack.WriteCell(EntIndexToEntRef(entity));
		RequestFrame(Bombs_RequestFrame, pack);
	}
}

static void Bombs_RequestFrame(DataPack pack)
{	
	pack.Reset();
	int owner = pack.ReadCell();
	int entity = EntRefToEntIndex(pack.ReadCell());

	if(!IsValidClient(owner))
	{	
		delete pack;
		return;
	}

	if(!IsValidEntity(entity))
	{	
		if(BombPhase[owner] == BOMB_PLANTED)
		{
			BombPhase[owner] = BOMB_IDLE;
			BombsToPlace[owner] = 0;
			CF_ApplyAbilityCooldown(owner, 5.0, M3, true);
			CF_UnblockAbilitySlot(owner, M3);
		}
		
		if(BombPhase[owner] == BOMB_DETONATING)
		{
			if(BombDetonationTime[owner] > GetGameTime())
			{
				BombPhase[owner] = BOMB_IDLE;
				BombsToPlace[owner] = 0;
				CF_ApplyAbilityCooldown(owner, 12.0, M3, true);
				CF_UnblockAbilitySlot(owner, M3);
			}
		}

		delete pack;
		return;
	}
	
	int phase = BombPhase[owner];
	switch(phase)
	{
		case BOMB_IDLE:
		{
			CF_ApplyAbilityCooldown(owner, BombCooldown[owner], M3, true);
			CF_UnblockAbilitySlot(owner, M3);

			SetEntityRenderColor(entity, 255, 255, 255, 255);

			HasABomb[entity] = false;
			BombsToPlace[owner] = 0;
			
			BombOwner[entity] = -1;
			BombPlantedOn[owner] = -1;
			
			delete pack;

			return;
		}
		case BOMB_DETONATING:
		{
			if(BombDetonationTime[owner] <= GetGameTime())
			{
				BombPhase[owner] = BOMB_EXPLODING;
			}
		}
		case BOMB_EXPLODING:
		{
			CF_ApplyAbilityCooldown(owner, BombCooldown[owner], M3, true);
			CF_UnblockAbilitySlot(owner, M3);

			BombPhase[owner] = BOMB_IDLE;
			HasABomb[entity] = false;

			float Origin[3]; CF_WorldSpaceCenter(entity, Origin);
			SpawnSpriteExplosion(Origin, 1);

			for(int i = 1; i <= MAXENTITIES; i++)
			{
				if(IsValidMulti(i))
				{
					if(entity == i)
						continue;

					if(GetTeam(i) == GetTeam(owner))
						continue;

					CF_WorldSpaceCenter(entity, Origin);
					float TargetLocation[3]; CF_WorldSpaceCenter(i, TargetLocation);
					float dist = GetVectorDistance(Origin, TargetLocation);

					if(CF_HasLineOfSight(Origin, TargetLocation, _, Origin) && dist <= BombRadius[owner])
					{
						SDKHooks_TakeDamage(i, owner, owner, BombDamage_AoE[owner], DMG_BLAST);
					}
				}

				if(IsABuilding(i, true))
				{
					if(entity == i)
						continue;
						
					if(GetTeam(i) == GetTeam(owner))
						continue;
					
					CF_WorldSpaceCenter(entity, Origin);
					float TargetLocation[3]; CF_WorldSpaceCenter(i, TargetLocation);
					float dist = GetVectorDistance(Origin, TargetLocation);

					if(CF_HasLineOfSight(Origin, TargetLocation, _, Origin) && dist <= BombRadius[owner])
					{
						SDKHooks_TakeDamage(i, owner, owner, BombDamage_Buildings_AoE[owner], DMG_BLAST);
					}
				}
			}

			SDKHooks_TakeDamage(entity, owner, owner, BombDamage[owner], DMG_BLAST);

			delete pack;

			return;
		}
	}

	DataPack pack2 = new DataPack();
	pack2.WriteCell(owner);
	pack2.WriteCell(entity);
	RequestFrame(Bombs_RequestFrame, pack2);

	delete pack;
}

static void Bombs_TETracking(int owner, int ref)
{
	if(!IsValidClient(owner))
		return;
	
	int entity = EntRefToEntIndex(ref);
	if(!IsValidEntity(entity))
		return;

	if(TETracker[owner] >= 3)
	{
		TETracker[owner] = 0;

		float Origin[3]; CF_WorldSpaceCenter(entity, Origin);

		int color[4]; color = TF2_GetClientTeam(owner) == TFTeam_Blue ? BlueGlow : RedGlow;

		float radius = BombRadius[owner] * 2.0;
		SpawnRing(Origin, 0.1, 0.0, 0.0, -25.0, BeamLaser, 0, color[0], color[1], color[2], color[3], 1, 0.11, 7.5, 1.0, 1, radius);
	}

	TETracker[owner]++;
}

public void OnObjectCarry(Event event, const char[] className, bool dontBroadcast) 
{
	int building = event.GetInt("index");
	//int builder = GetClientOfUserId(event.GetInt("userid"));

	if(!HasABomb[building])
		return;
	
	if(IsValidClient(BombOwner[building]))
		BombPhase[BombOwner[building]] = BOMB_IDLE;

	BombOwner[building] = -1;
	BombPlantedOn[building] = -1;
	HasABomb[building] = false;
}

////////////////////////
//////   CLOAK   //////
//////////////////////

static bool CloakActive[MAXTF2PLAYERS]={false,...};
static bool CloakUsing[MAXTF2PLAYERS]={false,...};
static bool CloakCanUse[MAXTF2PLAYERS]={false,...};

static float CloakMinUse[MAXTF2PLAYERS]={0.0,...};
static float ButtonInitialDelay[MAXTF2PLAYERS]={0.0,...};

static int CloakSlot[MAXTF2PLAYERS][2];

public void PrepareCloak(int client, char abilityName[255])
{
	//Slight delay needed so our starting_cloak argument takes action immediately right after an respawn/supply touch.

	SetEntPropFloat(client, Prop_Send, "m_flStealthNextChangeTime", GetGameTime()+7.0);
	CreateTimer(0.11, Cloak_Set, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

static Action Cloak_Set(Handle timer, int id)
{
	int client = GetClientOfUserId(id);
	if(!IsValidMulti(client))
		return Plugin_Stop;

	CloakActive[client] = true;

	bool Cloaked = IsCloaked(client);

	CloakUsing[client] = Cloaked;

	float MinCloak = CF_GetArgF(client, SHADOW, CLOAK, "minimum_cloak", 0.5);
	float StartCloak = CF_GetArgF(client, SHADOW, CLOAK, "starting_cloak", 0.0);

	CloakSlot[client][0] = CF_GetArgI(client, SHADOW, CLOAK, "cloak_slot", -1);
	CloakSlot[client][1] = CF_GetArgI(client, SHADOW, CLOAK, "decloak_slot", -1);
	
	CloakMinUse[client] = MinCloak;

	float CloakMeter = TF2_GetCloakLevel(client);
	
	TF2_SetCloakLevel(client, StartCloak, true);

	if(CloakMeter >= CloakMinUse[client])
	{
		TF2_SetCloakLevel(client, StartCloak, true);
		SetEntPropFloat(client, Prop_Send, "m_flStealthNextChangeTime", GetGameTime()+0.15);
		CloakCanUse[client] = true;
	}
	else if(CloakMeter < CloakMinUse[client])
	{
		TF2_SetCloakLevel(client, StartCloak, true);
		ButtonInitialDelay[client] = 1.35 + GetGameTime();
		SetEntPropFloat(client, Prop_Send, "m_flStealthNextChangeTime", GetGameTime()+9999.0);
		CloakCanUse[client] = false;
	}

	RequestFrame(Cloak_RequestFrame_Think, client);

	return Plugin_Continue;
}

static void Cloak_RequestFrame_Think(int client)
{
	if(!CloakActive[client] || !IsValidMulti(client))
	{	
		return;
	}

	bool Cloaked = IsCloaked(client);
	float CloakMeter = TF2_GetCloakLevel(client);

	if(CloakMeter < CloakMinUse[client] && !Cloaked)
	{
		if(CloakCanUse[client])
			ButtonInitialDelay[client] = 1.35 + GetGameTime();
		SetEntPropFloat(client, Prop_Send, "m_flStealthNextChangeTime", GetGameTime()+9999.0);
		CloakCanUse[client] = false;
	}
	else if(CloakMeter >= CloakMinUse[client])
	{
		if(!CloakCanUse[client])
			SetEntPropFloat(client, Prop_Send, "m_flStealthNextChangeTime", GetGameTime()+0.15);
		CloakCanUse[client] = true;
	}

	RequestFrame(Cloak_RequestFrame_Think, client);
}

static bool IsCloaked(int client)
{
	bool value;

	if(TF2_IsPlayerInCondition(client, TFCond_Cloaked))
	{
		value = true;
	}

	return value;
}

///////////////////////////////////
////////   UAV-DRONE    //////////
/////////////////////////////////

#define UAV_AMOUNT 1 //We never really want to give Agent more than 1 UAV.

enum
{
	IDLE = 0,
	TARGETING = 1
}

static bool UAVActive[MAXTF2PLAYERS]={false,...};
static int UAV_ShowScanOutline_Teammates[MAXTF2PLAYERS]={0,...};
static int UAV_Mode[MAXTF2PLAYERS]={IDLE,...};
static int UAVDrone[MAXTF2PLAYERS]={-1,...};
static int UAVTarget[MAXTF2PLAYERS]={-1,...};
static float UAV_ChaseTargTimer[MAXTF2PLAYERS];
static float UAV_OutlineColorDelay[MAXTF2PLAYERS]={0.0,...};
static float UAV_SpinAngle[MAXTF2PLAYERS]={0.0,...};
static float UAV_CurrentLifeSpan[MAXTF2PLAYERS]={0.0,...};
static float UAV_Health[MAXENTITIES]={0.0,...};
static float UAV_EndPoint[MAXENTITIES][3];
static float AgentCurrentLoc[MAXTF2PLAYERS][3];

static bool Exposed[MAXTF2PLAYERS];

#define DRONE_COLLISION_NOTHING		10
#define DRONE_COLLISION_NON_PLAYER	26

enum struct UAV_Drone
{
	int Owner;
	int Target;
	float ChaseWindup;
	float size;
	float Life;
	float Durability;

	void Spawn()
	{
		if(!IsValidClient(this.Owner))
		{	
			return;
		}

		float pos[3], ang[3];

		GetClientEyeAngles(this.Owner, ang);
		CF_WorldSpaceCenter(this.Owner, pos);

		int Drone = SpawnPhysProp(this.Owner, DRONE_MODEL, pos, ang, NULL_VECTOR, TF2_GetClientTeam(this.Owner) == TFTeam_Red ? view_as<int>(TFTeam_Blue) : view_as<int>(TFTeam_Red), this.Durability, false, _, this.size, this.size * 2.0, true);
		if (IsValidEntity(Drone))
		{
			SetEntProp(Drone, Prop_Data, "m_takedamage", 1, 1);
			SetEntProp(Drone, Prop_Send, "m_nSkin", GetClientTeam(this.Owner)-2);
			DispatchKeyValueFloat(Drone, "modelscale", this.size);
			SDKUnhook(Drone, SDKHook_OnTakeDamage, Drone_UAVDamaged);
			SDKHook(Drone, SDKHook_OnTakeDamage, Drone_UAVDamaged);

			if(IsValidClient(this.Target))
				UAVTarget[this.Owner] = this.Target;

			UAV_Health[Drone] = this.Durability;

			UAVDrone[this.Owner] = EntIndexToEntRef(Drone);

			UAV_ChaseTargTimer[this.Owner] = GetGameTime() + this.ChaseWindup;
			UAV_CurrentLifeSpan[this.Owner] = GetGameTime() + this.Life;
		}
	}

	void Delete()
	{
		int Drone = EntRefToEntIndex(UAVDrone[this.Owner]);
		if(IsValidEntity(Drone))
		{
			float pos[3]; GetAbsOrigin_main(Drone, pos);
			SpawnParticle(pos, "rd_robot_explosion", 0.1);

			EmitSoundToAll(DRONE_DESTROYED_1, Drone, _, _, _, _, GetRandomInt(80, 110), -1);
			EmitSoundToAll(DRONE_DESTROYED_2, Drone, _, _, _, _, GetRandomInt(80, 110), -1);

			for (int i = 0; i < GetRandomInt(4, 6); i++)
			{
				float randAng[3], randVel[3];
				for (int vec = 0; vec < 3; vec++)
				{
					randAng[vec] = GetRandomFloat(0.0, 360.0);
					
					if (vec < 2)
						randVel[vec] = GetRandomFloat(0.0, 360.0);
					else
						randVel[vec] = GetRandomFloat(200.0, 800.0);
				}
				
				char model[255];
				model = DroneGear_Gib[GetRandomInt(0, sizeof(DroneGear_Gib) - 1)];
				int gear = SpawnPhysicsProp(model, 0, "0", 99999.0, true, 1.0, pos, randAng, randVel, 5.0);
				
				if (IsValidEntity(gear))
				{
					SetEntityCollisionGroup(gear, 1);
					SetEntityRenderMode(gear, RENDER_TRANSALPHA);
					RequestFrame(Toss_FadeOutGib, EntIndexToEntRef(gear));
					SetEntityCollisionGroup(gear, 1);
					SetEntProp(gear, Prop_Send, "m_iTeamNum", 0);
				}
			}
			RemoveEntity(Drone);
		}

		UAVDrone[this.Owner] = -1;
	}
}

enum struct iGlowEntity
{
	int entity;
	int owner;
	int color[4];
	bool teamColor;
	float lifeSpan;

	int Create()
	{
		if(!IsValidClient(this.entity) || !IsPlayerAlive(this.entity))
			return -1;

		switch(this.teamColor)
		{
			case true:
			{
				if(TF2_GetClientTeam(this.entity) == TFTeam_Red)
				{
					this.color = RedGlow;
				}
				else
				{
					this.color = BlueGlow;
				}
			}
		}
		
		int iGlow = TF2_CreateGlow_Custom(this.entity, this.color);
		if(!IsValidEntity(iGlow))
			return -1;

		Exposed[this.entity] = true;

		SetEntProp(iGlow, Prop_Send, "m_iTeamNum",  view_as<int>(TF2_GetClientTeam(this.entity)));

		SetEntPropEnt(iGlow, Prop_Send, "m_hOwnerEntity", this.owner);

		SetEdictFlags(iGlow, GetEdictFlags(iGlow)&(~FL_EDICT_ALWAYS));
		SDKHook(iGlow, SDKHook_SetTransmit, CF_Agent_OutlineTransmit);

		if(this.lifeSpan > 0.0)
			CreateTimer(this.lifeSpan, Timer_RemoveEntity, EntIndexToEntRef(iGlow), TIMER_FLAG_NO_MAPCHANGE);
		
		return iGlow;
	}
	void ChangeColor(int icolor[4])
	{
		if(!IsValidClient(this.entity) || !IsPlayerAlive(this.entity))
			return;

		int iGlow = EntRefToEntIndex(GlowId[this.entity])
		if(IsValidEntity(iGlow))
		{
			SetVariantColor(icolor);		
			AcceptEntityInput(iGlow, "SetGlowColor");
		}
	}
	void Delete()
	{
		int iGlow = EntRefToEntIndex(GlowId[this.entity])
		if(IsValidEntity(iGlow))
		{
			RemoveEntity(iGlow);

			GlowId[this.entity] = -1;
		}
		Exposed[this.entity] = false;
	}
}

public void PrepareUAV(int client, char abilityName[255])
{
	UAVActive[client] = true;
	UAVTarget[client] = -1;

	UAV_Destroy(client);
}

static void UAV_RemoveOutlines(int client)
{
	for(int i=1;i<=MaxClients;i++)
	{
		if(IsValidClient(i) && TargetOutlined[i][client]) 
		{
			iGlowEntity Glow;
			Glow.entity = i;
			Glow.Delete();

			TargetOutlined[i][client] = false;
		}
	}
}

void UAV_Destroy(int owner)
{
	UAV_Drone Uav;
	Uav.Owner = owner;
	Uav.Delete();
	UAV_CurrentLifeSpan[owner] = 0.0;
}

public Action Drone_UAVDamaged(int prop, int &attacker, int &inflictor, float &damage, int &damagetype)
{	
	float originalDamage = damage;
	damage *= 0.0;
	
	if (GetTeam(prop) != GetTeam(attacker))
	{	
		if (IsValidClient(attacker))
		{
			if (originalDamage >= UAV_Health[prop])
				ClientCommand(attacker, "playgamesound ui/killsound.wav");
			else
			{
				EmitSoundToAll(DroneDamaged[GetRandomInt(0, sizeof(DroneDamaged) - 1)], prop);
				ClientCommand(attacker, "playgamesound ui/hitsound.wav");
			}
				
			float pos[3];
			CF_WorldSpaceCenter(prop, pos);
			pos[2] += 10.0;
			
			#if defined _worldtext_included_
			char damageDealt[16];
			Format(damageDealt, sizeof(damageDealt), "-%i", RoundToCeil(originalDamage));
			int text = WorldText_Create(pos, NULL_VECTOR, damageDealt, 15.0, _, _, _, 255, 120, 120, 255);
			if (IsValidEntity(text))
			{
				Text_Owner[text] = GetClientUserId(attacker);
				SDKHook(text, SDKHook_SetTransmit, Text_Transmit);
				
				WorldText_MimicHitNumbers(text);
			}
			#endif
		}
		
		UAV_DealDamage(prop, originalDamage);	
	}

	return Plugin_Changed;
}

public void UAV_DealDamage(int drone, float damage)
{
	UAV_Health[drone] -= damage;
	if (UAV_Health[drone] <= 0.0)
		UAV_Destroyed(drone);
}

static void UAV_Destroyed(int drone)
{
	int owner = GetEntPropEnt(drone, Prop_Data, "m_hOwnerEntity");
	if(!IsValidClient(owner))
	{
		UAV_Destroy(owner);
		return;
	}

	UAV_Destroy(owner);
}

public void UAV_SpawnDrone(int client, char abilityName[255])
{
	if(!UAVActive[client])
		return;

	UAV_Destroy(client);
	UAV_RemoveOutlines(client);

	float timer = CF_GetArgF(client, SHADOW, abilityName, "uav_chase_delay", 1.5);
	float lifespan = CF_GetArgF(client, SHADOW, abilityName, "uav_lifespan_idle", 13.5);
	float size = CF_GetArgF(client, SHADOW, abilityName, "uav_model_size", 1.0);
	float fadeTime = CF_GetArgF(client, SHADOW, abilityName, "uav_outline_fadetime", 3.0);
	float cooldown = CF_GetArgF(client, SHADOW, abilityName, "uav_cooldown", 25.0);
	float durability = CF_GetArgF(client, SHADOW, abilityName, "uav_health", 175.0);
	float traceDistance = CF_GetArgF(client, SHADOW, abilityName, "uav_placement_range", 1200.0);

	bool showToTeam = view_as<bool>(CF_GetArgI(client, SHADOW, abilityName, "uav_allow_teammates_see_outlines", 0));
	UAV_ShowScanOutline_Teammates[client] = showToTeam;

	OutlineFadeTime[client] = fadeTime;

	float VecOrigin[3]; GetAbsOrigin_main(client, VecOrigin);
	bool TraceHit;

	Generic_Laser_Trace AimTrace;
	AimTrace.client = client;
	AimTrace.DoForwardTrace_Basic(traceDistance, TraceWorldOrValidTarget);
	TraceHit = AimTrace.trace_hit;

	AgentCurrentLoc[client] = VecOrigin;

	AgentCurrentLoc[client][2] += 50.0;

	switch(TraceHit)
	{
		case true:
		{
			int target = AimTrace.target;

			// TE_SetupBeamPoints(AimTrace.Start_Point, AimTrace.End_Point, BeamLaser, 0, 0, 5, 3.0, 1.0, 10.0, 1, 15.0, {0, 255, 0, 120}, 0);	
			// TE_SendToAll();

			UAV_Drone Uav;
			Uav.Owner = client;

			if(IsValidMulti(target))	
			{	
				if(!Exposed[target])
				{
					target = AimTrace.target;

					iGlowEntity Glow;
					Glow.entity = target;
					Glow.owner = client;
					Glow.teamColor = true;
					GlowId[target] = EntIndexToEntRef(Glow.Create());

					lifespan = CF_GetArgF(client, SHADOW, abilityName, "uav_lifespan", 13.5);

					Uav.Target = target;

					EmitSoundToClient(target, SOUND_UAV_FOUND_CLIENT);
				}
				else
				{
					UAV_EndPoint[client] = AimTrace.End_Point;
				}
			}
			else
			{
				UAV_EndPoint[client] = AimTrace.End_Point;
			}

			Uav.ChaseWindup = timer;
			Uav.size = size;
			Uav.Life = (lifespan + timer); 
			Uav.Durability = durability; 
			Uav.Spawn();

			int Drone = EntRefToEntIndex(UAVDrone[client]);
			if(IsValidEntity(Drone))
			{
				UAV_Mode[client] = TARGETING;

				TeleportEntity(Drone, AgentCurrentLoc[client]);
				SetEntityCollisionGroup(Drone, DRONE_COLLISION_NON_PLAYER);

				CF_ApplyAbilityCooldown(client, cooldown, REL, true, true);

				RequestFrame(UAV_Logic, client);

				EmitSoundToClient(client, SOUND_UAV_FOUND);
			}
		}
	}
}

public bool CanTarget(int enemy)
{
	return (!IsPlayerInvis(enemy) && !Exposed[enemy]);
}

public bool IsTargetOutlined(int entity)
{
	if(!Exposed[entity])
		return false;
	
	return true;
}

public bool IsTargetOutlined_FromEnemy(int entity, int outliner)
{
	if(!TargetOutlined[entity][outliner])
		return false;
	
	return true;
}

public void UAV_CheckRadius(int client, float StartPos[3], float maxDistance)
{
	float Player_Pos[3];

	if(IsValidClient(UAVTarget[client]))
	{
		if(IsPlayerAlive(UAVTarget[client]))
		{
			GetEntPropVector(UAVTarget[client], Prop_Send, "m_vecOrigin", Player_Pos);

			for(int enemies = 1; enemies <= MaxClients; enemies++)
			{
				if(!IsValidMulti(enemies)) //Dead or not valid, ignore
					continue;

				if(GetTeam(client) == GetTeam(enemies)) //Our teammate, ignore
					continue;

				if(UAVTarget[client] == enemies) //Our current target, ignore
					continue;

				float EnemOrigin[3];
				GetEntPropVector(enemies, Prop_Send, "m_vecOrigin", EnemOrigin);

				float ScanRadius = CF_GetArgF(client, SHADOW, UAV, "uav_scan_radius_scan", 500.0);

				float Dist_New = GetVectorDistance(Player_Pos, EnemOrigin);
				if(Dist_New > ScanRadius)	//Out of reach? Ignore.
				{
					switch(IsTargetOutlined_FromEnemy(enemies, client))
					{
						case true:
						{
							UAV_DeleteOutline_Void(client, enemies);
						}
					}
					continue;
				}

				int outline = EntRefToEntIndex(GlowId[enemies]);
				if(!IsValidEntity(outline) && !IsTargetOutlined(enemies) && !IsTargetOutlined_FromEnemy(enemies, client))
				{
					TargetOutlined[enemies][client] = true;

					iGlowEntity Glow;
					Glow.entity = enemies;
					Glow.owner = client;
					Glow.teamColor = true;
					GlowId[enemies] = EntIndexToEntRef(Glow.Create());
					EmitSoundToClient(enemies, SOUND_UAV_FOUND);
				}

				if(IsTargetOutlined(enemies))
				{
					outline = EntRefToEntIndex(GlowId[enemies]);
					if(IsValidEntity(outline))
					{
						float Alpha = Dist_New / ScanRadius;
						if(Alpha > 1.0)
						{
							Alpha = 1.0;
						}

						int color[4];
						if(TF2_GetClientTeam(client) == TFTeam_Red)
						{
							color = BlueGlow;
						}
						else
						{
							color = RedGlow;
						}

						float opacity_Effectiveness = CF_GetArgF(client, SHADOW, UAV, "uav_outline_effectiveness", 0.1);
						color[3] = RoundFloat(255.0 - (Alpha * ScanRadius * opacity_Effectiveness));
						
						if(color[3] > 255)
						{
							color[3] = 255;
						}
						if(color[3] < 88)
						{
							color[3] = 88;
						}

						iGlowEntity Glow;
						Glow.entity = enemies;
						Glow.ChangeColor(color);
					}
				}
			}
		}
		else UAV_CurrentLifeSpan[client] = 0.0;
	}
	else 
	{
		if(!IsValidClient(UAVTarget[client]))
		{
			UAVTarget[client] = CF_GetClosestTarget(StartPos, false, _, maxDistance, grabEnemyTeam(client), SHADOW, CanTarget);

			if(IsValidMulti(UAVTarget[client]))
			{
				UAV_CurrentLifeSpan[client] = GetGameTime() + CF_GetArgF(client, SHADOW, UAV, "uav_lifespan", 0.1);

				iGlowEntity Glow;
				Glow.entity = UAVTarget[client];
				Glow.owner = client;
				Glow.teamColor = true;
				GlowId[UAVTarget[client]] = EntIndexToEntRef(Glow.Create());
			}
		}
	}
}

static void UAV_Logic(int client)
{	
	int DroneEntity = EntRefToEntIndex(UAVDrone[client]);	

	if(!IsValidClient(client) || !UAVActive[client] || UAV_CurrentLifeSpan[client] <= GetGameTime() || !IsValidEntity(DroneEntity))
	{	
		for(int enemies = 1; enemies <= MaxClients; enemies++)
		{
			if(!IsValidMulti(enemies)) //Dead or not valid, ignore
				continue;

			if(GetTeam(client) == GetTeam(enemies)) //Our teammate, ignore
				continue;

			if(UAVTarget[client] == enemies) //Our current target, ignore
				continue;

			switch(IsTargetOutlined_FromEnemy(enemies, client))
			{
				case true:
				{
					iGlowEntity Glow;
					Glow.entity = enemies;
					Glow.Delete();

					TargetOutlined[enemies][client] = false;
				}
			}
		}

		if(IsValidClient(UAVTarget[client]))
		{
			if(IsPlayerAlive(UAVTarget[client]))
			{
				if(!IsTargetOutlined_FromEnemy(UAVTarget[client], client))
				{
					TargetOutlined[UAVTarget[client]][client] = true;
					OutlineCurrentFadeTime[client] = GetGameTime() + OutlineFadeTime[client];
				}
			}
			else
			{
				iGlowEntity Glow;
				Glow.entity = UAVTarget[client];
				Glow.Delete();
			}
		}
		else
		{
			float newCD = CF_GetArgF(client, SHADOW, UAV, "uav_cd_refund", 5.0);
			CF_ApplyAbilityCooldown(client, newCD, REL, true, true);
		}

		UAV_Destroy(client);

		return;
	}
	
	float Range = CF_GetArgF(client, SHADOW, UAV, "uav_hover_range", 125.0), 
	Spin_angle = CF_GetArgF(client, SHADOW, UAV, "uav_spin_angle", 1.33), 
	Speed = CF_GetArgF(client, SHADOW, UAV, "uav_spin_speed", 1.5),
	maxDistance = CF_GetArgF(client, SHADOW, UAV, "uav_search_distance");

	float UAV_Loc[3];
	GetEntPropVector(DroneEntity, Prop_Send, "m_vecOrigin", UAV_Loc);

	float Player_Pos[3], 
	Origin[3], 
	Loc[3];

	if(IsValidClient(UAVTarget[client]))
	{
		if(IsPlayerAlive(UAVTarget[client]))
			GetEntPropVector(UAVTarget[client], Prop_Send, "m_vecOrigin", Player_Pos);
	}
	else
	{
		Player_Pos = UAV_EndPoint[client];
	}

	Origin = AgentCurrentLoc[client];
	
	if(UAV_ChaseTargTimer[client] <= GetGameTime())
	{
		Move_Vector_Towards_Target(Origin, Player_Pos, Loc, Speed);
	}
	else
	{
		Loc = Origin;
	}

	UAV_CheckRadius(client, UAV_Loc, maxDistance);

	AgentCurrentLoc[client] = Loc;

	Player_Pos = Loc;	//our end point
	Player_Pos[2]+=50.0;

	if(Spin_angle != 0.0)
	{
		UAV_SpinAngle[client] +=Spin_angle;

		if(UAV_SpinAngle[client]>360.0)
			UAV_SpinAngle[client]=0.0;
	}

	for(int i=0 ; i < UAV_AMOUNT ; i++)
	{
		float tempAngles[3], Direction[3], EndLoc[3], Multi;

		if(i%2!=0)
		{
			Multi = 1.0;
		}
		else
		{
			Multi = -1.0;
		}
		
		if(Spin_angle != 0.0)
		{	
			tempAngles[0] = 0.0;
			tempAngles[1] = (UAV_SpinAngle[client] + (float(i) * (360.0/UAV_AMOUNT)))*Multi;
			tempAngles[2] = 0.0;

			if(tempAngles[2]>360.0)
				tempAngles[2]-=360.0;
		}

		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, Range);
		AddVectors(Player_Pos, Direction, EndLoc);

		EndLoc[2]+=50.0;

		int colors[4];
		UAV_Loc[2] += 5.0;

		if(TF2_GetClientTeam(client) == TFTeam_Red)
		{
			colors = RedGlow;
		}
		else
		{
			colors = BlueGlow;
		}

		TE_SetupBeamRingPoint(UAV_Loc, 7.0, 0.0, BeamLaser, 0, 0, 1, 0.1, 3.5, 1.0, colors, 1, 0);
		TE_SendToAll();

		float Ang[3];

		MakeVectorFromPoints(Player_Pos, UAV_Loc, Ang);
		GetVectorAngles(Ang, Ang);

		float buffer_ang[3]; buffer_ang=Ang;

		MakeVectorFromPoints(UAV_Loc, Player_Pos, buffer_ang);
		GetVectorAngles(buffer_ang, buffer_ang);

		float Dist = GetVectorDistance(EndLoc, UAV_Loc);
		if(Dist>75.0)
		{
			MoveEntity(DroneEntity, EndLoc, buffer_ang, true);
		}
		else
		{
			MoveEntity(DroneEntity, EndLoc, buffer_ang, true);
		}
	}

	RequestFrame(UAV_Logic, client);
}

public Action CF_OnAbilityCheckCanUse(int client, char plugin[255], char ability[255], CF_AbilityType type, bool &result)
{
	if (!StrEqual(plugin, SHADOW))
		return Plugin_Continue;

	if (StrContains(ability, UAV) != -1)
	{
		if (CF_GetRoundState() == 0)
		{
			result = false;
			return Plugin_Changed;
		}
		if (CF_IsEntityInSpawn(client, TF2_GetClientTeam(client)))
		{
			result = false;
			return Plugin_Changed;
		}

		return Plugin_Continue;
	}

	return Plugin_Continue;
}


///////////////////////////////////
////////  PENETRATOR   ///////////
/////////////////////////////////

static float Offset[MAXTF2PLAYERS][3];
static int Penetrations[MAXTF2PLAYERS]={0,...};

public void PreparePenetrator(int client, char abilityName[255])
{
	char vectorStr[255];
	char vectorStrs[32][32];
	CF_GetArgS(client, SHADOW, abilityName, "laser_offset", vectorStr, sizeof(vectorStr));
	ExplodeString(vectorStr, " ; ", vectorStrs, sizeof(vectorStrs), sizeof(vectorStrs));
	Offset[client][0] = StringToFloat(vectorStrs[0]);
	Offset[client][1] = StringToFloat(vectorStrs[1]);
	Offset[client][2] = StringToFloat(vectorStrs[2]);
}

public void Penetrator_Initiate(int client, char abilityName[255])
{
	Penetrator_Trace(client, abilityName);
}

public void Penetrator_Trace(int client, char abilityName[255])
{
	Penetrations[client] = 0;

	int MaxPenetrations = CF_GetArgI(client, SHADOW, abilityName, "laser_max_penetrations", 0);
	bool PenaltyIngore = view_as<bool>(CF_GetArgI(client, SHADOW, abilityName, "laser_targets_ignore_penalty_los", 0));

	float damage = CF_GetArgF(client, SHADOW, abilityName, "laser_damage", 120.0),
	shootDist = CF_GetArgF(client, SHADOW, abilityName, "laser_range", 1200.0),
	width = CF_GetArgF(client, SHADOW, abilityName, "laser_width_visual", 12.0) * 1.5;

	float vecStart[3], vecAngles[3];

	GetClientEyeAngles(client, vecAngles);
	GetClientEyePosition(client, vecStart);

	GetBeamDrawStartPoint(client, vecStart);

	Generic_Laser_Trace Laser;
	
	Laser.client = client;
	Laser.DoForwardTrace_Custom(vecAngles, vecStart, shootDist, Generic_Laser_BEAM_TraceUsers);

	float NewLoc[3], NewAngles[3], Direction[3], vecEnd[3];
	GetClientEyeAngles(client, NewLoc);
	GetBeamDrawStartPoint(client, NewLoc);
	NewAngles = vecAngles;
	GetAngleVectors(NewAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	float scale = shootDist;
	ScaleVector(Direction, scale);
	AddVectors(NewLoc, Direction, vecEnd);
	
	Laser.damagetype = DMG_PLASMA;
	Laser.Damage = damage;
	Laser.Start_Point = NewLoc;
	Laser.End_Point = vecEnd;
	Laser.Custom_Hull[0] = width;
	Laser.Custom_Hull[1] = 5.0;
	Laser.Custom_Hull[2] = 5.0;
	Laser.CleanEnumerator();
	Laser.EnumerateGetEntities();
	Queue Victims = Laser.GetEnumeratedEntityPop();
			
	while(!Victims.Empty)
	{
		int victim = Victims.Pop();
		if (victim)
		{
			float totalDamage = Laser.Damage;

			float playerPos[3], enemyPos[3];
			GetAbsOrigin_main(client, playerPos);
			GetAbsOrigin_main(victim, enemyPos);

			if(IsValidEntity(victim) && victim > MaxClients)
			{
				float fallOff_Start = CF_GetArgF(client, SHADOW, abilityName, "laser_falloff_start", 1.0), 
				fallOff_End = CF_GetArgF(client, SHADOW, abilityName, "laser_falloff_end", 0.35), 
				fallOff_MaxDist = CF_GetArgF(client, SHADOW, abilityName, "laser_falloff_maxDistance", 1250.0);
				if(fallOff_Start < 1.0)
				{
					totalDamage *= CalculateFallOff(playerPos, enemyPos, fallOff_Start, fallOff_End, fallOff_MaxDist);
				}

				SDKHooks_TakeDamage(victim, Laser.client, Laser.client, totalDamage, Laser.damagetype, -1, NULL_VECTOR);
			}

			if(IsValidMulti(victim))
			{
				bool InSpawnRoom = CF_IsEntityInSpawn(victim, TF2_GetClientTeam(victim));

				if(!InSpawnRoom)
				{	
					bool IgnoreLoSPenalty = TargetOutlined[victim][client] && PenaltyIngore;

					if(!CF_HasLineOfSight(playerPos, enemyPos, _, playerPos, client) && !IgnoreLoSPenalty)
					{
						float dmgChange = CF_GetArgF(client, SHADOW, abilityName, "laser_damage_penalty_multi_los", 0.5);
						totalDamage *= dmgChange;
					}
					
					float fallOff_Start = CF_GetArgF(client, SHADOW, abilityName, "laser_falloff_start", 1.0), 
					fallOff_End = CF_GetArgF(client, SHADOW, abilityName, "laser_falloff_end", 0.35), 
					fallOff_MaxDist = CF_GetArgF(client, SHADOW, abilityName, "laser_falloff_maxDistance", 1250.0);
					if(fallOff_Start < 1.0)
					{
						totalDamage *= CalculateFallOff(playerPos, enemyPos, fallOff_Start, fallOff_End, fallOff_MaxDist);
					}

					bool Invuln = IsInvuln(victim);

					if(!MaxPenetrations)
					{
						if(Invuln)
							continue;

						SDKHooks_TakeDamage(victim, Laser.client, Laser.client, totalDamage, Laser.damagetype, -1, NULL_VECTOR);
					}
					else if(MaxPenetrations > 0)
					{
						if(Penetrations[client] >= MaxPenetrations || Invuln)
						{
							continue;
						}

						SDKHooks_TakeDamage(victim, Laser.client, Laser.client, totalDamage, Laser.damagetype, -1, NULL_VECTOR);

						Penetrations[client]++;
					}
				}
				else if(InSpawnRoom)
				{
					PrintCenterText(client, "You hit a target inside their spawn room, no damage to them!");
				}
			}
		}
	}
	delete Victims;

	float beamLife = 0.15;
	TE_SetupBeamPoints(Laser.Start_Point, Laser.End_Point, BeamLaser, 0, 0, 0, beamLife, width, width, 1, 0.0, TF2_GetClientTeam(client) == TFTeam_Red ? RedGlow : BlueGlow, 0);
	TE_SendToAll();
	TE_SetupBeamPoints(Laser.Start_Point, Laser.End_Point, BeamLaser, 0, 0, 0, beamLife, width, width, 1, 0.0, TF2_GetClientTeam(client) == TFTeam_Red ? RedGlow : BlueGlow, 0);
	TE_SendToAll();	
}

//////////////////////////////////////
////////////  BACKSTAB   ////////////
////////////////////////////////////

//// BACKSTAB LOGIC
//// TAKEN FROM GENTLESPY:
bool b_StabsEnabled[MAXTF2PLAYERS] = { false, ... };
bool b_DoCustomRagdoll[MAXTF2PLAYERS] = { false, ... };

float f_NextStab[MAXTF2PLAYERS] = { 0.0, ... };
float f_StabDMG[MAXTF2PLAYERS] = { 0.0, ... };
float f_StabDMG_Exposed[MAXTF2PLAYERS] = { 0.0, ... };
float f_StabDelay[MAXTF2PLAYERS] = { 0.0, ... };
float f_StabDelay_Lethal[MAXTF2PLAYERS] = { 0.0, ... };

int i_StabMode[MAXTF2PLAYERS] = { 0, ... };
int i_StabSlot[MAXTF2PLAYERS] = { -1, ... };
int i_StabSlot_Lethal[MAXTF2PLAYERS] = { -1, ... };
int i_StabRagdoll[MAXTF2PLAYERS] = { 0, ... };

public void PrepareStabs(int client, char abilityName[255])
{
	b_StabsEnabled[client] = true;
	f_StabDMG[client] = CF_GetArgF(client, SHADOW, abilityName, "damage", 150.0);
	f_StabDMG_Exposed[client] = CF_GetArgF(client, SHADOW, abilityName, "damage_exposed", 250.0);
	i_StabMode[client] = CF_GetArgI(client, SHADOW, abilityName, "damage_mode", 0);
	i_StabSlot[client] = CF_GetArgI(client, SHADOW, abilityName, "ability", -1);
	i_StabSlot_Lethal[client] = CF_GetArgI(client, SHADOW, abilityName, "ability_lethal", 11);
	f_StabDelay[client] = CF_GetArgF(client, SHADOW, abilityName, "delay", 3.0);
	f_StabDelay_Lethal[client] = CF_GetArgF(client, SHADOW, abilityName, "delay_lethal", 0.0);
	i_StabRagdoll[client] = CF_GetArgI(client, SHADOW, abilityName, "ragdoll", 0);
	f_NextStab[client] = 0.0;
}

public void Stabs_ApplyMeleeCooldown(int client, float delay)
{
	int weapon = GetPlayerWeaponSlot(client, 2);
	if (!IsValidEntity(weapon))
		return;

	float gt = GetGameTime();
	f_NextStab[client] = gt + delay;

	int viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	int melee = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
				
	if (IsValidEntity(viewmodel))
	{
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", gt + delay);
		SetEntPropFloat(client, Prop_Send, "m_flNextAttack", gt + delay);
						
		DataPack pack = new DataPack();
		CreateDataTimer(0.1, Stabs_DoMeleeStunSequence, pack, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack, EntIndexToEntRef(viewmodel));
		WritePackCell(pack, melee);
	}
}

public Action Stabs_DoMeleeStunSequence(Handle timely, DataPack pack)
{
	ResetPack(pack);
	int viewmodel = EntRefToEntIndex(ReadPackCell(pack));

	if(viewmodel != INVALID_ENT_REFERENCE)
	{
		int animation = 38;
		switch(ReadPackCell(pack))
		{
			case 225, 356, 423, 461, 574, 649, 1071, 30758:  //Your Eternal Reward, Conniver's Kunai, Saxxy, Wanga Prick, Big Earner, Spy-cicle, Golden Frying Pan, Prinny Machete
				animation=12;

			case 638:  //Sharp Dresser
				animation=32;
		}
		SetEntProp(viewmodel, Prop_Send, "m_nSequence", animation);
	}

	return Plugin_Continue;
}

public void CF_OnCheckCanBackstab(int attacker, int victim, bool &forceStab, bool &result)
{ 
	if (!b_StabsEnabled[attacker] || IsABuilding(victim) || !CF_IsValidTarget(victim, grabEnemyTeam(attacker)))
		return;

	float gt = GetGameTime();

	result = gt >= f_NextStab[attacker];
}

public void CF_OnBackstab(int attacker, int victim, float &damage)
{
	if (b_StabsEnabled[attacker])
	{
		damage = !IsTargetOutlined(victim) ? f_StabDMG[attacker] : f_StabDMG_Exposed[attacker];
		if (i_StabMode[attacker] > 0)
		{
			if (IsValidClient(victim))
				damage *= float(GetEntProp(victim, Prop_Data, "m_iMaxHealth"));
			else
				damage *= float(GetEntProp(victim, Prop_Send, "m_iMaxHealth"));
		}

		if (IsValidClient(victim))
		{
			float current = float((IsValidClient(victim) ? GetEntProp(victim, Prop_Send, "m_iHealth") : GetEntProp(victim, Prop_Data, "m_iHealth")));
			if (damage >= current)
			{
				CF_DoAbilitySlot(attacker, i_StabSlot_Lethal[attacker]);
				if (f_StabDelay_Lethal[attacker] > 0.0)
					Stabs_ApplyMeleeCooldown(attacker, f_StabDelay_Lethal[attacker]);
				
				b_DoCustomRagdoll[attacker] = true;
				CF_PlayRandomSound(attacker, attacker, "sound_backstab_lethal");
			}
			else
			{
				CF_DoAbilitySlot(attacker, i_StabSlot[attacker]);
				if (f_StabDelay[attacker] > 0.0)
					Stabs_ApplyMeleeCooldown(attacker, f_StabDelay[attacker]);

				EmitSoundToAll(SOUND_STAB_NONLETHAL, attacker, _, _, _, _, GetRandomInt(90, 110));
			}
		}
	}
}

public void PNPC_OnPlayerRagdoll(int victim, int attacker, int inflictor, bool &freeze, bool &cloaked, bool &ash, bool &gold, bool &shocked, bool &burning, bool &gib)
{
	if (b_DoCustomRagdoll[attacker])
	{
		switch(i_StabRagdoll[attacker])
		{
			case 1:
				freeze = true;
			case 2:
				cloaked = true;
			case 3:
				ash = true;
			case 4:
				gold = true;
			case 5:
				shocked = true;
			case 6:
				burning = true;
			case 7:
				gib = true;
		}

		b_DoCustomRagdoll[attacker] = false;
	}
}

//////////////////////////////////////
////////////  STEALTH   /////////////
////////////////////////////////////

static bool StealthActive[MAXTF2PLAYERS]={false,...};
static bool Stealth_AllowUltGainCD[MAXTF2PLAYERS]={false,...};
static float StealthDmgBonus[MAXTF2PLAYERS][2];
static float StealthUltGain[MAXTF2PLAYERS]={0.0,...};
static float StealthUltGain_HS[MAXTF2PLAYERS]={0.0,...};

public void PrepareStealth(int client, char abilityName[255])
{
	StealthActive[client] = true;
	
	Stealth_AllowUltGainCD[client] = view_as<bool>(CF_GetArgI(client, SHADOW, abilityName, "stealth_ult_ignore_cd_gain", 1));
	StealthDmgBonus[client][0] = CF_GetArgF(client, SHADOW, abilityName, "stealth_damage_bonus", 1.5);
	StealthDmgBonus[client][1] = CF_GetArgF(client, SHADOW, abilityName, "stealth_damage_bonus_hs", 1.5);
	StealthUltGain[client] = CF_GetArgF(client, SHADOW, abilityName, "stealth_ult_gain", 1.0);
	StealthUltGain_HS[client] = CF_GetArgF(client, SHADOW, abilityName, "stealth_ult_gain_hs", 1.0);
}

////////////////////////////////////
/////////// ACTIONS	///////////////
//////////////////////////////////

public void TF2_OnConditionAdded(int client, TFCond cond)
{
	if(CloakActive[client])
	{
		if(cond == TFCond_Cloaked)
		{
			CF_DoAbilitySlot(client, CloakSlot[client][0]);
			CF_PlayRandomSound(client, client, "sound_cloaked");
			//CF_PlayRandomSound(client, client, "sound_cloaked_effect");
		}
	}
}

public void TF2_OnConditionRemoved(int client, TFCond cond)
{
	if(CloakActive[client])
	{
		if(cond == TFCond_Cloaked)
		{
			float CloakMeter = TF2_GetCloakLevel(client);
			CF_DoAbilitySlot(client, CloakSlot[client][1]);
			CF_PlayRandomSound(client, client, "sound_decloak");
			if(CloakMeter < CloakMinUse[client])
			{
				if(CloakCanUse[client])
				{
					ButtonInitialDelay[client] = 1.35 + GetGameTime();
					SetEntPropFloat(client, Prop_Send, "m_flStealthNextChangeTime", GetGameTime()+9999.0);
					CloakCanUse[client] = false;
				}
			}
			//CF_PlayRandomSound(client, client, "sound_decloak_effect");
		}
	}
}

static void EquipAgent(int client)
{
	if(!IsValidClient(client))
		return;

	if (CF_HasAbility(client, SHADOW, BOMB))
	{
		PrepareBombs(client, BOMB);
	}
	if (CF_HasAbility(client, SHADOW, UAV))
	{
		PrepareUAV(client, UAV);
	}
	if (CF_HasAbility(client, SHADOW, CLOAK))
	{
		PrepareCloak(client, CLOAK);
	}
	if (CF_HasAbility(client, SHADOW, PENETRATOR))
	{
		PreparePenetrator(client, PENETRATOR);
	}
	if (CF_HasAbility(client, SHADOW, BACKSTAB))
	{
		PrepareStabs(client, BACKSTAB);
	}
	if (CF_HasAbility(client, SHADOW, STEALTH))
	{
		PrepareStealth(client, STEALTH);
	}
}

static void ResetAgent(int client)
{
	UAV_Destroy(client);
	UAV_RemoveOutlines(client);
	
	BombActive[client] = false;
	UAVActive[client] = false;
	b_StabsEnabled[client] = false;
	UAVTarget[client] = -1;
	
	int entity = EntRefToEntIndex(BombPlantedOn[client]);
	if(IsValidEntity(entity))
	{
		if(BombOwner[entity] == client)
		{
			SetEntityRenderColor(entity, 255, 255, 255, 255);

			HasABomb[entity] = false;
			BombOwner[entity] = -1;
			BombPlantedOn[client] = -1;
		}
	}
}

public void CF_OnCharacterCreated(int client)
{
	EquipAgent(client);
}

public void CF_OnCharacterRemoved(int client)
{
	ResetAgent(client);
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, SHADOW))
		return;
		
	if (StrContains(abilityName, BOMB) != -1)
		Bombs_Spawn(client, abilityName);

	if (StrContains(abilityName, UAV) != -1)
		UAV_SpawnDrone(client, abilityName);

	if (StrContains(abilityName, PENETRATOR) != -1)
		Penetrator_Initiate(client, abilityName);
}

public Action CF_OnTakeDamageAlive_Bonus(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
	if (!IsValidClient(attacker) || !IsValidClient(victim))
		return Plugin_Continue;
		
	Action ReturnValue = Plugin_Continue;
	
	if (StealthActive[attacker])
	{
		if(IsBehindAndFacingTarget(attacker, victim))
		{
			bool ignoreCD = Stealth_AllowUltGainCD[attacker];
			float newDmg = 0.0;

			float hsBonus = StealthDmgBonus[attacker][1], 
			normalBonus = StealthDmgBonus[attacker][0];

			if(damagecustom == TF_CUSTOM_HEADSHOT)
			{
				CF_GiveUltCharge(attacker, StealthUltGain_HS[attacker], CF_ResourceType_Percentage, ignoreCD);

				if(hsBonus > 0.0)
					newDmg += hsBonus;
			}
			else if(damagetype & DMG_BULLET)
			{
				CF_GiveUltCharge(attacker, StealthUltGain[attacker], CF_ResourceType_Percentage, ignoreCD);

				if(normalBonus > 0.0)
					newDmg += normalBonus;
			}

			damage *= (1.0 + newDmg);

			ReturnValue = Plugin_Changed;
		}
	}
	
	return ReturnValue;
}

public Action CF_OnTakeDamageAlive_Post(int victim, int attacker, int inflictor, float damage, int weapon)
{
	if (!IsValidClient(attacker) || !IsABuilding(victim, true))
		return Plugin_Continue;
	
	if(IsABuilding(victim, view_as<bool>(BombOnNPC[attacker])))
	{
		Bombs_PlantOnEntity(victim, attacker);
	}

	return Plugin_Continue;
}

public Action CF_OnFakeMediShieldDamaged(int shield, int attacker, int inflictor, float &damage, int &damagetype, int owner)
{
	if (!IsValidClient(attacker) || IsValidMulti(owner, false, _, true, TF2_GetClientTeam(attacker)))
		return Plugin_Continue;
	
	return Plugin_Continue;
}

static void UAV_ChangeOutlineColor(int client, int target)
{
	if(!IsValidMulti(client) || !IsValidMulti(target))
	{
		UAV_DeleteOutline_Void(client, target);
		return;
	}

	bool Outlined = TargetOutlined[target][client];
	if(!Outlined)
	{
		return;
	}

	if(UAV_OutlineColorDelay[client] < GetGameTime())
	{
		UAV_OutlineColorDelay[client] = GetGameTime() + 0.1;
		
		int outline = EntRefToEntIndex(GlowId[target]);
		if(IsValidEntity(outline))
		{
			int glow[4];
			if(TF2_GetClientTeam(target) == TFTeam_Red)
			{
				glow = RedGlow;
			}
			else
			{
				glow = BlueGlow;
			}

			int color[4];
			color = glow;
			color[3] = RoundFloat(255.0 * ((OutlineCurrentFadeTime[client] - GetGameTime()) / OutlineFadeTime[client]));

			iGlowEntity Glow;
			Glow.entity = target;
			Glow.ChangeColor(color);

			if(color[3] < 50)
			{
				TargetOutlined[target][client] = false;

				iGlowEntity Glow2;
				Glow2.entity = target;
				Glow2.Delete();

				if(UAVTarget[client] == target)
					UAVTarget[client] = -1;

				return;
			}
		}
	}
}

static void UAV_DeleteOutline_Void(int client, int target)
{
	TargetOutlined[target][client] = false;

	iGlowEntity Glow;
	Glow.entity = target;
	Glow.Delete();

	if(UAVTarget[client] == target)
		UAVTarget[client] = -1;
}

public void OnEntityDestroyed(int entity)
{
	if(IsValidEntity(entity) && entity > 0 && entity <= MAXENTITIES)
	{
		if(IsValidClient(BombOwner[entity]))
		{
			// CF_ApplyAbilityCooldown(BombOwner[entity], 12.0, M3, true);
			// CF_UnblockAbilitySlot(BombOwner[entity], M3);
			// BombPhase[BombOwner[entity]] = BOMB_IDLE;
		}

		BombOwner[entity] = -1;
		BombPlantedOn[entity] = -1;
		HasABomb[entity] = false;
	}
}

public void CF_OnHUDDisplayed(int client, char HUDText[255], int &r, int &g, int &b, int &a)
{
	if(!CF_HasAbility(client, SHADOW, BOMB))
		return;
	
	int phase = BombPhase[client];
	switch(phase)
	{
		case BOMB_PLANTED:
		{
			Format(HUDText, sizeof(HUDText), "DETONATION AVAILABLE: [Spec. Attack]\n%s", HUDText);
		}
		case BOMB_DETONATING:
		{
			Format(HUDText, sizeof(HUDText), "DETONATION IN: (%.1fs)\n%s", BombDetonationTime[client]-GetGameTime(), HUDText);
		}
	}
}

public Action CF_OnPlayerRunCmd(int client, int &buttons)
{
	if(!IsValidMulti(client) || !CF_HasAbility(client, SHADOW, BOMB))
		return Plugin_Continue;

	char buffer[255];
	bool m2 = (buttons & IN_ATTACK2) != 0;
	bool m3 = (buttons & IN_ATTACK3) != 0;

	if(IsValidMulti(UAVTarget[client]))
	{
		UAV_ChangeOutlineColor(client, UAVTarget[client]);
	}
	
	int entity = EntRefToEntIndex(BombPlantedOn[client]);
	if(IsValidEntity(entity))
	{
		if(BombOwner[entity] == client)
		{
			switch(BombPhase[client])
			{
				case BOMB_PLANTED:
				{
					if(!m3 && M3Pressed[client])
					{
						BombPhase[client] = BOMB_DETONATING;
						float time = CF_GetArgF(client, SHADOW, BOMB, "bomb_detonation_time", 1.5);
						BombDetonationTime[client] = time + GetGameTime();


						if(TF2_GetClientTeam(client) == TFTeam_Blue)
						{
							SetEntityRenderColor(entity, 3, 204, 175, 255);
						}
						else
						{
							SetEntityRenderColor(entity, 175, 65, 84, 255);
						}
					}
				}
				case BOMB_DETONATING:
				{
					Bombs_TETracking(client, entity);
				}
			}
		}

		M3Pressed[client] = m3;
	}

	if(CF_HasAbility(client, SHADOW, CLOAK))
	{
		bool Cloaked = IsCloaked(client);

		if(ButtonInitialDelay[client] < GetGameTime())
		{
			if(!m2 && M2Pressed[client] && (!Cloaked || !TF2_IsPlayerInCondition(client, TFCond_CloakFlicker)))
			{
				switch(CloakCanUse[client])
				{
					case false:
					{
						FormatEx(buffer, sizeof(buffer), "%.0fPRCNT cloak meter required!", CloakMinUse[client]);

						ReplaceString(buffer, sizeof(buffer), "PRCNT", "%");
						
						PrintCenterText(client, "%s", buffer);

						EmitSoundToClient(client, SOUND_CLOAK_BLOCKED);
						EmitSoundToClient(client, SOUND_CLOAK_BLOCKED);

						ButtonInitialDelay[client] = 0.5 + GetGameTime();
					}
				}
			}

			M2Pressed[client] = m2;
		}
	}

	return Plugin_Continue;
}

public Action CF_OnM3Used(int client)
{
	if(BombPhase[client] != BOMB_IDLE)
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action CF_Agent_OutlineTransmit(int entity, int client)
{
	// kill the glow if the owner don't exist
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	if (!IsValidClient(owner))
	{
		RemoveEntity(entity);
		return Plugin_Handled;
	}
	
	int target = GetEntPropEnt(entity, Prop_Send, "m_hTarget");
	if (!IsValidEntity(target))
	{
		RemoveEntity(entity);
		return Plugin_Handled;
	}
	
	// this is necessary for the glow to be hidden from other clients
	SetEntityTransmitState(entity, FL_EDICT_FULLCHECK);
	
	// force glow target to transmit to ensure that the glow is not cut off by visleaves
	SetEdictFlags(target, GetEdictFlags(target)|FL_EDICT_ALWAYS);

	switch(UAV_Mode[owner])
	{
		case TARGETING:
		{
			switch(UAV_ShowScanOutline_Teammates[owner])
			{
				case true:
				{
					if(GetTeam(client) != GetTeam(entity))
					{
						// only transmit to teammates!
						return Plugin_Handled;
					}
				}
				default:
				{
					if (client != owner)
					{
						// only transmit the outline to the owner
						return Plugin_Handled;
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

public Action Text_Transmit(int entity, int client)
{
	SetEdictFlags(entity, GetEdictFlags(entity)&(~FL_EDICT_ALWAYS));
	if (client != GetClientOfUserId(Text_Owner[entity]))
 	{
 		return Plugin_Handled;
	}
 		
	return Plugin_Continue;
}

//////////////////////
////   STOCKS	/////
////////////////////

static void GetBeamDrawStartPoint(int client, float startPoint[3])
{
	GetClientEyePosition(client, startPoint);
	float angles[3];
	GetClientEyeAngles(client, angles);
	startPoint[2] -= 25.0;
	if (0.0 == Offset[client][0] && 0.0 == Offset[client][1] && 0.0 == Offset[client][2])
	{
		return;
	}
	float tmp[3];
	float actualBeamOffset[3];
	tmp[0] = Offset[client][0];
	tmp[1] = Offset[client][1];
	tmp[2] = 0.0;
	VectorRotate(tmp, angles, actualBeamOffset);
	actualBeamOffset[2] = Offset[client][2];
	startPoint[0] += actualBeamOffset[0];
	startPoint[1] += actualBeamOffset[1];
	startPoint[2] += actualBeamOffset[2];
}

stock void StopFiringPrimary(int client, int slot = 0, float duration = 9999.0)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(weapon))
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + duration);
}

// stock void StopFiringSecondary(int client)
// {
// 	int weapon = GetPlayerWeaponSlot(client, slot);
// 	if (IsValidEntity(weapon))
// 		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + duration);

// }
stock float M3Cooldowns(int client)
{
	char conf[255];
	CF_GetPlayerConfig(client, conf, sizeof(conf));
	ConfigMap map = new ConfigMap(conf);
	if (map == null)
	{
		return 0.0;
	}
		
	ConfigMap subsection = map.GetSection("character.m3_ability");
	if (subsection == null)
	{
		DeleteCfg(map);
		return 0.0;
	}

	float CD = GetFloatFromCFGMap(subsection, "cooldown", 0.0);
	DeleteCfg(map);

	return CD;
}

stock void SetAttributeValue(int entity, int attribute, float value)
{
	if (!IsValidEntity(entity))
		return;
		
	Address addy = TF2Attrib_GetByDefIndex(entity, attribute);
	if (addy == Address_Null)
		return;
		
	TF2Attrib_SetValue(addy, value);
}

/**
 * @param client -  Client index input.
 * @param v[3]   -  Location output.
 */
stock void GetAbsOrigin_main(int client, float v[3])
{
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", v);
}

/**
 *  @param Origin - Input
 *  @param Target - Input
 *  @param EndLoc - Output
 *  @param Speed - How far it goes, in HU.
 */
stock void Move_Vector_Towards_Target(float Origin[3], float Target[3], float EndLoc[3], float Speed)
{
	float Angles[3];
	MakeVectorFromPoints(Origin, Target, Angles);
	GetVectorAngles(Angles, Angles);

	Get_Fake_Forward_Vec(Speed, Angles, EndLoc, Origin);
}
/**
 *  @param Range - self explanitory.
 *  @param Angles - twoards where should it go
 *  @param Vec_Target - Output Vector.
 *  @param Pos - Input Vector
 */
stock void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}

void MoveEntity(int entity, float loc[3], float Ang[3], bool old=false)
{
	if(IsValidEntity(entity))	
	{
		if(old)
		{
			//the version bellow creates some "funny" movements/interactions..
			float vecView[3], vecFwd[3], Entity_Loc[3], vecVel[3];
					
			MakeVectorFromPoints(Entity_Loc, loc, vecView);
			GetVectorAngles(vecView, vecView);
			
			float dist = GetVectorDistance(Entity_Loc, loc);

			GetAngleVectors(vecView, vecFwd, NULL_VECTOR, NULL_VECTOR);
		
			Entity_Loc[0]+=vecFwd[0] * dist;
			Entity_Loc[1]+=vecFwd[1] * dist;
			Entity_Loc[2]+=vecFwd[2] * dist;
			
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vecFwd);
			
			SubtractVectors(Entity_Loc, vecFwd, vecVel);
			ScaleVector(vecVel, 10.0);

			TeleportEntity(entity, NULL_VECTOR, Ang, vecVel);
		}
		else
		{
			float flNewVec[3], flRocketPos[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flRocketPos);
			float Ratio = (GetVectorDistance(loc, flRocketPos))/250.0;

			if(Ratio<0.075)
				Ratio=0.075;

			float flSpeedInit = 1250.0*Ratio;
		
			SubtractVectors(loc, flRocketPos, flNewVec);
			NormalizeVector(flNewVec, flNewVec);
			
			float flAng[3];
			GetVectorAngles(flNewVec, flAng);
			
			ScaleVector(flNewVec, flSpeedInit);
			TeleportEntity(entity, NULL_VECTOR, Ang, flNewVec);
		}
	}
}

stock void Proper_To_Groud_Clip(float vecHull[3], float StepHeight = 300.0, float vecorigin[3])
{
	float originalPostionTrace[3];
	float startPostionTrace[3];
	float endPostionTrace[3];
	endPostionTrace = vecorigin;
	startPostionTrace = vecorigin;
	originalPostionTrace = vecorigin;
	startPostionTrace[2] += StepHeight;
	endPostionTrace[2] -= 5000.0;

	float vecHullMins[3];
	vecHullMins = vecHull;

	vecHullMins[0] *= -1.0;
	vecHullMins[1] *= -1.0;
	vecHullMins[2] *= -1.0;

	Handle trace;
	trace = TR_TraceHullFilterEx( startPostionTrace, endPostionTrace, vecHullMins, vecHull, MASK_PLAYERSOLID,HitOnlyWorld, 0);
	if ( TR_GetFraction(trace) < 1.0)
	{
		// This is the point on the actual surface (the hull could have hit space)
		TR_GetEndPosition(vecorigin, trace);	
	}
	vecorigin[0] = originalPostionTrace[0];
	vecorigin[1] = originalPostionTrace[1];

	float VecCalc = (vecorigin[2] - startPostionTrace[2]);
	if(VecCalc > (StepHeight - (vecHull[2] + 2.0)) || VecCalc > (StepHeight - (vecHull[2] + 2.0)) ) //This means it was inside something, in this case, we take the normal non traced position.
	{
		vecorigin[2] = originalPostionTrace[2];
	}

	delete trace;
	//if it doesnt hit anything, then it just does buisness as usual
}

stock void MakeObjectIntangeable(int entity)
{
	SetEntityCollisionGroup(entity, 26); //Dont Touch Anything.
	SetEntProp(entity, Prop_Send, "m_usSolidFlags", 12); 
	SetEntProp(entity, Prop_Data, "m_nSolidType", 6);
}

//Fades the alpha of a given entity and removes it if the alpha falls below 1.
public void Toss_FadeOutGib(int ref)
{
	int gear = EntRefToEntIndex(ref);
	if (!IsValidEntity(gear))
		return;
		
	int r, g, b, a;
	GetEntityRenderColor(gear, r, g, b, a);
	a -= 1;
	if (a < 1)
		RemoveEntity(gear);
	else
	{
		SetEntityRenderColor(gear, r, g, b, a);
		RequestFrame(Toss_FadeOutGib, ref);
	}
}
public bool TraceWorldOrValidTarget(int entity, int mask, int client)
{
	if(IsValidClient(entity)) //Valid clients
	{
		if(IsPlayerAlive(entity) && GetTeam(entity) != GetTeam(client)) //Enemies only.
		{
			return true;
		}
	}
	
	return false;
}

public bool HitAll(int entity, int mask, int client)
{
	return false;
}

/**
 * Gives an entity an outline.
 *
 * @param iEnt		Entity to outline.
 * @param team		Entity's team.
 
 * @error Invalid entity index.
 
 * @return The entity index of the outline itself.
 */
stock int TF2_CreateGlow_Custom(int iEnt, int Color[4])
{
	char oldEntName[64];
	GetEntPropString(iEnt, Prop_Data, "m_iName", oldEntName, sizeof(oldEntName));
	
	char strName[126], strClass[64];
	GetEntityClassname(iEnt, strClass, sizeof(strClass));
	Format(strName, sizeof(strName), "%s%i", strClass, iEnt);
	DispatchKeyValue(iEnt, "targetname", strName);
	
	int ent = CreateEntityByName("tf_glow");
	if(IsValidEntity(ent))
	{
		DispatchKeyValue(ent, "targetname", "RainbowGlow");
		DispatchKeyValue(ent, "target", strName);
		DispatchKeyValue(ent, "Mode", "0");
		DispatchSpawn(ent);
		
		AcceptEntityInput(ent, "Enable");
		
		//Change name back to old name because we don't need it anymore.
		SetEntPropString(iEnt, Prop_Data, "m_iName", oldEntName);

		SetVariantColor(Color);

		AcceptEntityInput(ent, "SetGlowColor");
		
		return ent;
	}
	
	return -1;
}

stock float TF2_GetCloakLevel(int client)
{
	if(!IsValidClient(client))
		return -1.0;

	float value;

	if(GetEntPropFloat(client, Prop_Send, "m_flCloakMeter"))
	{
		value = GetEntPropFloat(client, Prop_Send, "m_flCloakMeter");
	}

	return value;
}

stock void TF2_SetCloakLevel(int client, float amount, bool cap = false)
{
	if(!IsValidClient(client))
		return;

	if (GetEntPropFloat(client, Prop_Send, "m_flCloakMeter"))
	{
		SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", amount);

		if (cap && TF2_GetCloakLevel(client) > 100.0)
		{
			SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", 100.0);
		}
		else if (cap && TF2_GetCloakLevel(client) < 0.0)
		{
			SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", 0.0);
		}
	}
}

stock void TF2_AddCloakLevel(int client, float amount, bool cap = false)
{
	if(!IsValidClient(client))
		return;

	TF2_SetCloakLevel(client, (TF2_GetCloakLevel(client) + amount), cap);
}

stock void TF2_RemoveCloakLevel(int client, float amount, bool cap = false)
{
	if(!IsValidClient(client))
		return;
		
	TF2_SetCloakLevel(client, (TF2_GetCloakLevel(client) - amount), cap);
}

static int i_traced_ents_amt;
enum struct Generic_Laser_Trace
{
	int client;
	int target;
	float Start_Point[3];
	float End_Point[3];
	float Radius;
	float Damage;
	int damagetype;

	bool player_check;

	bool trace_hit;
	bool trace_hit_enemy;

	float Custom_Hull[3];

	void DoForwardTrace_Basic(float Dist=-1.0, TraceEntityFilter Func_Trace = INVALID_FUNCTION)
	{
		if(Func_Trace==INVALID_FUNCTION)
			Func_Trace = Generic_Laser_BEAM_TraceWallsOnly;

		this.target = -1;

		float Angles[3], startPoint[3], Loc[3];
		GetClientEyeAngles(this.client, Angles);
		GetClientEyePosition(this.client, startPoint);

		CF_StartLagCompensation(this.client);
		Handle trace = TR_TraceRayFilterEx(startPoint, Angles, MASK_PLAYERSOLID, RayType_Infinite, TraceWorldOrValidTarget, this.client);
		CF_EndLagCompensation(this.client);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(Loc, trace);

			int TracedEntity = TR_GetEntityIndex(trace);
			if(TracedEntity > 0 && TracedEntity <= MaxClients)
			{
				this.target = TracedEntity;
			}

			if(Dist !=-1.0)
			{
				ConformLineDistance(Loc, startPoint, Loc, Dist);
			}

			this.Start_Point = startPoint;
			this.End_Point = Loc;
			this.trace_hit=true;

			delete trace;
		}
		else
		{
			delete trace;
		}
	}
	void DoForwardTrace_Custom(float Angles[3], float startPoint[3], float Dist=-1.0, TraceEntityFilter Func_Trace = INVALID_FUNCTION)
	{
		if(Func_Trace==INVALID_FUNCTION)
			Func_Trace = Generic_Laser_BEAM_TraceWallsOnly;

		float Loc[3];
		if(this.client !=-1)
			CF_StartLagCompensation(this.client);
		Handle trace = TR_TraceRayFilterEx(startPoint, Angles, 11, RayType_Infinite, Func_Trace, this.client);
		if(this.client !=-1)
			CF_EndLagCompensation(this.client);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(Loc, trace);
			delete trace;

			if(Dist !=-1.0)
			{
				ConformLineDistance(Loc, startPoint, Loc, Dist);
			}
			this.Start_Point = startPoint;
			this.End_Point = Loc;
			this.trace_hit=true;
		}
		else
		{
			delete trace;
		}
	}

	void CleanEnumerator()
	{
		i_traced_ents_amt = 0;
		Zero(Generic_Laser_BEAM_HitDetected);
	}

	void EnumerateGetEntities(TraceEntityFilter Hull_TraceFunc = INVALID_FUNCTION)
	{
		if(Hull_TraceFunc==INVALID_FUNCTION)
			Hull_TraceFunc = Generic_Laser_BEAM_TraceUsers;

		float hullMin[3], hullMax[3];
		this.SetHull(hullMin, hullMax);
		
		if(this.client !=-1)
			CF_StartLagCompensation(this.client);
		Handle trace = TR_TraceHullFilterEx(this.Start_Point, this.End_Point, hullMin, hullMax, 1073741824, Hull_TraceFunc, this.client);	// 1073741824 is CONTENTS_LADDER?
		delete trace;
		if(this.client !=-1)
			CF_EndLagCompensation(this.client);
	}
	Queue GetEnumeratedEntityPop()
	{
		Queue Victims = new Queue();

		for (int loop = 0; loop < i_traced_ents_amt; loop++)
		{
			//so we don't have to loop through max ents worth of ents when we only have 1 valid
			int victim = Generic_Laser_BEAM_HitDetected[loop];
			if(victim)
				Victims.Push(victim);
		}

		return Victims;
	}

	void Deal_Damage_Basic(Function Attack_Function = INVALID_FUNCTION)
	{
		this.CleanEnumerator();
		this.EnumerateGetEntities();
		Queue Victims = this.GetEnumeratedEntityPop();
				
		while(!Victims.Empty)
		{
			int victim = Victims.Pop();
			if (victim)
			{
				this.trace_hit_enemy=true;
				if(this.player_check)
				{
					if(Attack_Function && Attack_Function != INVALID_FUNCTION)
					{	
						Call_StartFunction(null, Attack_Function);
						Call_PushCell(this.client);
						Call_PushCell(victim);
						Call_PushCell(this.damagetype);
						Call_PushFloat(this.Damage);
						Call_Finish();	
					}
				}
				else
				{
					float playerPos[3];
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);

					SDKHooks_TakeDamage(victim, this.client, this.client, this.Damage, this.damagetype, -1, NULL_VECTOR, playerPos);

					if(Attack_Function && Attack_Function != INVALID_FUNCTION)
					{	
						Call_StartFunction(null, Attack_Function);
						Call_PushCell(this.client);
						Call_PushCell(victim);
						Call_PushCell(this.damagetype);
						Call_PushFloat(this.Damage);
						Call_Finish();
					}
				}
			}
		}
		delete Victims;
	}
	void SetHull(float hullMin[3], float hullMax[3])
	{
		if(this.Custom_Hull[0] != 0.0 || this.Custom_Hull[1] != 0.0 || this.Custom_Hull[2] != 0.0)
		{
			hullMin[0] = -this.Custom_Hull[0];
			hullMin[1] = -this.Custom_Hull[1];
			hullMin[2] = -this.Custom_Hull[2];
		}
		// else
		// {
		// 	hullMin[0] = -this.Radius;
		// 	hullMin[1] = hullMin[0];
		// 	hullMin[2] = hullMin[0];
		// }
		hullMax[0] = -hullMin[0];
		hullMax[1] = -hullMin[1];
		hullMax[2] = -hullMin[2];
	}
}
stock float CalculateFallOff(float StartLoc[3], float EndLoc[3], float falloffstart, float falloffmax, float maxDist)
{
	float dist = GetVectorDistance(StartLoc, EndLoc);
	//FF2Dbg("Input damage: %f", Damage);
	if (dist > falloffstart)
	{
		if(dist > maxDist)
			return falloffmax;

		float diff = dist - falloffstart;
		float rad = maxDist - falloffstart;
		
		return (1.0 - ((diff/rad) * falloffmax));
	}
	return 1.0;
}

stock bool Generic_Laser_BEAM_TraceWallsOnly(int entity, int contentsMask, int client)
{
	return !entity;
}
stock bool Generic_Laser_BEAM_TraceWallAndEnemies(int entity, int contentsMask, int client)
{
	if(CF_IsValidTarget(entity, grabEnemyTeam(client)))
		return true;
		

	return !entity;
}

bool Generic_Laser_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsValidEntity(entity))
	{
		if(client == -1 || CF_IsValidTarget(entity, grabEnemyTeam(client)))
		{
			for(int i=0 ; i < MAXENTITIES ; i++)
			{
				//don't retrace the same entity!
				if(Generic_Laser_BEAM_HitDetected[i] == entity)
					break;
					
				if(!Generic_Laser_BEAM_HitDetected[i])
				{
					i_traced_ents_amt++;	//so we don't have to loop through max ents worth of ents when we only have 1 valid
					Generic_Laser_BEAM_HitDetected[i] = entity;
					break;
				}
			}
		}
	}
	return false;
}

stock float ConformAxisValue(float src, float dst, float distCorrectionFactor)
{
	return src - ((src - dst) * distCorrectionFactor);
}
stock float DEG2RAD(float n)
{
	return n * 0.017453;
}

stock float DotProduct(float v1[3], float v2[4])
{
	return v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];
}

stock void VectorRotate2(float in1[3], float in2[3][4], float out[3])
{
	out[0] = DotProduct(in1, in2[0]);
	out[1] = DotProduct(in1, in2[1]);
	out[2] = DotProduct(in1, in2[2]);
}

stock void AngleMatrix(float angles[3], float matrix[3][4])
{
	float sr = 0.0;
	float sp = 0.0;
	float sy = 0.0;
	float cr = 0.0;
	float cp = 0.0;
	float cy = 0.0;
	sy = Sine(DEG2RAD(angles[1]));
	cy = Cosine(DEG2RAD(angles[1]));
	sp = Sine(DEG2RAD(angles[0]));
	cp = Cosine(DEG2RAD(angles[0]));
	sr = Sine(DEG2RAD(angles[2]));
	cr = Cosine(DEG2RAD(angles[2]));
	matrix[0][0] = cp * cy;
	matrix[1][0] = cp * sy;
	matrix[2][0] = -sp;
	float crcy = cr * cy;
	float crsy = cr * sy;
	float srcy = sr * cy;
	float srsy = sr * sy;
	matrix[0][1] = sp * srcy - crsy;
	matrix[1][1] = sp * srsy + crcy;
	matrix[2][1] = sr * cp;
	matrix[0][2] = sp * crcy + srsy;
	matrix[1][2] = sp * crsy - srcy;
	matrix[2][2] = cr * cp;
	matrix[0][3] = 0.0;
	matrix[1][3] = 0.0;
	matrix[2][3] = 0.0;
}

stock void VectorRotate(float inPoint[3], float angles[3], float outPoint[3])
{
	float matRotate[3][4];
	AngleMatrix(angles, matRotate);
	VectorRotate2(inPoint, matRotate, outPoint);
}

stock float ClampBeamWidth(float w) { return w > 128.0 ? 128.0 : w; }
stock int GetR(int c) { return abs((c>>16)&0xff); }
stock int GetG(int c) { return abs((c>>8 )&0xff); }
stock int GetB(int c) { return abs((c	)&0xff); }
stock int abs(int x) { return x < 0 ? -x : x; }
// if the distance between two points is greater than max distance allowed
// fills result with a new destination point that lines on the line between src and dst
stock void ConformLineDistance(float result[3], const float src[3], const float dst[3], float maxDistance, bool canExtend = false)
{
	float distance = GetVectorDistance(src, dst);
	if (distance <= maxDistance && !canExtend)
	{
		// everything's okay.
		result[0] = dst[0];
		result[1] = dst[1];
		result[2] = dst[2];
	}
	else
	{
		// need to find a point at roughly maxdistance. (FP irregularities aside)
		float distCorrectionFactor = maxDistance / distance;
		result[0] = ConformAxisValue(src[0], dst[0], distCorrectionFactor);
		result[1] = ConformAxisValue(src[1], dst[1], distCorrectionFactor);
		result[2] = ConformAxisValue(src[2], dst[2], distCorrectionFactor);
	}
}