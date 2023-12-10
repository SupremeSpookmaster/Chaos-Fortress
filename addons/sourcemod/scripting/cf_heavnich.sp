#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define HEAVNICH	"cf_heavnich"
#define SHARE		"heavnich_share_sandviches"
#define CHOW		"heavnich_chow_down"
#define MEGA		"heavnich_mega_cosmetics"

#define MODEL_SANDVICH					"models/items/plate.mdl"

#define PARTICLE_MEGA_TRANSFORM_RED		"drg_cow_explosioncore_charged"
#define PARTICLE_MEGA_TRANSFORM_BLUE	"drg_cow_explosioncore_charged_blue"
#define PARTICLE_MEGA_END				"drg_wrenchmotron_teleport"

#define SOUND_MEGA_TRANSFORM_1		"mvm/mvm_deploy_giant.wav"
#define SOUND_MEGA_TRANSFORM_2		"mvm/mvm_tank_deploy.wav"
#define SOUND_MEGA_TRANSFORM_3		"mvm/giant_heavy/giant_heavy_entrance.wav"
#define SOUND_MEGA_TRANSFORM_LOOP	"mvm/giant_heavy/giant_heavy_loop.wav"
#define SOUND_MEGA_WARNING			"mvm/mvm_cpoint_klaxon.wav"
#define SOUND_MEGA_END				"mvm/mvm_deploy_small.wav"
#define SOUND_MEGA_REV				"mvm/giant_heavy/giant_heavy_gunwindup.wav"
#define SOUND_MEGA_UNREV			"mvm/giant_heavy/giant_heavy_gunwinddown.wav"
#define SOUND_MEGA_SPIN				"mvm/giant_heavy/giant_heavy_gunspin.wav"
#define SOUND_MEGA_GUNFIRE			"mvm/giant_heavy/giant_heavy_gunfire.wav"
#define SOUND_MEGA_STEP_1			"mvm/giant_heavy/giant_heavy_step01.wav"
#define SOUND_MEGA_STEP_2			"mvm/giant_heavy/giant_heavy_step02.wav"
#define SOUND_MEGA_SHOTGUN			"mvm/giant_soldier/giant_soldier_rocket_shoot.wav.wav"

#define CATCH_SOUND_REV				"minigun_wind_up"
#define CATCH_SOUND_UNREV			"minigun_wind_down"
#define CATCH_SOUND_SPIN			"minigun_spin"
#define CATCH_SOUND_MINISHOOT		"minigun_shoot"
#define CATCH_SOUND_STEP			"player/footsteps/"
#define CATCH_SOUND_SHOTGUN			"shotgun_shoot"

public void OnMapStart()
{
	PrecacheSound(SOUND_MEGA_TRANSFORM_1, true);
	PrecacheSound(SOUND_MEGA_TRANSFORM_2, true);
	PrecacheSound(SOUND_MEGA_TRANSFORM_3, true);
	PrecacheSound(SOUND_MEGA_TRANSFORM_LOOP, true);
	PrecacheSound(SOUND_MEGA_WARNING, true);
	PrecacheSound(SOUND_MEGA_END, true);
	PrecacheSound(SOUND_MEGA_REV, true);
	PrecacheSound(SOUND_MEGA_UNREV, true);
	PrecacheSound(SOUND_MEGA_SPIN, true);
	PrecacheSound(SOUND_MEGA_GUNFIRE, true);
	PrecacheSound(SOUND_MEGA_STEP_1, true);
	PrecacheSound(SOUND_MEGA_STEP_2, true);
	PrecacheSound(SOUND_MEGA_SHOTGUN, true);
	
	PrecacheModel(MODEL_SANDVICH);
}

public void OnPluginStart()
{
	
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, HEAVNICH))
		return;
		
	if (StrContains(abilityName, SHARE) != -1)
		Share_Activate(client, abilityName);
		
	if (StrContains(abilityName, CHOW) != -1)
		Chow_Activate(client, abilityName);
		
	if (StrContains(abilityName, MEGA) != -1)
		Mega_Activate(client, abilityName);
}

bool b_SandvichCanHealSelf[MAXPLAYERS + 1] = { false, ... };
public void Share_Activate(int client, char abilityName[255])
{
	int num = CF_GetArgI(client, HEAVNICH, abilityName, "sandviches");
	float delay = CF_GetArgF(client, HEAVNICH, abilityName, "delay");
	float velocity = CF_GetArgF(client, HEAVNICH, abilityName, "velocity");
	float lifespan = CF_GetArgF(client, HEAVNICH, abilityName, "lifespan");
	float radius = CF_GetArgF(client, HEAVNICH, abilityName, "radius");
	b_SandvichCanHealSelf[client] = CF_GetArgI(client, HEAVNICH, abilityName, "self") > 0;
	float amt = CF_GetArgF(client, HEAVNICH, abilityName, "heal_amt");
	int type = CF_GetArgI(client, HEAVNICH, abilityName, "heal_type");
	float mult = CF_GetArgF(client, HEAVNICH, abilityName, "heal_mult");
	
	Share_TossSandvich(client, num, delay, velocity, lifespan, radius, amt, type, mult);
}

public void Share_TossSandvich(int client, int num, float delay, float velocity, float lifespan, float radius, float amt, int type, float mult)
{
	if (!IsValidMulti(client))
		return;
		
	float pos[3], ang[3], buffer[3], vel[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);
	
	int sandvich = CF_CreateHealthPickup(client, amt, radius, type, lifespan, HEAVNICH, Share_Filter, pos, MODEL_SANDVICH, _, _, _, _, _, mult, MODEL_SANDVICH);
	if (IsValidEntity(sandvich))
	{
		GetAngleVectors(ang, buffer, NULL_VECTOR, NULL_VECTOR);
		vel[0] = buffer[0] * velocity;
		vel[1] = buffer[1] * velocity;
		vel[2] = buffer[2] * velocity;
		
		TeleportEntity(sandvich, pos, NULL_VECTOR, vel);
	}
	
	num--;
	if (num > 0)
	{
		DataPack pack = new DataPack();
		CreateDataTimer(delay, Share_TossAnotherOne, pack, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack, GetClientUserId(client));
		WritePackCell(pack, num);
		WritePackFloat(pack, delay);
		WritePackFloat(pack, velocity);
		WritePackFloat(pack, lifespan);
		WritePackFloat(pack, radius);
		WritePackFloat(pack, amt);
		WritePackCell(pack, type);
		WritePackFloat(pack, mult);
	}
}

public Action Share_TossAnotherOne(Handle sandviches, DataPack pack)
{
	ResetPack(pack);
	
	int client = GetClientOfUserId(ReadPackCell(pack));
	int num = ReadPackCell(pack);
	float delay = ReadPackFloat(pack);
	float velocity = ReadPackFloat(pack);
	float lifespan = ReadPackFloat(pack);
	float radius = ReadPackFloat(pack);
	float amt = ReadPackFloat(pack);
	int type = ReadPackCell(pack);
	float mult = ReadPackFloat(pack);
	
	if (IsValidMulti(client))
		Share_TossSandvich(client, num, delay, velocity, lifespan, radius, amt, type, mult);
	
	return Plugin_Continue;
}

public bool Share_Filter(int sandvich, int owner, int eater)
{
	if (!IsValidClient(owner))
		return true;
		
	return (owner != eater || b_SandvichCanHealSelf[owner]);
}

float f_Eating[MAXPLAYERS + 1] = { 0.0, ... };

public void Chow_Activate(int client, char abilityName[255])
{
	CF_DoAbility(client, "cf_generic_abilities", "generic_weapon_sandvich");
	f_Eating[client] = GetGameTime() + 4.2;
	
	float target = CF_GetArgF(client, HEAVNICH, abilityName, "target_hp");
	float amount_per = target / 4.0;
	
	DataPack pack = new DataPack();
	CreateDataTimer(1.0, Chow_Heal, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, GetClientUserId(client));
	WritePackFloat(pack, target);
	WritePackFloat(pack, amount_per);
}

public Action Chow_Heal(Handle healem, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	float target = ReadPackFloat(pack);
	float amount = ReadPackFloat(pack);
	
	if (!IsValidMulti(client))
		return Plugin_Stop;
		
	if (GetGameTime() > f_Eating[client])
		return Plugin_Stop;
		
	CF_HealPlayer(client, client, RoundFloat(amount), (target / CF_GetCharacterMaxHealth(client)));
	
	return Plugin_Continue;
}

public Action CF_OnPlayerRunCmd(int client, int &buttons, int &impulse, int &weapon)
{
	if (GetGameTime() < f_Eating[client])
	{
		int wep = TF2_GetActiveWeapon(client);
		if (IsValidEntity(wep))
		{
			char classname[255];
			GetEntityClassname(wep, classname, sizeof(classname));
			
			if (StrEqual(classname, "tf_weapon_lunchbox"))
			{
				buttons |= IN_ATTACK;
				return Plugin_Changed;
			}
		}
	}
	
	return Plugin_Continue;
}

float f_MegaEndTime[MAXPLAYERS + 1] = { 0.0, ... };

public void Mega_Activate(int client, char abilityName[255])
{
	float duration = CF_GetArgF(client, HEAVNICH, abilityName, "duration");
	f_MegaEndTime[client] = duration + GetGameTime();
	
	EmitSoundToAll(SOUND_MEGA_TRANSFORM_1, client, SNDCHAN_STATIC, 120, _, 1.0);
	EmitSoundToAll(SOUND_MEGA_TRANSFORM_2, client, SNDCHAN_STATIC, 80, _, 1.0, 80);
	//EmitSoundToAll(SOUND_MEGA_TRANSFORM_3, _, _, 120);
	EmitSoundToAll(SOUND_MEGA_TRANSFORM_LOOP, client, SNDCHAN_STATIC, 80, _, 1.0, 80);
	EmitSoundToAll(SOUND_MEGA_WARNING, client, SNDCHAN_STATIC, 120, _, 1.0);
	
	CreateTimer(3.0, Mega_Warning, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(duration, Mega_End, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	
	RequestFrame(Mega_EffectParticles, GetClientUserId(client));
}

public Action Mega_Warning(Handle warning, int id)
{
	int client = GetClientOfUserId(id);
	
	if (!IsValidMulti(client))
		return Plugin_Stop;
		
	if (f_MegaEndTime[client] <= GetGameTime())
		return Plugin_Stop;
		
	EmitSoundToAll(SOUND_MEGA_WARNING, client, SNDCHAN_STATIC, 120, _, 1.0);
	
	return Plugin_Continue;
}

public Action Mega_End(Handle warning, int id)
{
	int client = GetClientOfUserId(id);
	
	if (!IsValidMulti(client))
		return Plugin_Continue;
		
	CF_AttachParticle(client, PARTICLE_MEGA_END, "root", _, 4.0);
	EmitSoundToAll(SOUND_MEGA_END, client, SNDCHAN_STATIC, _, _, 1.0);
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(client))
			StopSound(client, SNDCHAN_STATIC, SOUND_MEGA_TRANSFORM_LOOP);
				
	}
	
	return Plugin_Continue;
}

public void Mega_EffectParticles(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return;
		
	char particle[255];
	if (TF2_GetClientTeam(client) == TFTeam_Red)
		particle = PARTICLE_MEGA_TRANSFORM_RED;
	else
		particle = PARTICLE_MEGA_TRANSFORM_BLUE;
		
	for (int i = 0; i < 18; i++)
	{
		CF_AttachParticle(client, particle, "flag", _, 2.0, GetRandomFloat(-90.0, 90.0), GetRandomFloat(-90.0, 90.0), GetRandomFloat(-90.0, 90.0));
	}
}

public Action CF_SoundHook(char strSound[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
	if (!IsValidMulti(entity))
		return Plugin_Continue;
		
	if (f_MegaEndTime[entity] <= GetGameTime())
		return Plugin_Continue;

	level += (level / 4);	//Make all sounds produced by the user louder.

	if (StrContains(strSound, CATCH_SOUND_REV) != -1)
		Format(strSound, sizeof(strSound), "%s", SOUND_MEGA_REV);
	if (StrContains(strSound, CATCH_SOUND_UNREV) != -1)
		Format(strSound, sizeof(strSound), "%s", SOUND_MEGA_UNREV);
	if (StrContains(strSound, CATCH_SOUND_SPIN) != -1)
		Format(strSound, sizeof(strSound), "%s", SOUND_MEGA_SPIN);
	if (StrContains(strSound, CATCH_SOUND_MINISHOOT) != -1)
		Format(strSound, sizeof(strSound), "%s", SOUND_MEGA_GUNFIRE);
	if (StrContains(strSound, CATCH_SOUND_STEP) != -1)
		Format(strSound, sizeof(strSound), "%s", GetRandomInt(0, 1) == 1 ? SOUND_MEGA_STEP_1 : SOUND_MEGA_STEP_2);
	if (StrContains(strSound, CATCH_SOUND_SHOTGUN) != -1)
		Format(strSound, sizeof(strSound), "%s", SOUND_MEGA_SHOTGUN);

	if (StrContains(strSound, "vo/") != -1 && StrContains(strSound, "announcer") == -1 && StrContains(strSound, "vo/mvm/") == -1)
	{
		//Borrowed from MasterOfTheXP's "Be the Robot" (https://forums.alliedmods.net/showthread.php?p=1772818) and modified because I am lazy.
		
		pitch -= (pitch / 4);
		
		char placeholder[255];
		strcopy(placeholder, 255, strSound);
		
		ReplaceString(placeholder, sizeof(placeholder), "vo/", "vo/mvm/norm/", false);
		ReplaceString(placeholder, sizeof(placeholder), ".wav", ".mp3", false);
		
		char class[255], class_mvm[255];
		TF2_GetNameOfClass(TF2_GetPlayerClass(entity), class, sizeof(class));
		Format(class_mvm, sizeof(class_mvm), "%s_mvm", class);
		
		ReplaceString(placeholder, sizeof(placeholder), class, class_mvm, false);
		
		char checkit[PLATFORM_MAX_PATH];
		Format(checkit, sizeof(checkit), "sound/%s", placeholder);
		
		if (!FileExists(checkit) && !FileExists(checkit, true))
			return Plugin_Handled;
		
		Format(strSound, sizeof(strSound), "%s", placeholder);
		PrecacheSound(placeholder);
	}
	
	return Plugin_Changed;
}

public void CF_OnCharacterRemoved(int client)
{
	if (f_MegaEndTime[client] > GetGameTime())
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(client))
				StopSound(client, SNDCHAN_STATIC, SOUND_MEGA_TRANSFORM_LOOP);	
		}
	}
	
	f_MegaEndTime[client] = 0.0;
}