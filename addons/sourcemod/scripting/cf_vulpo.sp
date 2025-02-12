#include <sourcemod>
#include <tf2_stocks>
#include <sdkhooks>
#include <cf_stocks>
#include <cf_include>
#include <tf2utils>
#include <fakeparticles>

#define MAXENTITIES	2048

#define AMP_MODEL	"models/buildables/amplifier_test/amplifier.mdl"

#define ABILITY_BUILDINGS	"vulpo_special_buildings"
#define ABILITY_CIRCUITAMMO	"vulpo_special_circuitammo"
#define ABILITY_MAJORSTEAM	"vulpo_rage_majorsteam"

static const char BotClassNames[][] =
{
	"",
	"scout",
	"sniper",
	"soldier",
	"demoman",
	"medic",
	"heavy",
	"pyro",
	"spy",
	"engineer"
};

char PluginName[255];
int BeamSprite;
int HaloSprite;

Handle AmpBuffTimer[MAXPLAYERS+1];
int AmpBuffEntRef[MAXPLAYERS+1];

Handle CircuitBuffTimer[MAXENTITIES];
int CircuitBuffEntRef[MAXENTITIES];

Handle MajorSteamTimer[MAXPLAYERS+1];
float MajorSteamEndAt[MAXPLAYERS+1];
TFClassType MajorSteamClass[MAXPLAYERS+1];
float MajorSteamAlarmAt;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	GetPluginFilename(null, PluginName, sizeof(PluginName));
	
	int pos = FindCharInString(PluginName, '/', true);
	if(pos != -1)
		strcopy(PluginName, sizeof(PluginName), PluginName[pos + 1]);
	
	pos = FindCharInString(PluginName, '\\', true);
	if(pos != -1)
		strcopy(PluginName, sizeof(PluginName), PluginName[pos + 1]);
	
	pos = FindCharInString(PluginName, '.', true);
	if(pos != -1)
		PluginName[pos] = '\0';
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	HookEvent("player_builtobject", OnBuildObject);
}

public void OnMapStart()
{
	BeamSprite = PrecacheModel("materials/sprites/laser.vmt");
	HaloSprite = PrecacheModel("materials/sprites/halo01.vmt");

	PrecacheSound("mvm/giant_soldier/giant_soldier_rocket_shoot.wav");
	PrecacheSound("mvm/giant_soldier/giant_soldier_rocket_shoot_crit.wav");
	PrecacheSound("mvm/giant_soldier/giant_soldier_explode.wav");
	PrecacheSound("mvm/giant_soldier/giant_soldier_loop.wav");
	PrecacheSound("mvm/mvm_tank_deploy.wav");
	PrecacheSound("mvm/mvm_deploy_giant.wav");
	PrecacheSound("mvm/mvm_cpoint_klaxon.wav");
	
	PrecacheScriptSound("MVM.GiantScoutStep");
	PrecacheScriptSound("MVM.GiantSoldierStep");
	PrecacheScriptSound("MVM.GiantPyroStep");
	PrecacheScriptSound("MVM.GiantDemomanStep");
	PrecacheScriptSound("MVM.GiantHeavyStep");
	PrecacheScriptSound("MVM.BotStep");
	PrecacheScriptSound("MVM.FallDamageBots");
}

public void OnClientDisconnect(int client)
{
	MajorSteamEndAt[client] = 0.0;
	
	if(AmpBuffTimer[client])
		TriggerTimer(AmpBuffTimer[client]);
	
	if(CircuitBuffTimer[client])
		TriggerTimer(CircuitBuffTimer[client]);
	
	if(MajorSteamTimer[client])
		TriggerTimer(MajorSteamTimer[client]);
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if(!StrEqual(pluginName, PluginName, false))
		return;
	
	if(StrContains(abilityName, ABILITY_MAJORSTEAM) != -1)
	{
		MajorSteamEffects(client, abilityName);
	}
}

public Action CF_OnTakeDamageAlive_Bonus(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
	if (!IsValidClient(attacker))
		return Plugin_Continue;
		
	if(AmpBuffTimer[attacker])
	{
		damage *= 1.15;
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public Action CF_OnTakeDamageAlive_Resistance(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
	if(CircuitBuffTimer[victim])
	{
		damage *= 0.85;
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public Action CF_OnPlayerKilled_Pre(int &victim, int &inflictor, int &attacker, char weapon[255], char console[255], int &custom, int deadRinger, int &critType, int &damagebits)
{
	if(AmpBuffTimer[victim])
		TriggerTimer(AmpBuffTimer[victim]);
	
	if(CircuitBuffTimer[victim])
		TriggerTimer(CircuitBuffTimer[victim]);
	
	MajorSteamEndAt[victim] = 0.0;
	return Plugin_Continue;
}

public Action CF_SoundHook(char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
	if(entity > 0 && entity <= MaxClients && MajorSteamTimer[entity])
	{
		level += (level / 4);

		TFClassType class = TF2_GetPlayerClass(entity);
		
		if(StrContains(sample, "mvm/", false) != -1)
		{
		}
		else if(StrContains(sample, "rocket_shoot", false) != -1)
		{
			strcopy(sample, sizeof(sample), StrContains(sample, "crit", false) == -1 ? "mvm/giant_soldier/giant_soldier_rocket_shoot.wav" : "mvm/giant_soldier/giant_soldier_rocket_shoot_crit.wav");
			return Plugin_Changed;
		}
		else if(StrContains(sample, "vo/", false) != -1)
		{
			static char buffer[PLATFORM_MAX_PATH];
			if(class != TFClass_Sniper && class != TFClass_Engineer && class != TFClass_Medic && class != TFClass_Spy)
			{
				ReplaceString(sample, sizeof(sample), "vo/", "vo/mvm/mght/", false);
				Format(buffer, sizeof(buffer), "%s_mvm_m", BotClassNames[view_as<int>(class)]);
			}
			else
			{
				ReplaceString(sample, sizeof(sample), "vo/", "vo/mvm/norm/", false);
				Format(buffer, sizeof(buffer), "%s_mvm", BotClassNames[view_as<int>(class)]);
			}
			
			ReplaceString(sample, sizeof(sample), BotClassNames[view_as<int>(class)], buffer);
			
			Format(buffer, sizeof(buffer), "sound/%s", sample);
			if(FileExists(buffer, true))
			{
				PrecacheSound(sample);
				return Plugin_Changed;
			}
		}
		else if(StrContains(sample, "player/footsteps/", false) != -1)
		{
			switch(class)
			{
				case TFClass_Scout:
				{
					EmitGameSoundToAll("MVM.GiantScoutStep", entity, flags);
					return Plugin_Stop;
				}
				case TFClass_Soldier:
				{
					EmitGameSoundToAll("MVM.GiantSoldierStep", entity, flags);
					return Plugin_Stop;
				}
				case TFClass_Pyro:
				{
					EmitGameSoundToAll("MVM.GiantPyroStep", entity, flags);
					return Plugin_Stop;
				}
				case TFClass_DemoMan:
				{
					EmitGameSoundToAll("MVM.GiantDemomanStep", entity, flags);
					return Plugin_Stop;
				}
				case TFClass_Heavy:
				{
					EmitGameSoundToAll("MVM.GiantHeavyStep", entity, flags);
					return Plugin_Stop;
				}
			}

			if(class != TFClass_Medic)
				EmitGameSoundToAll("MVM.BotStep", entity, flags);
			
			return Plugin_Stop;
		}
		else if(StrContains(sample, "player/pl_fallpain.wav", false) != -1)
		{
			EmitGameSoundToAll("MVM.FallDamageBots", entity, flags);
			return Plugin_Stop;
		}

		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public void CF_OnCharacterRemoved(int client, CF_CharacterRemovalReason reason)
{
	if(reason == CF_CRR_SWITCHED_CHARACTER)
	{
		FakeClientCommand(client, "destroy 0; destroy 1; destroy 2; destroy 3");
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(!StrContains(classname, "tf_projectile_mechanicalarmorb"))
	{
		SDKHook(entity, SDKHook_Spawn, OnShortCircuit);
	}
}

public void TF2_OnConditionRemoved(int client, TFCond condition)
{
	if(condition == TFCond_PreventDeath && MajorSteamTimer[client])
	{
		TF2_RemoveCondition(client, TFCond_MegaHeal);
		TF2_RemoveCondition(client, TFCond_Dazed);
		TF2_StunPlayer(client, 30.0, 1.0, TF_STUNFLAGS_NORMALBONK);
		TF2_AddCondition(client, TFCond_UberchargedHidden, 30.0);

		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon != -1)
			SetEntProp(weapon, Prop_Data, "m_iClip1", 0);
	}
}

Action OnShortCircuit(int entity)
{
	int owner = entity;
	do
	{
		owner = GetEntPropEnt(owner, Prop_Send, "m_hOwnerEntity");
	}
	while(owner != -1 && (owner < 1 || owner > MaxClients));

	if(owner == -1 || !CF_HasAbility(owner, PluginName, ABILITY_CIRCUITAMMO))
		return Plugin_Continue;
	
	float buff = CF_GetArgF(owner, PluginName, ABILITY_CIRCUITAMMO, "buff");

	float range = CF_GetArgF(owner, PluginName, ABILITY_CIRCUITAMMO, "range");
	range *= range;

	float pos1[3], pos2[3];
	GetEntPropVector(owner, Prop_Send, "m_vecOrigin", pos1);
	int team = GetEntProp(owner, Prop_Send, "m_iTeamNum");
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			if(team != GetClientTeam(client))
			{
				if(!TF2_IsPlayerInCondition(client, TFCond_Disguised) || GetEntProp(client, Prop_Send, "m_nDisguiseTeam") != team)
					continue;
			}

			GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < range)
			{
				if(client != owner)
				{
					int ammo = CreateEntityByName("tf_ammo_pack");
					if(ammo != -1)
					{
						SetVariantString("OnUser4 !self:Kill::0.1:1,0,1");
						AcceptEntityInput(ammo, "AddOutput");
						AcceptEntityInput(ammo, "FireUser4");

						DispatchSpawn(ammo);
						TeleportEntity(ammo, pos2);
					}
				}

				if(!CircuitBuffTimer[client])
					CircuitBuffEntRef[client] = EntIndexToEntRef(FPS_AttachFakeParticleToEntity(client, "root", "models/fake_particles/chaos_fortress/player_aura.mdl", 0, "rotate", 0.75, _, team == 2 ? 255 : 180, 180, team == 2 ? 180 : 255, 0));
				
				delete CircuitBuffTimer[client];
				CircuitBuffTimer[client] = CreateTimer(buff, Timer_CircuitBuff, client);
			}
		}
	}

	int obj = -1;
	while((obj=FindEntityByClassname(obj, "obj_*")) != -1)
	{
		if(GetEntProp(entity, Prop_Send, "m_iTeamNum") == team)
		{
			if(!CircuitBuffTimer[obj])
			{
				SDKUnhook(obj, SDKHook_OnTakeDamage, BuildingTakeDamage);
				SDKHook(obj, SDKHook_OnTakeDamage, BuildingTakeDamage);
				CircuitBuffEntRef[obj] = EntIndexToEntRef(FPS_AttachFakeParticleToEntity(entity, "root", "models/fake_particles/chaos_fortress/player_aura.mdl", 0, "rotate", 0.75, _, team == 2 ? 255 : 180, 180, team == 2 ? 180 : 255, 0));
			}
			
			delete CircuitBuffTimer[obj];
			CircuitBuffTimer[obj] = CreateTimer(buff, Timer_CircuitBuff, obj);

			if(HasEntProp(obj, Prop_Send, "m_iAmmoShells"))
				SetEntProp(obj, Prop_Send, "m_iAmmoShells", 200);

			if(HasEntProp(obj, Prop_Send, "m_iAmmoMetal"))
				SetEntProp(obj, Prop_Send, "m_iAmmoMetal", 400);
		}
	}

	//CF_GiveUltCharge(owner, 65.0, CF_ResourceType_Generic);

	RemoveEntity(entity);
	return Plugin_Stop;
}

void OnBuildObject(Event event, const char[] name, bool dontBroadcast)
{
	int entity = event.GetInt("index");
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
	if(owner != -1 && CF_HasAbility(owner, PluginName, ABILITY_BUILDINGS))
	{
		char prefix[16], buffer[255];
		switch(TF2_GetObjectType(entity))
		{
			case TFObject_Sentry:
				strcopy(prefix, sizeof(prefix), "sentry");
			
			case TFObject_Dispenser:
				strcopy(prefix, sizeof(prefix), "dispenser");
			
			case TFObject_Teleporter:
				strcopy(prefix, sizeof(prefix), "teleporter");
		}

		if(prefix[0])
		{
			FormatEx(buffer, sizeof(buffer), "%s_startlevel", prefix);
			int value = CF_GetArgI(owner, PluginName, ABILITY_BUILDINGS, buffer, -1);
			if(value >= 0)
			{
				if(GetEntProp(entity, Prop_Send, "m_iHighestUpgradeLevel") < value)
				{
					SetEntProp(entity, Prop_Send, "m_iUpgradeLevel", value);
					SetEntProp(entity, Prop_Send, "m_iHighestUpgradeLevel", value);
				}
			}
			
			FormatEx(buffer, sizeof(buffer), "%s_upgradecost", prefix);
			value = CF_GetArgI(owner, PluginName, ABILITY_BUILDINGS, buffer, -1);
			if(value >= 0)
				SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", value);
			
			FormatEx(buffer, sizeof(buffer), "%s_amplifier", prefix);
			value = CF_GetArgI(owner, PluginName, ABILITY_BUILDINGS, buffer, -1);
			if(value >= 0)
			{
				SetEntityModel(entity, AMP_MODEL);
				SetEntProp(entity, Prop_Send, "m_nSkin", GetEntProp(entity, Prop_Send, "m_nSkin") + 2);

				CreateTimer(0.1, Timer_AmpBuilding, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			}
			else
			{
				FormatEx(buffer, sizeof(buffer), "%s_upgrademax", prefix);
				value = CF_GetArgI(owner, PluginName, ABILITY_BUILDINGS, buffer, -1);
				if(value >= 0)
				{
					DataPack pack;
					CreateDataTimer(0.1, Timer_LimitBuilding, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
					pack.WriteCell(EntIndexToEntRef(entity));
					pack.WriteCell(value);
				}
			}
		}
	}
}

Action Timer_LimitBuilding(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		if(GetEntProp(entity, Prop_Send, "m_iUpgradeLevel") >= pack.ReadCell())
		{
			int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
			if(owner != -1 && IsPlayerAlive(owner))
			{
				int upgrade = GetEntProp(entity, Prop_Send, "m_iUpgradeMetal");
				GivePlayerAmmo(owner, upgrade, 3, true);
			}

			SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 0);
			SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 16384);
		}
		
		return Plugin_Continue;
	}

	return Plugin_Stop;
}

Action Timer_AmpBuilding(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity != -1)
	{
		if(GetEntProp(entity, Prop_Send, "m_bCarried") || GetEntPropFloat(entity, Prop_Send, "m_flPercentageConstructed")<1.0)
			return Plugin_Continue;
		
		SetEntityModel(entity, AMP_MODEL);
		SetEntProp(entity, Prop_Send, "m_nSkin", GetEntProp(entity, Prop_Send, "m_nSkin") - 2);
		SetEntProp(entity, Prop_Send, "m_bDisabled", true);

		CreateTimer(0.3, Timer_AmpThink, ref, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}

	return Plugin_Stop;
}

Action Timer_AmpThink(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity != -1)
	{
		SetEntProp(entity, Prop_Send, "m_bDisabled", true);

		if(GetEntProp(entity, Prop_Send, "m_bHasSapper") || GetEntProp(entity, Prop_Send, "m_bPlasmaDisable") || GetEntProp(entity, Prop_Send, "m_bCarried") || GetEntPropFloat(entity, Prop_Send, "m_flPercentageConstructed")<1.0)
			return Plugin_Continue;
		
		SetEntityModel(entity, AMP_MODEL);
		
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
		int level = GetEntProp(entity, Prop_Send, "m_iUpgradeLevel");
		bool boosted = (owner != -1 && TF2_IsPlayerInCondition(owner, TFCond_CritCanteen));
		int metal = GetEntProp(entity, Prop_Send, "m_iAmmoMetal") + (level > 1 ? 10 : 5);
		float ultCharge;

		if(boosted)
			metal = 10000;

		float pos1[3], pos2[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos1);
		int team = GetEntProp(entity, Prop_Send, "m_iTeamNum");
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && IsPlayerAlive(client))
			{
				if(team != GetClientTeam(client))
				{
					if(!TF2_IsPlayerInCondition(client, TFCond_Disguised) || GetEntProp(client, Prop_Send, "m_nDisguiseTeam") != team)
						continue;
				}

				GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos2);
				if(GetVectorDistance(pos1, pos2, true) < 30000.0)
				{
					int cost = AmpBuffTimer[client] ? 6 : 50;
					if(metal >= cost)
					{
						if(!AmpBuffTimer[client])
						{
							ClientCommand(client, "playgamesound items/powerup_pickup_precision.wav");
							AmpBuffEntRef[client] = EntIndexToEntRef(FPS_AttachFakeParticleToEntity(client, "root", "models/fake_particles/chaos_fortress/player_aura.mdl", 2, "rotate", 0.75, _, team == 2 ? 255 : 180, 180, team == 2 ? 180 : 255, 0));
						}
						
						delete AmpBuffTimer[client];
						AmpBuffTimer[client] = CreateTimer(2.5, Timer_AmpBuff, client);

						metal -= cost;
						ultCharge += float(cost);
					}
				}
			}
		}

		if(owner != -1)
			CF_GiveUltCharge(owner, ultCharge, CF_ResourceType_Generic);

		if(metal > 400)
			metal = 400;
		
		if(level > 1)
		{
			int upgrade = GetEntProp(entity, Prop_Send, "m_iUpgradeMetal");
			metal += upgrade * 8;

			if(metal > 400)
			{
				upgrade = (metal - 400) / 8;
				metal = 400;
			}
			else
			{
				upgrade = 0;
			}
			
			SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", upgrade);
			SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 16384);
		}

		int color[4];
		color = team == 2 ? {255, 75, 75, 255} : {75, 75, 255, 255};
		color[3] = metal * 255 / 400;

		pos1[2] += 90.0;
		TE_SetupBeamRingPoint(pos1, 10.0, boosted ? 700.0 : 350.0, BeamSprite, HaloSprite, 0, 15, 1.0, 5.0, 0.0, color, boosted ? 16 : 8, 0);
		TE_SendToAll();	

		SetEntProp(entity, Prop_Send, "m_iAmmoMetal", metal);
		return Plugin_Continue;
	}

	return Plugin_Stop;
}

Action Timer_AmpBuff(Handle timer, int client)
{
	int entity = EntRefToEntIndex(AmpBuffEntRef[client]);
	if(entity != -1)
		RemoveEntity(entity);

	AmpBuffTimer[client] = null;
	return Plugin_Stop;
}

Action Timer_CircuitBuff(Handle timer, int client)
{
	int entity = EntRefToEntIndex(CircuitBuffEntRef[client]);
	if(entity != -1)
		RemoveEntity(entity);

	CircuitBuffTimer[client] = null;
	return Plugin_Stop;
}

Action BuildingTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(CircuitBuffTimer[victim])
	{
		damage *= 0.85;
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

void MajorSteamEffects(int client, char abilityName[255])
{
	int team = GetClientTeam(client);

	int count;
	int[] victims = new int[MaxClients];
	for(int victim = 1; victim <= MaxClients; victim++)
	{
		if(victim == client || (IsClientInGame(victim) && GetClientTeam(victim) != team))
			victims[count++] = victim;
	}

	EmitSound(victims, count, "mvm/mvm_tank_deploy.wav", client, SNDCHAN_STATIC, 80, _, 1.0, 80);
	EmitSoundToAll("mvm/mvm_deploy_giant.wav", client, SNDCHAN_STATIC, 120, _, 1.0);
	EmitSoundToAll("mvm/giant_soldier/giant_soldier_loop.wav", client, SNDCHAN_STATIC, 80, _, 1.0, 80);

	MajorSteamEndAt[client] = GetGameTime() + CF_GetArgF(client, PluginName, abilityName, "duration");

	if(!MajorSteamTimer[client])
		MajorSteamTimer[client] = CreateTimer(0.1, Timer_MajorSteam, client, TIMER_REPEAT);

	MajorSteamClass[client] = CF_GetCharacterClass(client);

	int class = CF_GetArgI(client, PluginName, abilityName, "class");
	if(class > 0)
		CF_SetCharacterClass(client, view_as<TFClassType>(class));
}

Action Timer_MajorSteam(Handle timer, int client)
{
	if(MajorSteamEndAt[client] > GetGameTime())
	{
		if(MajorSteamAlarmAt < GetGameTime())
		{
			MajorSteamAlarmAt = GetGameTime() + 3.0;

			int team = GetClientTeam(client);

			int count;
			int[] victims = new int[MaxClients];
			for(int victim = 1; victim <= MaxClients; victim++)
			{
				if(victim == client || (IsClientInGame(victim) && GetClientTeam(victim) != team))
					victims[count++] = victim;
			}

			EmitSound(victims, count, "mvm/mvm_cpoint_klaxon.wav", client, SNDCHAN_STATIC, 120, _, 1.0);
		}
		return Plugin_Continue;
	}

	MajorSteamTimer[client] = null;
	StopSound(client, SNDCHAN_STATIC, "mvm/giant_soldier/giant_soldier_loop.wav");
	StopSound(client, SNDCHAN_STATIC, "mvm/giant_soldier/giant_soldier_loop.wav");
	CF_SetCharacterClass(client, MajorSteamClass[client]);
	
	if(IsPlayerAlive(client))
	{
		TF2_RemoveCondition(client, TFCond_UberchargedHidden);
		TF2_RemoveCondition(client, TFCond_MegaHeal);
		TF2_RemoveCondition(client, TFCond_Dazed);
		TF2_StunPlayer(client, 5.0, 1.0, TF_STUNFLAGS_NORMALBONK);

		float pos[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
		TE_Particle("asplode_hoodoo", pos);

		EmitSoundToAll("mvm/giant_soldier/giant_soldier_explode.wav", client, SNDCHAN_STATIC, 120, _, 1.0);
	}

	return Plugin_Stop;
}

stock void TE_Particle(const char[] Name, float origin[3]=NULL_VECTOR, float start[3]=NULL_VECTOR, float angles[3]=NULL_VECTOR, int entindex=-1, int attachtype= 0, int attachpoint=-1, bool resetParticles=true, int customcolors=0, float color1[3]=NULL_VECTOR, float color2[3]=NULL_VECTOR, int controlpoint=-1, int controlpointattachment=-1, float controlpointoffset[3]=NULL_VECTOR, float delay=0.0)
{
	// find string table
	int tblidx = FindStringTable("ParticleEffectNames");
	if (tblidx == INVALID_STRING_TABLE)
		return;

	// find particle index
	static char tmp[256];
	int count = GetStringTableNumStrings(tblidx);
	int stridx = INVALID_STRING_INDEX;
	for(int i; i<count; i++)
	{
		ReadStringTable(tblidx, i, tmp, sizeof(tmp));
		if(StrEqual(tmp, Name, false))
		{
			stridx = i;
			break;
		}
	}

	if(stridx == INVALID_STRING_INDEX)
		return;
	
	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", origin[0]);
	TE_WriteFloat("m_vecOrigin[1]", origin[1]);
	TE_WriteFloat("m_vecOrigin[2]", origin[2]);
	TE_WriteFloat("m_vecStart[0]", start[0]);
	TE_WriteFloat("m_vecStart[1]", start[1]);
	TE_WriteFloat("m_vecStart[2]", start[2]);
	TE_WriteVector("m_vecAngles", angles);
	TE_WriteNum("m_iParticleSystemIndex", stridx);

	TE_WriteNum("entindex", entindex);

	if(attachtype != -1)
		TE_WriteNum("m_iAttachType", attachtype);

	if(attachpoint != -1)
		TE_WriteNum("m_iAttachmentPointIndex", attachpoint);

	TE_WriteNum("m_bResetParticles", resetParticles ? 1:0);
	if(customcolors)
	{
		TE_WriteNum("m_bCustomColors", customcolors);
		TE_WriteVector("m_CustomColors.m_vecColor1", color1);
		if(customcolors == 2)
			TE_WriteVector("m_CustomColors.m_vecColor2", color2);
	}

	if(controlpoint != -1)
	{
		TE_WriteNum("m_bControlPoint1", controlpoint);
		if(controlpointattachment != -1)
		{
			TE_WriteNum("m_ControlPoint1.m_eParticleAttachment", controlpointattachment);
			TE_WriteFloat("m_ControlPoint1.m_vecOffset[0]", controlpointoffset[0]);
			TE_WriteFloat("m_ControlPoint1.m_vecOffset[1]", controlpointoffset[1]);
			TE_WriteFloat("m_ControlPoint1.m_vecOffset[2]", controlpointoffset[2]);
		}
	}

	TE_SendToAll(delay);
}
