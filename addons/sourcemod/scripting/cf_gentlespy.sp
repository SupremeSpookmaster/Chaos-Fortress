#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define GENTLESPY		"cf_gentlespy"
#define STABS			"gentlespy_enable_backstabs"
#define AMBY			"gentlespy_revolver_attackspeed"
#define MONTAGE			"gentlespy_montage"
#define SAPPER			"gentlespy_throwable_sapper"

#define SOUND_STAB_NONLETHAL		"player/spy_shield_break.wav"
#define SOUND_SAPPER_DESTROYED		")weapons/sentry_explode.wav"
#define SOUND_SAPPER_LOOP			")weapons/sapper_timer.wav"
#define SOUND_SAPPER_WAVE			")weapons/barret_arm_shot.wav"

#define PARTICLE_SAPPER_DESTROYED	"rd_robot_explosion"
#define PARTICLE_SAPPER_TRAIL_RED	"stickybombtrail_red"
#define PARTICLE_SAPPER_TRAIL_BLUE	"stickybombtrail_blue"
#define PARTICLE_SAPPER_HIT_RED		"drg_cow_explosion_sparkles_charged"
#define PARTICLE_SAPPER_HIT_BLUE	"drg_cow_explosion_sparkles_charged_blue"

#define MODEL_SAPPER			"models/weapons/w_models/w_sapper.mdl"

static char g_Gears[][] = { 
	"models/player/gibs/gibs_bolt.mdl",
	"models/player/gibs/gibs_gear1.mdl",
	"models/player/gibs/gibs_gear2.mdl",
	"models/player/gibs/gibs_gear3.mdl",
	"models/player/gibs/gibs_gear4.mdl",
	"models/player/gibs/gibs_gear5.mdl",
};

static char g_MetallicImpactSounds[][] = { 
	")weapons/crowbar/crowbar_impact1.wav",
	")weapons/crowbar/crowbar_impact2.wav"
};

float f_AmbyEndTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_MontageEndTime[MAXPLAYERS + 1] = { 0.0, ... };

int Model_Glow, Model_Laser, Model_Lightning;

public void OnMapStart()
{
	PrecacheSound(SOUND_STAB_NONLETHAL);
	PrecacheSound(SOUND_SAPPER_DESTROYED);
	PrecacheSound(SOUND_SAPPER_LOOP);
	PrecacheSound(SOUND_SAPPER_WAVE);

	PrecacheModel(MODEL_SAPPER);

	for (int i = 0; i < (sizeof(g_Gears));   i++) { PrecacheModel(g_Gears[i]);   }

	for (int i = 0; i < (sizeof(g_MetallicImpactSounds));   i++) { PrecacheSound(g_MetallicImpactSounds[i]);   }

	for (int client = 0; client <= MaxClients; client++)
	{
		f_AmbyEndTime[client] = 0.0;
		f_MontageEndTime[client] = 0.0;
	}

	Model_Glow = PrecacheModel("materials/sprites/glow02.vmt");
	Model_Laser = PrecacheModel("materials/sprites/laserbeam.vmt");
	Model_Lightning = PrecacheModel("materials/sprites/lgtning.vmt");
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, GENTLESPY))
		return;

	if (StrContains(abilityName, AMBY) != -1)
		Amby_Activate(client, abilityName);

	if (StrContains(abilityName, MONTAGE) != -1)
		Montage_Activate(client, abilityName);
	
	if (StrContains(abilityName, SAPPER) != -1)
		Sapper_Activate(client, abilityName);
}

float f_AmbyMult[MAXPLAYERS + 1] = { 0.0, ... };

public void Amby_Activate(int client, char abilityName[255])
{
	f_AmbyEndTime[client] = GetGameTime() + CF_GetArgF(client, GENTLESPY, abilityName, "duration", 2.5);
	f_AmbyMult[client] = CF_GetArgF(client, GENTLESPY, abilityName, "amt", 0.33);
}

bool b_StabsEnabled[MAXPLAYERS + 1] = { false, ... };
bool b_DoCustomRagdoll[MAXPLAYERS + 1] = { false, ... };

float f_NextStab[MAXPLAYERS + 1] = { 0.0, ... };
float f_StabDMG[MAXPLAYERS + 1] = { 0.0, ... };
float f_StabDelay[MAXPLAYERS + 1] = { 0.0, ... };
float f_StabDelay_Lethal[MAXPLAYERS + 1] = { 0.0, ... };

int i_StabMode[MAXPLAYERS + 1] = { 0, ... };
int i_StabSlot[MAXPLAYERS + 1] = { -1, ... };
int i_StabSlot_Lethal[MAXPLAYERS + 1] = { -1, ... };
int i_StabRagdoll[MAXPLAYERS + 1] = { 0, ... };

char s_OldStats[MAXPLAYERS + 1][255];

Handle g_MontageTimer[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };

public void Montage_Activate(int client, char abilityName[255])
{
	float duration = CF_GetArgF(client, GENTLESPY, abilityName, "duration", 9.0);
	f_MontageEndTime[client] = GetGameTime() + duration;
	CF_GetArgS(client, GENTLESPY, abilityName, "old_stats", s_OldStats[client], 255);

	Stabs_Prepare(client, abilityName);

	Montage_DeleteTimer(client);
	DataPack pack = new DataPack();
	g_MontageTimer[client] = CreateDataTimer(duration, Montage_End, pack);
	WritePackCell(pack, GetClientUserId(client));
	WritePackCell(pack, client);
}

public void Montage_DeleteTimer(int client)
{
	if (g_MontageTimer[client] != null && g_MontageTimer[client] != INVALID_HANDLE)
	{
		delete g_MontageTimer[client];
		g_MontageTimer[client] = null;
	}
}

public Action Montage_End(Handle revert, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int idx = ReadPackCell(pack);
	g_MontageTimer[idx] = null;

	if (IsValidMulti(client))
	{
		Stabs_Prepare(client, s_OldStats[client]);
	}

	return Plugin_Continue;
}

public void CF_OnCharacterCreated(int client)
{
	b_StabsEnabled[client] = CF_HasAbility(client, GENTLESPY, STABS);
	if (b_StabsEnabled[client])
		Stabs_Prepare(client, STABS);

	f_AmbyEndTime[client] = 0.0;
	f_AmbyEndTime[client] = 0.0;
	f_MontageEndTime[client] = 0.0;
}

public void CF_OnCharacterRemoved(int client, CF_CharacterRemovalReason reason)
{
	Montage_DeleteTimer(client);
	f_AmbyEndTime[client] = 0.0;
	f_MontageEndTime[client] = 0.0;

	if (reason != CF_CRR_DEATH)
		Sapper_DestroySapper(client);
}

public void Stabs_Prepare(int client, char abilityName[255])
{
	f_StabDMG[client] = CF_GetArgF(client, GENTLESPY, abilityName, "damage", 400.0);
	i_StabMode[client] = CF_GetArgI(client, GENTLESPY, abilityName, "damage_mode", 0);
	i_StabSlot[client] = CF_GetArgI(client, GENTLESPY, abilityName, "ability", -1);
	i_StabSlot_Lethal[client] = CF_GetArgI(client, GENTLESPY, abilityName, "ability_lethal", 11);
	f_StabDelay[client] = CF_GetArgF(client, GENTLESPY, abilityName, "delay", 3.0);
	f_StabDelay_Lethal[client] = CF_GetArgF(client, GENTLESPY, abilityName, "delay_lethal", 0.0);
	i_StabRagdoll[client] = CF_GetArgI(client, GENTLESPY, abilityName, "ragdoll", 0);
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
	if (gt <= f_MontageEndTime[attacker])
		forceStab = true;

	result = gt >= f_NextStab[attacker];
}

public void CF_OnBackstab(int attacker, int victim, float &damage)
{
	if (b_StabsEnabled[attacker])
	{
		damage = f_StabDMG[attacker];
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

public Action CF_OnCalcAttackInterval(int client, int weapon, int slot, char classname[255], float &rate)
{
	if (slot == 2 || GetGameTime() > f_AmbyEndTime[client])
		return Plugin_Continue;
		
	rate *= f_AmbyMult[client];
	return Plugin_Changed;
}

bool b_IsSapper[2049] = { false, ... };

int i_SapperOwner[2049] = { -1, ... };
int i_Sapper[MAXPLAYERS + 1] = { -1, ... };

float f_SapperDamaged[2049] = { 0.0, ... };
float f_SapperRadius[2049] = { 0.0, ... };
float f_SapperInterval[2049] = { 0.0, ... };
float f_SapperNextHit[2049] = { 0.0, ... };
float f_SapperDMG[2049] = { 0.0, ... };
float f_SapperFalloffStart[2049] = { 0.0, ... };
float f_SapperFalloffMax[2049] = { 0.0, ... };

float f_DisableEndTime[2049] = { 0.0, ... };

TFTeam sapperTeam;
float disableTime;

public void Sapper_Activate(int client, char abilityName[255])
{
	int hp = CF_GetArgI(client, GENTLESPY, abilityName, "health", 200);
	float duration = CF_GetArgF(client, GENTLESPY, abilityName, "duration", 6.0);
	float velocity = CF_GetArgF(client, GENTLESPY, abilityName, "velocity", 600.0);
	char sapName[255];
	Format(sapName, 255, "Sapper (%N)", client);

	float ang[3], pos[3], vel[3];
	GetClientEyePosition(client, pos);
	pos[2] -= 10.0;
	GetClientEyeAngles(client, ang);
	GetPointInDirection(pos, ang, 30.0, pos);
	GetVelocityInDirection(ang, velocity, vel);
	ang[0] = 0.0;
	ang[2] = 0.0;

	TFTeam team = TF2_GetClientTeam(client);
	PNPC sapper = PNPC(MODEL_SAPPER, team, hp, hp, _, 2.33, 0.0, Sapper_Think, GENTLESPY, 0.1, pos, ang, duration, _, sapName);
	if (!IsValidEntity(sapper.Index))
		return;

	sapper.SetBleedParticle("buildingdamage_sparks2");
	sapper.b_IsABuilding = true;
	sapper.b_CanBeDisabled = false;
	sapper.f_HealthBarHeight = 20.0;
	sapper.b_GibsForced = true;
	sapper.SetVelocity(vel);
	sapper.f_FrictionSideways = 0.0;
	sapper.f_FrictionForwards = 0.0;
	sapper.StopPathing();

	float mins[3], maxs[3];
	mins[0] = -5.706;
	mins[1] = -4.929;
	mins[2] = -1.554;
	maxs[0] = 3.126;
	maxs[1] = 5.389;
	maxs[2] = 3.112;
	sapper.SetBoundingBox(mins, maxs);

	for (int i = 0; i < sizeof(g_Gears); i++)
		sapper.AddGib(g_Gears[i]);

	float force[3];
	ang[0] = GetRandomFloat(-80.0, -90.0);
	ang[1] = GetRandomFloat(0.0, 360.0);
	ang[2] = 0.0;
	GetVelocityInDirection(ang, 400.0, force);
	sapper.PunchForce(force, true);

	EmitSoundToAll(SOUND_SAPPER_LOOP, sapper.Index);

	b_IsSapper[sapper.Index] = true;
	i_SapperOwner[sapper.Index] = GetClientUserId(client);
	i_Sapper[client] = EntIndexToEntRef(sapper.Index);

	f_SapperRadius[sapper.Index] = CF_GetArgF(client, GENTLESPY, abilityName, "radius", 300.0);
	f_SapperInterval[sapper.Index] = CF_GetArgF(client, GENTLESPY, abilityName, "interval", 0.8);
	f_SapperNextHit[sapper.Index] = GetGameTime() + f_SapperInterval[sapper.Index];
	f_SapperDMG[sapper.Index] = CF_GetArgF(client, GENTLESPY, abilityName, "damage", 40.0);
	f_SapperFalloffStart[sapper.Index] = CF_GetArgF(client, GENTLESPY, abilityName, "falloff_start", 100.0);
	f_SapperFalloffMax[sapper.Index] = CF_GetArgF(client, GENTLESPY, abilityName, "falloff_max", 0.5);

	AttachParticleToEntity(sapper.Index, team == TFTeam_Red ? PARTICLE_SAPPER_TRAIL_RED : PARTICLE_SAPPER_TRAIL_BLUE, "", duration);
	CF_ForceGesture(client);
}

public void Sapper_Think(int sapper)
{
	PNPC npc = view_as<PNPC>(sapper);

	if (CF_IsEntityInSpawn(sapper, (npc.i_Team == TFTeam_Red ? TFTeam_Blue : TFTeam_Red)))
	{
		npc.Gib();
		return;
	}

	int r = 255;
	int g = 120;
	int b = 120;
	if (npc.i_Team == TFTeam_Blue)
	{
		r = 120;
		b = 255;
	}

	float pos[3];
	npc.GetAbsOrigin(pos);
	SpawnRing(pos, f_SapperRadius[sapper] * 2.0, 0.0, 0.0, 0.0, Model_Lightning, Model_Glow, r, g, b, 220, 30, 0.1, 1.0, 12.0, 10);

	float gt = GetGameTime();
	if (gt >= f_SapperNextHit[sapper])
	{
		int owner = Sapper_GetOwner(sapper);
		sapperTeam = npc.i_Team;
		disableTime = f_SapperInterval[sapper];
		CF_GenericAOEDamage((IsValidClient(owner) ? owner : -1), sapper, 0, f_SapperDMG[sapper], DMG_GENERIC, f_SapperRadius[sapper], pos, f_SapperFalloffStart[sapper], f_SapperFalloffMax[sapper], true, false, _, GENTLESPY, Sapper_OnlyBuildings, GENTLESPY, Sapper_OnHit);

		SpawnRing(pos, 0.0, 0.0, 0.0, 0.0, Model_Laser, Model_Glow, r, g, b, 240, 10, 0.25, 6.0, 0.0, 10, f_SapperRadius[sapper] * 2.0);
		EmitSoundToAll(SOUND_SAPPER_WAVE, sapper, _, _, _, _, GetRandomInt(80, 120));
		f_SapperNextHit[sapper] = gt + f_SapperInterval[sapper];
	}
}

public bool Sapper_OnlyBuildings(int victim, int &attacker, int &inflictor, int &weapon, float &damage)
{
	char classname[255];
	GetEntityClassname(victim, classname, 255);
	if (StrContains(classname, "physics") != -1)
		return false;
		
	return IsABuilding(victim);
}

public void Sapper_OnHit(int victim, int &attacker, int &inflictor, int &weapon, float &damage)
{
	float pos[3];
	CF_WorldSpaceCenter(victim, pos);
	SpawnParticle(pos, sapperTeam == TFTeam_Red ? PARTICLE_SAPPER_HIT_RED : PARTICLE_SAPPER_HIT_BLUE);

	Sapper_DisableEntity(victim, disableTime);
}

public void Sapper_DisableEntity(int ent, float duration)
{
	if (f_DisableEndTime[ent] >= GetGameTime())
		return;

	f_DisableEndTime[ent] = GetGameTime() + duration - 0.01;

	if (PNPC_IsNPC(ent))
		view_as<PNPC>(ent).b_Disabled = true;
	else
		SetEntProp(ent, Prop_Send, "m_bDisabled", true);

	CreateTimer(duration, Sapper_UnDisable, EntIndexToEntRef(ent), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Sapper_UnDisable(Handle timer, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (IsValidEntity(ent) && GetGameTime() >= f_DisableEndTime[ent])
	{
		if (PNPC_IsNPC(ent))
			view_as<PNPC>(ent).b_Disabled = false;
		else
			SetEntProp(ent, Prop_Send, "m_bDisabled", false);
	}

	return Plugin_Continue;
}

public int Sapper_GetOwner(int sapper) { return GetClientOfUserId(i_SapperOwner[sapper]); }
public int Sapper_GetSapper(int owner) { return EntRefToEntIndex(i_Sapper[owner]); }

public void Sapper_DestroySapper(int client)
{
	int sapper = Sapper_GetSapper(client);
	if (IsValidEntity(sapper))
	{
		view_as<PNPC>(sapper).Gib();
	}

	i_Sapper[client] = -1;
}

public Action PNPC_OnPNPCTakeDamage(PNPC npc, float &damage, int weapon, int inflictor, int attacker, int &damagetype, int &damagecustom)
{
	if (b_IsSapper[npc.Index])
	{
		EmitSoundToAll(g_MetallicImpactSounds[GetRandomInt(0, sizeof(g_MetallicImpactSounds) - 1)], npc.Index, _, _, _, _, GetRandomInt(80, 110));
		f_SapperDamaged[npc.Index] = GetGameTime() + 0.1;
	}

	return Plugin_Continue;
}

public void PNPC_OnPNPCDestroyed(int entity)
{
	if (b_IsSapper[entity])
	{
		float pos[3];
		view_as<PNPC>(entity).GetAbsOrigin(pos);
		SpawnParticle(pos, PARTICLE_SAPPER_DESTROYED, 0.1);
		EmitSoundToAll(SOUND_SAPPER_DESTROYED, entity, _, _, _, _, GetRandomInt(90, 110));

		int owner = Sapper_GetOwner(entity);
		if (IsValidClient(owner) && f_SapperDamaged[entity] > GetGameTime())
		{
			PrintCenterText(owner, "Your sapper was destroyed!");
		}

		StopSound(entity, SNDCHAN_AUTO, SOUND_SAPPER_LOOP)
	}
}