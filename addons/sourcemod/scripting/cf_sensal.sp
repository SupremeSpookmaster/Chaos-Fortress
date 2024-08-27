/*
	Sensal based on the Zombie Riot version
	Code and it's porting by Batfoxkid and Artvin
*/

#include <sourcemod>
#include <tf2_stocks>
#include <sdkhooks>
#include <cf_include>
#include <dhooks>
#include <tf2items>

#define MAXENTITIES	2048

#define SENSAL_LASER_THICKNESS 25

#define ABILITY_WEAPON			"sensal_special_weapon"
#define ABILITY_THROW			"sensal_ability_throw"
#define ABILITY_BARRIER			"sensal_ability_barrier"
#define ABILITY_BARRIER_SPAWN	"sensal_special_barrier"
#define ABILITY_MASSLASER		"sensal_ability_masslaser"
#define ABILITY_PORTALGATE		"sensal_ability_portalgate"
#define ABILITY_BLOCKRESOURCE	"sensal_ability_noresource"
#define ABILITY_RAGDOLL			"sensal_special_ragdoll"

static const char SyctheHitSound[][] =
{
	"ambient/machines/slicer1.wav",
	"ambient/machines/slicer2.wav",
	"ambient/machines/slicer3.wav",
	"ambient/machines/slicer4.wav",
};

static const char TeleportSound[][] =
{
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

enum
{
	Kill_Sycthe,
	Kill_Laser
}

char PluginName[255];
Handle SDKPlayTaunt;
int Shared_BEAM_Laser;
int Shared_BEAM_Glow;
int KillFeedType = -1;

int VulnStacks[MAXPLAYERS+1];
float VulnStackMulti[MAXPLAYERS+1];

int ShieldEntRef[MAXPLAYERS+1] = {-1, ...};

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
	GameData gameData = new GameData("tf2.tauntem");
	if(!gameData)
	{
		LogError("Could not find gamedata/tf2.tauntem.txt");
		return;
	}

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gameData, SDKConf_Signature, "CTFPlayer::PlayTauntSceneFromItem");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	SDKPlayTaunt = EndPrepSDKCall();
	if(SDKPlayTaunt == INVALID_HANDLE)
		LogError("Could not find CTFPlayer::PlayTauntSceneFromItem.");

	delete gameData;
}

public void OnMapStart()
{
	Shared_BEAM_Laser = PrecacheModel("materials/sprites/laser.vmt");
	Shared_BEAM_Glow = PrecacheModel("sprites/glow02.vmt");

	PrecacheSound("misc/halloween/spell_teleport.wav");

	for(int i; i < sizeof(SyctheHitSound); i++)
	{
		PrecacheSound(SyctheHitSound[i]);
	}

	for(int i; i < sizeof(TeleportSound); i++)
	{
		PrecacheSound(TeleportSound[i]);
	}
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if(!StrEqual(pluginName, PluginName, false))
		return;
	
	if(StrContains(abilityName, ABILITY_THROW) != -1)
	{
		ScytheThrow(client, abilityName);
	}
	else if(StrContains(abilityName, ABILITY_BARRIER) != -1)
	{
		ApplyBarrier(client, abilityName);
	}
	else if(StrContains(abilityName, ABILITY_MASSLASER) != -1)
	{
		DoMassLaser(client, abilityName);
	}
	else if(StrContains(abilityName, ABILITY_BLOCKRESOURCE) != -1)
	{
		ApplyNoResource(client, abilityName);
	}
	else if(StrContains(abilityName, ABILITY_PORTALGATE) != -1)
	{
		DoPortalGate(client, abilityName);
	}
}

public void CF_OnCharacterCreated(int client)
{
	if(CF_HasAbility(client, PluginName, ABILITY_WEAPON))
	{
		// Sensal Scythe model uses Alpha for skins and Bodygroups for model types

		int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		if(weapon != -1)
		{
			if(GetEntProp(weapon, Prop_Send, "m_bBeingRepurposedForTaunt"))
			{
				// Custom Model Attribute method

				int model = GetEntProp(weapon, Prop_Send, "m_iWorldModelIndex");

				int entity = -1;
				while((entity = FindEntityByClassname(entity, "tf_wearable_vm")) != -1)
				{
					if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client
					   && GetEntProp(entity, Prop_Send, "m_nModelIndex") == model)
					{
						SetAlphaBodyGroup(client, entity, ABILITY_WEAPON);
						break;
					}
				}
			}
			else
			{
				SetAlphaBodyGroup(client, weapon, ABILITY_WEAPON);
			}
		}
	}

	if(CF_HasAbility(client, PluginName, ABILITY_BARRIER_SPAWN))
	{
		int health = RoundFloat(CF_GetCharacterMaxHealth(client)) + CF_GetArgI(client, PluginName, ABILITY_BARRIER_SPAWN, "amount");
		if(health > GetClientHealth(client))
			SetEntityHealth(client, health);
		
		UpdateBarrier(client, ABILITY_BARRIER_SPAWN);
	}
}

public void CF_OnCharacterRemoved(int client, CF_CharacterRemovalReason reason)
{
	if(ShieldEntRef[client] != -1)
	{
		int entity = EntRefToEntIndex(ShieldEntRef[client]);
		if(entity != -1)
			TF2_RemoveWearable(client, entity);

		ShieldEntRef[client] = -1;
		SDKUnhook(client, SDKHook_OnTakeDamagePost, BarrierTakeDamagePost);
	}
}

public Action CF_OnTakeDamageAlive_Bonus(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
	if(VulnStacks[victim] > 0 && !(damagetype & DMG_CRIT))
	{
		float total = Pow(VulnStackMulti[victim], float(VulnStacks[victim]));

		// Marked-for-Death effect already gives a x1.35, and that's our cap
		if(total > 1.35)
			return Plugin_Continue;
		
		damage *= total;
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public Action CF_OnPlayerKilled_Pre(int &victim, int &inflictor, int &attacker, char weapon[255], char console[255], int &custom, int deadRinger, int &critType, int &damagebits)
{
	if(CF_HasAbility(victim, PluginName, ABILITY_RAGDOLL))
	{
		CreateTimer(3.0, DissolveRagdoll, GetClientUserId(victim), TIMER_FLAG_NO_MAPCHANGE);
	}

	switch(KillFeedType)
	{
		case Kill_Sycthe:
		{
			strcopy(weapon, sizeof(weapon), "tf_projectile_rocket");
			strcopy(console, sizeof(console), "sensal_scythe");
			return Plugin_Changed;
		}
		case Kill_Laser:
		{
			strcopy(weapon, sizeof(weapon), "cow_mangler");
			strcopy(console, sizeof(console), "sensal_laser");
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

Action DissolveRagdoll(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
		if(ragdoll != -1)
		{
			int dissolver = CreateEntityByName("env_entity_dissolver");
			if(dissolver != -1)
			{
				DispatchKeyValue(dissolver, "dissolvetype", "0");
				DispatchKeyValue(dissolver, "magnitude", "200");
				DispatchKeyValue(dissolver, "target", "!activator");

				AcceptEntityInput(dissolver, "Dissolve", ragdoll);
				AcceptEntityInput(dissolver, "Kill");

				EmitSoundToAll(TeleportSound[GetURandomInt() % sizeof(TeleportSound)], ragdoll, SNDCHAN_AUTO, 60, _, 0.8);
			}
		}
	}
	return Plugin_Continue;
}

void ScytheThrow(int client, char abilityName[255])
{
	CF_SimulateSpellbookCast(client, _, CF_Spell_Teleport);

	int target = GetClientAimTarget(client);
	FireScythe(client, abilityName, target);
}

int FireScythe(int client, char abilityName[255], int target)
{
	int rocket = CF_FireGenericRocket(client, CF_GetArgF(client, PluginName, abilityName, "damage"), CF_GetArgF(client, PluginName, abilityName, "velocity"), _, _, PluginName, OnScytheCollide);
	if(rocket != -1)
	{
		int prop = rocket;

		float ang[3];
		GetEntPropVector(rocket, Prop_Send, "m_angRotation", ang);

		if(target > 0)
		{
			Initiate_HomingProjectile(rocket,
				client,
				CF_GetArgF(client, PluginName, abilityName, "lockon"),			// float lockonAngleMax,
				CF_GetArgF(client, PluginName, abilityName, "homing"),				//float homingaSec,
				true,				// bool changeAngles,
				ang,			
				target); //home onto this enemy
		}
		
		// Attached Prop
		char buffer[255];
		CF_GetArgS(client, PluginName, abilityName, "model", buffer, sizeof(buffer));
		if(buffer[0])
		{
			SetEntityRenderMode(rocket, RENDER_TRANSCOLOR);
			SetEntityRenderColor(rocket, 255, 255, 255, 0);
			
			prop = CreateEntityByName("prop_dynamic_override");
			if(prop != -1)
			{
				DispatchKeyValue(prop, "model", buffer);

				float pos[3];
				GetEntPropVector(rocket, Prop_Send, "m_vecOrigin", pos);
				GetEntPropVector(rocket, Prop_Data, "m_angRotation", ang);

				int frame = GetEntProp(prop, Prop_Send, "m_ubInterpolationFrame");
				TeleportEntity(prop, pos, ang, NULL_VECTOR);
				SetEntPropFloat(prop, Prop_Data, "m_flSimulationTime", GetGameTime());
				DispatchSpawn(prop);
				SetEntProp(prop, Prop_Send, "m_ubInterpolationFrame", frame);

				SetEntityCollisionGroup(prop, 0);
				SetEntProp(prop, Prop_Send, "m_usSolidFlags", 12); 
				SetEntProp(prop, Prop_Data, "m_nSolidType", 0);

				SetVariantString("!activator");
				AcceptEntityInput(prop, "SetParent", rocket, prop);

				// Prop Animation
				CF_GetArgS(client, PluginName, abilityName, "animation", buffer, sizeof(buffer));
				if(buffer[0])
				{
					SetVariantString(buffer);
					AcceptEntityInput(prop, "SetDefaultAnimation", prop, prop);
					
					SetVariantString(buffer);
					AcceptEntityInput(prop, "SetAnimation", prop, prop);
				}

				float modelscale = CF_GetArgF(client, PluginName, abilityName, "modelscale");
				if(modelscale > 0.0)
					SetEntPropFloat(prop, Prop_Send, "m_flModelScale", modelscale);
			}
		}
		
		SetAlphaBodyGroup(client, prop, abilityName);
	}

	return rocket;
}

void SetAlphaBodyGroup(int client, int entity, char abilityName[255])
{
	TFTeam num = TF2_GetClientTeam(client);

	char team[32];
	if(num != TFTeam_Red && num != TFTeam_Blue)	// Note: If any FFA mode, add logic here
	{
		strcopy(team, sizeof(team), "_ffa");
	}
	else if(num == TFTeam_Red)
	{
		strcopy(team, sizeof(team), "_red");
	}
	else
	{
		strcopy(team, sizeof(team), "_blue");
	}

	char arg[255];

	FormatEx(arg, sizeof(arg), "alpha%s", team);
	int alpha = CF_GetArgI(client, PluginName, abilityName, arg);
	if(alpha != -1)
		SetEntityRenderColor(entity, 255, 255, 255, alpha);

	FormatEx(arg, sizeof(arg), "bodygroup%s", team);
	int bodygroup = CF_GetArgI(client, PluginName, abilityName, arg);
	if(bodygroup != -1)
	{
		SetVariantInt(bodygroup);
		AcceptEntityInput(entity, "SetBodyGroup");
	}
}

MRESReturn OnScytheCollide(int entity, int owner, int team)
{
	// There is no collider given to us from CF, do a AOE instead

	float damage = GetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4);

	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);

	KillFeedType = Kill_Sycthe;
	ArrayList victims = view_as<ArrayList>(CF_GenericAOEDamage(owner, entity, entity, damage, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, 50.0, pos, 400.0, 1.0, _, false));
	KillFeedType = -1;
	
	if(victims.Length)
	{
		// We only care about our single target
		int victim = victims.Get(0);
		if(victim <= MaxClients)
			ApplyVulnStack(victim, owner, 1.065, 5.0);

		// CF does not feature a way to play a sound from config in another location
		EmitSoundToAll(SyctheHitSound[GetURandomInt() % sizeof(SyctheHitSound)], entity, SNDCHAN_AUTO, 95);

		TE_Particle(team == 2 ? "spell_batball_impact_red" : "spell_batball_impact_blue", pos);
	}
	delete victims;

	RemoveEntity(entity);
	return MRES_Supercede;
}

void ApplyVulnStack(int victim, int attacker, float multi, float duration)
{
	VulnStacks[victim]++;
	VulnStackMulti[victim] = multi;

	float total = Pow(VulnStackMulti[victim], float(VulnStacks[victim]));

	// Marked when at x1.35 vuln
	if(total >= 1.35)
		TF2_AddCondition(victim, TFCond_MarkedForDeath, duration, attacker);
	
	CreateTimer(duration, RemoveVulnStackTimer, victim);
}

Action RemoveVulnStackTimer(Handle timer, int victim)
{
	VulnStacks[victim]--;

	if(IsClientInGame(victim) && TF2_IsPlayerInCondition(victim, TFCond_MarkedForDeath))
	{
		// Remove mark when below x1.35
		float total = Pow(VulnStackMulti[victim], float(VulnStacks[victim]));
		if(total < 1.35)
			TF2_RemoveCondition(victim, TFCond_MarkedForDeath);
	}

	return Plugin_Continue;
}

void ApplyBarrier(int client, char abilityName[255])
{
	CF_HealPlayer(client, client, CF_GetArgI(client, PluginName, abilityName, "amount"), CF_GetArgF(client, PluginName, abilityName, "cap"));
	UpdateBarrier(client, abilityName);
}

bool UpdateBarrier(int client, char abilityName[255] = "")
{
	int maxHealth = RoundFloat(CF_GetCharacterMaxHealth(client));
	
	// 255 alpha at x5 max health
	int alpha = (GetClientHealth(client) - maxHealth) * 255 / (maxHealth * 4);
	
	if(alpha < 1)
	{
		// No more barrier
		if(ShieldEntRef[client] != -1)
		{
			int entity = EntRefToEntIndex(ShieldEntRef[client]);
			if(entity != -1)
			{
				TF2_RemoveWearable(client, entity);
			}

			ShieldEntRef[client] = -1;
		}

		return false;
	}

	if(alpha > 255)
		alpha = 255;
	
	// Update barrier model
	int entity = EntRefToEntIndex(ShieldEntRef[client]);
	
	if(entity == -1)
	{
		if(!abilityName[0])
			return false;	// Update model, no new one
		
		// Remove overheal decay along with our shield
		entity = CF_AttachWearable(client, 57, "tf_wearable", true, 0, 0, _, "68 ; 1 ; 125 ; -9999");
		if(entity == -1)
			return false;
		
		char model[255];
		CF_GetArgS(client, PluginName, abilityName, "model", model, sizeof(model));

		if(model[0])
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndex", PrecacheModel(model));
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
			ShieldEntRef[client] = EntIndexToEntRef(entity);

			SDKUnhook(client, SDKHook_OnTakeDamagePost, BarrierTakeDamagePost);
			SDKHook(client, SDKHook_OnTakeDamagePost, BarrierTakeDamagePost);
		}
	}

	SetEntityRenderColor(entity, 255, 255, 255, alpha);
	return true;
}

void BarrierTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	if(!UpdateBarrier(victim))
		SDKUnhook(victim, SDKHook_OnTakeDamagePost, BarrierTakeDamagePost);
}

void DoMassLaser(int client, char abilityName[255])
{
	float range = CF_GetArgF(client, PluginName, abilityName, "radius");
	int targets = CF_GetArgI(client, PluginName, abilityName, "targets");
	float delay = CF_GetArgF(client, PluginName, abilityName, "delay");

	float pos[3];
	GetClientEyePosition(client, pos);

	ArrayList victims = view_as<ArrayList>(CF_GenericAOEDamage(client, client, client, 0.0, 0, range, pos, range, 1.0, _, false));
	
	int length = victims.Length;
	while(length > targets)
	{
		victims.Erase(0);
		length--;
	}

	for(int i; i < length; i++)
	{
		victims.Set(i, EntIndexToEntRef(victims.Get(i)));
	}
	
	DataPack pack;
	CreateDataTimer(delay, MassLaserTimer, pack);
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(victims);

	CF_AttachParticle(client, GetClientTeam(client) == 2 ? "flaregun_trail_red" : "flaregun_trail_blue", "effect_hand_r", _, 1.0);

	TF2_AddCondition(client, TFCond_HalloweenKartCage, delay + 1.1);
	TF2_AddCondition(client, TFCond_MegaHeal, delay + 1.1);

	if(SDKPlayTaunt)
	{
		static Handle item;
		if(item == INVALID_HANDLE)
		{
			item = TF2Items_CreateItem(OVERRIDE_ALL|PRESERVE_ATTRIBUTES|FORCE_GENERATION);
			TF2Items_SetClassname(item, "tf_wearable_vm");
			TF2Items_SetQuality(item, 6);
			TF2Items_SetLevel(item, 1);
		}

		TF2Items_SetItemIndex(item, 31162);
		int entity = TF2Items_GiveNamedItem(client, item);
		if(entity != -1)
		{
			TF2_RemoveCondition(client, TFCond_Taunting);
			
			static int offset;
			if(!offset)
				offset = GetEntSendPropOffs(entity, "m_Item", true);
			
			if(offset > 0)
			{
				Address address = GetEntityAddress(entity);
				if(address != Address_Null)
				{
					address += view_as<Address>(offset);
					SDKCall(SDKPlayTaunt, client, address);
				}

				AcceptEntityInput(entity, "Kill");
			}
		}
	}
}

Action MassLaserTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int attacker = GetClientOfUserId(pack.ReadCell());
	ArrayList victims = pack.ReadCell();

	if(attacker && IsPlayerAlive(attacker))
	{
		float pos1[3], pos2[3];

		int index = LookupEntityAttachment(attacker, "effect_hand_r");
		if(!index || !GetEntityAttachment(attacker, index, pos1, pos2))
		{
			CF_WorldSpaceCenter(attacker, pos1);
		}
		
		CF_AttachParticle(attacker, GetClientTeam(attacker) == 2 ? "powerup_supernova_explode_red" : "powerup_supernova_explode_blue", "effect_hand_r", _, 1.0);

		int length = victims.Length;
		for(int i; i < length; i++)
		{
			int victim = EntRefToEntIndex(victims.Get(i));
			if(victim != -1)
			{
				CF_WorldSpaceCenter(victim, pos2);
				SensalInitiateLaserAttack(attacker, pos2, pos1);
			}
		}

		CF_PlayRandomSound(attacker, "", "sound_masslaser");
	}

	delete victims;
	return Plugin_Continue;
}

void ApplyNoResource(int client, char abilityName[255])
{
	float time = GetGameTime() + CF_GetArgF(client, PluginName, abilityName, "duration");

	DataPack pack;
	CreateDataTimer(0.5, SetNoResourceTimer, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	pack.WriteCell(GetClientUserId(client));
	pack.WriteFloat(time);

	CF_SetSpecialResource(client, 0.0);
}

Action SetNoResourceTimer(Handle timer, DataPack pack)
{
	pack.Reset();

	int client = GetClientOfUserId(pack.ReadCell());
	if(client)
	{
		float time = pack.ReadFloat();
		if(time > GetGameTime())
		{
			CF_SetSpecialResource(client, 0.0);
			return Plugin_Continue;
		}
	}

	return Plugin_Stop;
}

void DoPortalGate(int client, char abilityName[255])
{
	float delay = CF_GetArgF(client, PluginName, abilityName, "delay");

	TF2_AddCondition(client, TFCond_HalloweenKartCage, delay);
	TF2_AddCondition(client, TFCond_MegaHeal, delay);

	// Temp weapon used for taunt animation
	int weapon = CF_SpawnWeapon(client, "tf_weapon_shovel", 128, 45, 8, TFWeaponSlot_Melee, 0, 0, "252 ; 0.0", _, false, false)
	if(weapon != -1)
	{
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
		FakeClientCommand(client, "taunt");
		weapon = EntIndexToEntRef(weapon);
	}

	DataPack pack;
	CreateDataTimer(delay, PortalGateStartTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(weapon);
	pack.WriteString(abilityName);

	// Partial refund if you somehow died during the startup delay
	CF_SetUltCharge(client, CF_GetArgF(client, PluginName, abilityName, "refund"), true);
}

Action PortalGateStartTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	if(client)
	{
		// Remove our temp weapon
		int weapon = EntRefToEntIndex(pack.ReadCell());
		
		int entity = GetEntPropEnt(weapon, Prop_Send, "m_hExtraWearable");
		if(entity != -1)
			TF2_RemoveWearable(client, entity);

		entity = GetEntPropEnt(weapon, Prop_Send, "m_hExtraWearableViewModel");
		if(entity != -1)
			TF2_RemoveWearable(client, entity);

		RemovePlayerItem(client, weapon);
		AcceptEntityInput(weapon, "Kill");

		if(IsPlayerAlive(client))
		{
			// Remove partial refund
			CF_SetUltCharge(client, 0.0, true);

			float pos[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos);
			pos[2] += 400.0;

			entity = ParticleEffectAt(pos, "eyeboss_tp_vortex", 0.0);
			if(entity != -1)
			{
				char abilityName[255];
				pack.ReadString(abilityName, sizeof(abilityName));

				float duration = CF_GetArgF(client, PluginName, abilityName, "duration");
				float frequency = CF_GetArgF(client, PluginName, abilityName, "frequency");

				CreateDataTimer(frequency, PortalGateLoopTimer, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				pack.WriteCell(EntIndexToEntRef(entity));
				pack.WriteCell(GetClientUserId(client));
				pack.WriteCell(GetClientTeam(client));
				pack.WriteFloat(GetGameTime() + duration);
				pack.WriteString(abilityName);

				ParticleEffectAt(pos, "hammer_bell_ring_shockwave", 1.0);
			}

			CF_PlayRandomSound(client, "", "sound_portalgate_1");
			CF_PlayRandomSound(client, "", "sound_portalgate_2");
		}
	}

	return Plugin_Continue;
}

Action PortalGateLoopTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		int client = GetClientOfUserId(pack.ReadCell());
		if(client)
		{
			int team = pack.ReadCell();
			if(GetClientTeam(client) == team)
			{
				float time = pack.ReadFloat();
				if(time > GetGameTime())
				{
					char abilityName[255];
					pack.ReadString(abilityName, sizeof(abilityName));

					float pos[3];
					GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);

					float range = CF_GetArgF(client, PluginName, abilityName, "radius");

					ArrayList victims = view_as<ArrayList>(CF_GenericAOEDamage(client, client, client, 0.0, 0, range, pos, range, 1.0, _, false));
					
					int length = victims.Length;
					if(length)
					{
						for(int i; i < length; i++)
						{
							int rocket = FireScythe(client, abilityName, victims.Get(i));
							if(rocket != -1)
								TeleportEntity(rocket, pos);
						}

						EmitSoundToAll("misc/halloween/spell_teleport.wav", entity, SNDCHAN_STATIC, 90, _, 0.8);
					}

					delete victims;

					return Plugin_Continue;
				}
			}
		}

		RemoveEntity(entity);
	}

	return Plugin_Stop;
}

/*
	Zombie Riot Ported Code
*/

void SensalInitiateLaserAttack(int entity, float VectorTarget[3], float VectorStart[3])
{
	float vecForward[3], vecRight[3], Angles[3];

	MakeVectorFromPoints(VectorStart, VectorTarget, vecForward);
	GetVectorAngles(vecForward, Angles);
	GetAngleVectors(vecForward, vecForward, vecRight, VectorTarget);

	Handle trace = TR_TraceRayFilterEx(VectorStart, Angles, 11, RayType_Infinite, Sensal_TraceWallsOnly);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(VectorTarget, trace);
		
		float lineReduce = 20.0 / 3.0;
		float curDist = GetVectorDistance(VectorStart, VectorTarget, false);
		if (curDist > lineReduce)
		{
			ConformLineDistance(VectorTarget, VectorStart, VectorTarget, curDist - lineReduce);
		}
	}
	delete trace;

	int red = 255;
	int green = 255;
	int blue = 255;
	int Alpha = 255;

	int colorLayer4[4];
	float diameter = float(SENSAL_LASER_THICKNESS * 4);
	SetColorRGBA(colorLayer4, red, green, blue, Alpha);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, Alpha);
	int glowColor[4];
	SetColorRGBA(glowColor, red, green, blue, Alpha);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Glow, 0, 0, 0, 0.7, ClampBeamWidth(diameter * 0.1), ClampBeamWidth(diameter * 0.1), 0, 0.5, glowColor, 0);
	TE_SendToAll(0.0);

	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteFloat(VectorTarget[0]);
	pack.WriteFloat(VectorTarget[1]);
	pack.WriteFloat(VectorTarget[2]);
	pack.WriteFloat(VectorStart[0]);
	pack.WriteFloat(VectorStart[1]);
	pack.WriteFloat(VectorStart[2]);
	CreateDataTimer(0.8, SensalInitiateLaserAttack_DamagePart, pack, TIMER_FLAG_NO_MAPCHANGE);
}

ArrayList SensalHitList;

void SensalInitiateLaserAttack_DamagePart(DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(entity))
		entity = 0;

	float VectorTarget[3];
	float VectorStart[3];
	VectorTarget[0] = pack.ReadFloat();
	VectorTarget[1] = pack.ReadFloat();
	VectorTarget[2] = pack.ReadFloat();
	VectorStart[0] = pack.ReadFloat();
	VectorStart[1] = pack.ReadFloat();
	VectorStart[2] = pack.ReadFloat();

	int team = entity ? 0 : GetClientTeam(entity);
	int red = 50;
	int green = 50;
	int blue = 255;
	int Alpha = 222;
	if(team == 2)
	{
		red = 255;
		green = 50;
		blue = 50;
	}
	int colorLayer4[4];
	float diameter = float(SENSAL_LASER_THICKNESS * 4);
	SetColorRGBA(colorLayer4, red, green, blue, Alpha);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, Alpha);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.4), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);

	float hullMin[3];
	float hullMax[3];
	hullMin[0] = -float(SENSAL_LASER_THICKNESS);
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];

	SensalHitList = new ArrayList();

	Handle trace;
	trace = TR_TraceHullFilterEx(VectorStart, VectorTarget, hullMin, hullMax, 1073741824, Sensal_BEAM_TraceUsers, entity);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
			
	float CloseDamage = 350.0;
	float FarDamage = 60.0;
	float MaxDistance = 1000.0;
	float playerPos[3];
	
	int length = SensalHitList.Length;
	for(int i; i < length; i++)
	{
		int victim = SensalHitList.Get(i);
		if(GetEntProp(entity, Prop_Data, "m_iTeamNum") != team)
		{
			GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
			float distance = GetVectorDistance(VectorStart, playerPos, false);
			float damage = CloseDamage + (FarDamage-CloseDamage) * (distance/MaxDistance);
			if (damage < FarDamage)
				damage = FarDamage;
			
			if(victim > MaxClients)
				damage *= 0.25;
			
			KillFeedType = Kill_Laser;
			SDKHooks_TakeDamage(victim, entity, entity, damage, DMG_PLASMA, -1, NULL_VECTOR, playerPos, false);	// 2048 is DMG_NOGIB?
			KillFeedType = -1;
		}
	}

	delete SensalHitList;

	delete pack;
}

bool Sensal_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (CF_IsValidTarget(entity, TFTeam_Unassigned))
	{
		SensalHitList.Push(entity);
	}
	return false;
}

bool Sensal_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}

stock float ClampBeamWidth(float w) { return w > 128.0 ? 128.0 : w; }

stock int ConnectWithBeamClient(int iEnt, int iEnt2, int iRed=255, int iGreen=255, int iBlue=255,
							float fStartWidth=0.8, float fEndWidth=0.8, float fAmp=1.35, char[] Model = "sprites/laserbeam.vmt")
{
	int iBeam = CreateEntityByName("env_beam");
	if(iBeam <= MaxClients)
		return -1;

	if(!IsValidEntity(iBeam))
		return -1;

	SetEntityModel(iBeam, Model);
	char sColor[16];
	Format(sColor, sizeof(sColor), "%d %d %d", iRed, iGreen, iBlue);

	DispatchKeyValue(iBeam, "rendercolor", sColor);
	DispatchKeyValue(iBeam, "life", "0");

	DispatchSpawn(iBeam);

	SetEntPropEnt(iBeam, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(iEnt));

	SetEntPropEnt(iBeam, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(iEnt2), 1);

	SetEntProp(iBeam, Prop_Send, "m_nNumBeamEnts", 2);
	SetEntProp(iBeam, Prop_Send, "m_nBeamType", 2);

	SetEntPropFloat(iBeam, Prop_Data, "m_fWidth", fStartWidth);
	SetEntPropFloat(iBeam, Prop_Data, "m_fEndWidth", fEndWidth);

	SetEntPropFloat(iBeam, Prop_Data, "m_fAmplitude", fAmp);

	SetVariantFloat(32.0);
	AcceptEntityInput(iBeam, "Amplitude");
	AcceptEntityInput(iBeam, "TurnOn");

	SetVariantInt(0);
	AcceptEntityInput(iBeam, "TouchType");

	SetVariantString("0");
	AcceptEntityInput(iBeam, "damage");
	//its delayed by a frame to avoid it not rendering at all.
//	RequestFrames(ApplyBeamThinkRemoval, 15, EntIndexToEntRef(iBeam));

	return iBeam;
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

stock void SetColorRGBA(int color[4], int r, int g, int b, int a)
{
	color[0] = r%256;
	color[1] = g%256;
	color[2] = b%256;
	color[3] = a%256;
}

stock float ConformAxisValue(float src, float dst, float distCorrectionFactor)
{
	return src - ((src - dst) * distCorrectionFactor);
}

stock int ParticleEffectAt(float position[3], const char[] effectName, float duration)
{
	int particle = CreateEntityByName("info_particle_system");
	if (particle != -1)
	{
		TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
		SetEntPropFloat(particle, Prop_Data, "m_flSimulationTime", GetGameTime());
		DispatchKeyValue(particle, "effect_name", effectName);

		DispatchSpawn(particle);
		if(effectName[0])
		{
			ActivateEntity(particle);
			AcceptEntityInput(particle, "start");
		}

		SetEdictFlags(particle, (GetEdictFlags(particle) & ~FL_EDICT_ALWAYS));

		if (duration > 0.0)
		{
			char buffer[64];
			FormatEx(buffer, sizeof(buffer), "OnUser4 !self:Kill::%.2f:1,0,1", duration);
			SetVariantString("OnUser4 !self:Kill::30:1,0,1");
			AcceptEntityInput(particle, "AddOutput");
			AcceptEntityInput(particle, "FireUser4");
		}
	}
	return particle;
}

int RMR_CurrentHomingTarget[MAXENTITIES];
int RMR_RocketOwner[MAXENTITIES];
float RMR_HomingPerSecond[MAXENTITIES];
float RWI_LockOnAngle[MAXENTITIES];
float RWI_RocketSpeed[MAXENTITIES];

bool RWI_AlterRocketActualAngle[MAXENTITIES];
float RWI_RocketRotation[MAXENTITIES][3];

//Credits: Me (artvin) for rewriting it abit so its easier to read
// Sarysa (sarysa pub 1 plugin)
void Initiate_HomingProjectile(int projectile, int owner, float lockonAngleMax, float homingaSec, bool changeAngles, float AnglesInitiate[3], int initialTarget)
{
	RMR_RocketOwner[projectile] = EntIndexToEntRef(owner);
	RMR_HomingPerSecond[projectile] = homingaSec; 	//whats the homingpersec
	RWI_LockOnAngle[projectile] = lockonAngleMax;	//at what point do i lose my Target if out of my angle
		
	RMR_CurrentHomingTarget[projectile] = initialTarget;
	RWI_AlterRocketActualAngle[projectile] = changeAngles;

	RWI_RocketRotation[projectile][0] = AnglesInitiate[0];
	RWI_RocketRotation[projectile][1] = AnglesInitiate[1];
	RWI_RocketRotation[projectile][2] = AnglesInitiate[2];

	float vecVelocityCurrent[3];
	GetEntPropVector(projectile, Prop_Send, "m_vInitialVelocity", vecVelocityCurrent);
	RWI_RocketSpeed[projectile] = getLinearVelocity(vecVelocityCurrent);
	//homing will always be 0.1 seconds, thats the delay.
	CreateTimer(0.1, Projectile_NonPerfectHoming, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	/*
		dont bother using EntRef for RMR_CurrentHomingTarget, it has a 0.1 timer
		and the same entity cannot be repeated/id cant be replaced in under 1 second
		due to source engine
		todo perhaps: Use requestframes and make a loop of it, thats basically OnGameFrame!
	*/
}

public Action Projectile_NonPerfectHoming(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		if(!IsValidEntity(RMR_RocketOwner[entity])) //no need for converting.
		{
			RemoveEntity(entity);
			return Plugin_Stop;
		}

		//The enemy is valid
		if(CF_IsValidTarget(RMR_CurrentHomingTarget[entity], TFTeam_Unassigned))
		{
			if(HomingProjectile_ValidTargetCheck(entity, RMR_CurrentHomingTarget[entity]))
			{
				HomingProjectile_TurnToTarget_NonPerfect(entity, RMR_CurrentHomingTarget[entity]);
				return Plugin_Continue;
			}
		}
		RMR_CurrentHomingTarget[entity] = -1;

		//We already lost our homing Target AND we made it so we cant get another, kill the homing.
	}
	
	return Plugin_Stop;
}

void HomingProjectile_TurnToTarget_NonPerfect(int projectile, int Target)
{
	static float rocketAngle[3];

	rocketAngle[0] = RWI_RocketRotation[projectile][0];
	rocketAngle[1] = RWI_RocketRotation[projectile][1];
	rocketAngle[2] = RWI_RocketRotation[projectile][2];

	static float tmpAngles[3];
	static float rocketOrigin[3];
	GetEntPropVector(projectile, Prop_Send, "m_vecOrigin", rocketOrigin);

	float pos1[3];
	CF_WorldSpaceCenter(Target, pos1);
	GetRayAngles(rocketOrigin, pos1, tmpAngles);
	
	// Thanks to mikusch for pointing out this function to use instead
	// we had a simular function but i forgot that it existed before
	// https://github.com/Mikusch/ChaosModTF2/pull/4/files
	rocketAngle[0] = ApproachAngle(tmpAngles[0], rocketAngle[0], RMR_HomingPerSecond[projectile]);
	rocketAngle[1] = ApproachAngle(tmpAngles[1], rocketAngle[1], RMR_HomingPerSecond[projectile]);
	
	float vecVelocity[3];
	GetAngleVectors(rocketAngle, vecVelocity, NULL_VECTOR, NULL_VECTOR);
	
	vecVelocity[0] *= RWI_RocketSpeed[projectile];
	vecVelocity[1] *= RWI_RocketSpeed[projectile];
	vecVelocity[2] *= RWI_RocketSpeed[projectile];

	RWI_RocketRotation[projectile][0] = rocketAngle[0];
	RWI_RocketRotation[projectile][1] = rocketAngle[1];
	RWI_RocketRotation[projectile][2] = rocketAngle[2];

	// Apply only both if we want to, angle doesnt matter mostly
	if(RWI_AlterRocketActualAngle[projectile])
		TeleportEntity(projectile, NULL_VECTOR, rocketAngle, vecVelocity);
	else
		TeleportEntity(projectile, NULL_VECTOR, NULL_VECTOR, vecVelocity);
}

bool HomingProjectile_ValidTargetCheck(int projectile, int Target)
{
	static float ang3[3];
	
	float ang_Look[3];

	ang_Look[0] = RWI_RocketRotation[projectile][0];
	ang_Look[1] = RWI_RocketRotation[projectile][1];
	ang_Look[2] = RWI_RocketRotation[projectile][2];

	float pos1[3];
	float pos2[3];
	GetEntPropVector(projectile, Prop_Send, "m_vecOrigin", pos2);
	CF_WorldSpaceCenter(Target, pos1);
	GetVectorAnglesTwoPoints(pos2, pos1, ang3);

	// fix all angles
	ang3[0] = fixAngle(ang3[0]);
	ang3[1] = fixAngle(ang3[1]);

	// verify angle validity
	if(!(fabs(ang_Look[0] - ang3[0]) <= RWI_LockOnAngle[projectile] ||
	(fabs(ang_Look[0] - ang3[0]) >= (360.0-RWI_LockOnAngle[projectile]))))
	{
		return false;
	}

	if(!(fabs(ang_Look[1] - ang3[1]) <= RWI_LockOnAngle[projectile] ||
	(fabs(ang_Look[1] - ang3[1]) >= (360.0-RWI_LockOnAngle[projectile]))))
	{
		return false;
	}
		
	return true;
}

stock void GetRayAngles(float startPoint[3], float endPoint[3], float angle[3])
{
	static float tmpVec[3];
	tmpVec[0] = endPoint[0] - startPoint[0];
	tmpVec[1] = endPoint[1] - startPoint[1];
	tmpVec[2] = endPoint[2] - startPoint[2];
	GetVectorAngles(tmpVec, angle);
}

stock float getLinearVelocity(float vecVelocity[3])
{
	return SquareRoot((vecVelocity[0] * vecVelocity[0]) + (vecVelocity[1] * vecVelocity[1]) + (vecVelocity[2] * vecVelocity[2]));
}

stock void GetVectorAnglesTwoPoints(const float startPos[3], const float endPos[3], float angles[3])
{
	static float tmpVec[3];
	tmpVec[0] = endPos[0] - startPos[0];
	tmpVec[1] = endPos[1] - startPos[1];
	tmpVec[2] = endPos[2] - startPos[2];
	GetVectorAngles(tmpVec, angles);
}

stock float fabs(float value)
{
	return value < 0 ? -value : value;
}

stock float fixAngle(float angle)
{
	while (angle < -180.0)
		angle = angle + 360.0;
	while (angle > 180.0)
		angle = angle - 360.0;
		
	return angle;
}

stock float ApproachAngle( float target, float value, float speed )
{
	float delta = AngleDiff_Change(target, value);
	
	// Speed is assumed to be positive
	if ( speed < 0 )
		speed = -speed;
	
	if ( delta < -180 )
		delta += 360;
	else if ( delta > 180 )
		delta -= 360;
	
	if ( delta > speed )
		value += speed;
	else if ( delta < -speed )
		value -= speed;
	else 
		value = target;
	
	return value;
}

stock float AngleDiff_Change( float destAngle, float srcAngle )
{
	float delta = fmodf(destAngle - srcAngle, 360.0);
	if ( destAngle > srcAngle )
	{
		if ( delta >= 180 )
			delta -= 360;
	}
	else
	{
		if ( delta <= -180 )
			delta += 360;
	}
	
	return delta;
}

stock float fmodf(float num, float denom)
{
	return num - denom * RoundToFloor(num / denom);
}