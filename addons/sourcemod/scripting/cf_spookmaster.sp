#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define SPOOKMASTER		"cf_spookmaster"
#define HARVESTER		"soul_harvester"
#define ABSORB			"soul_absorption"
#define DISCARD			"soul_discard"
#define CALCIUM			"calcium_cataclysm"

public void OnMapStart()
{
	
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (StrContains(abilityName, HARVESTER) != -1)
		Harvester_Activate(client, abilityName);
		
	if (StrEqual(abilityName, ABSORB))
		Absorb_Activate(client, abilityName);
}

int Harvester_LeftParticle[MAXPLAYERS + 1] = { -1, ... };
int Harvester_RightParticle[MAXPLAYERS + 1] = { -1, ... };

float Discard_Bonus[MAXPLAYERS + 1] = { 0.0, ... };

public void Harvester_Activate(int client, char abilityName[255])
{
	float resources = CF_GetSpecialResource(client);
	if (resources > 0.0)
	{
		int L = EntRefToEntIndex(Harvester_LeftParticle[client]);
		int R = EntRefToEntIndex(Harvester_RightParticle[client]);
			
		char LName[255], RName[255];
		if (TF2_GetClientTeam(client) == TFTeam_Red)
		{
			CF_GetArgS(client, SPOOKMASTER, abilityName, "left_red", LName, sizeof(LName));
			CF_GetArgS(client, SPOOKMASTER, abilityName, "right_red", RName, sizeof(RName));
		}
		else
		{
			CF_GetArgS(client, SPOOKMASTER, abilityName, "left_blue", LName, sizeof(LName));
			CF_GetArgS(client, SPOOKMASTER, abilityName, "right_blue", RName, sizeof(RName));
		}
		
		if (!IsValidEntity(L))
			Harvester_LeftParticle[client] = EntIndexToEntRef(CF_AttachParticle(client, LName, "effect_hand_L", true));
			
		if (!IsValidEntity(R))
			Harvester_RightParticle[client] = EntIndexToEntRef(CF_AttachParticle(client, RName, "effect_hand_R", true));
	}
	else
	{
		Harvester_DeleteParticles(client);
	}
}

public void Harvester_DeleteParticles(int client)
{
	int L = EntRefToEntIndex(Harvester_LeftParticle[client]);
	int R = EntRefToEntIndex(Harvester_RightParticle[client]);
	
	if (IsValidEntity(L))
		RemoveEntity(L);
		
	if (IsValidEntity(R))
		RemoveEntity(R);
		
	Harvester_LeftParticle[client] = -1;
	Harvester_RightParticle[client] = -1;
}

int Absorb_Uses[MAXPLAYERS + 1] = { 0, ... };
float Absorb_Health[MAXPLAYERS + 1] = { 0.0, ... };
float Absorb_Speed[MAXPLAYERS + 1] = { 0.0, ... };
float Absorb_Heal[MAXPLAYERS + 1] = { 0.0, ... };
float Absorb_Swing[MAXPLAYERS + 1] = { 0.0, ... };
float Absorb_Melee[MAXPLAYERS + 1] = { 0.0, ... };

public void Absorb_Activate(int client, char abilityName[255])
{
	Discard_Bonus[client] += CF_GetArgF(client, SPOOKMASTER, abilityName, "discard_bonus");
	
	float bonusHP = CF_GetArgF(client, SPOOKMASTER, abilityName, "health_bonus");
	float currentHP = GetAttributeValue(client, 26, 0.0);
	Absorb_Health[client] = bonusHP + currentHP;
	
	float bonusSpeed = CF_GetArgF(client, SPOOKMASTER, abilityName, "speed_bonus");
	float currentSpeed = GetAttributeValue(client, 107, 0.0);
	Absorb_Speed[client] = bonusSpeed + currentSpeed;
	
	Absorb_Heal[client] = CF_GetArgF(client, SPOOKMASTER, abilityName, "heal");
	
	int weapon = GetPlayerWeaponSlot(client, 2);
	if (!IsValidEntity(weapon))
		return;
		
	float bonusSwing = CF_GetArgF(client, SPOOKMASTER, abilityName, "swing_bonus");
	float currentSwing = GetAttributeValue(weapon, 396, 1.0);
	Absorb_Swing[client] = currentSwing - bonusSwing;
	
	float bonusDmg = CF_GetArgF(client, SPOOKMASTER, abilityName, "melee_bonus");
	float currentDmg = GetAttributeValue(weapon, 2, 1.0);
	Absorb_Melee[client] = bonusDmg + currentDmg;
	
	Absorb_SetStats(client);
	Absorb_Uses[client]++;
}

void Absorb_SetStats(int client, float NumTimes = 0.0)
{
	TF2Attrib_SetByDefIndex(client, 26, Absorb_Health[client]);
	TF2Attrib_SetByDefIndex(client, 107, Absorb_Speed[client]);
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
	
	DataPack pack = new DataPack();
	RequestFrame(Absorb_HealOnDelay, pack);
	WritePackCell(pack, GetClientUserId(client));
	WritePackFloat(pack, NumTimes > 0.0 ? Absorb_Heal[client] * NumTimes : Absorb_Heal[client])
	
	int weapon = GetPlayerWeaponSlot(client, 2);
	if (!IsValidEntity(weapon))
		return;
		
	TF2Attrib_SetByDefIndex(weapon, 396, Absorb_Swing[client]);
	TF2Attrib_SetByDefIndex(weapon, 2, Absorb_Melee[client]);
}

public void Absorb_HealOnDelay(DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	float amt = ReadPackFloat(pack);
	delete pack;
	
	CF_HealPlayer(client, client, amt, 1.0);
}

public void CF_OnCharacterRemoved(int client)
{
	Discard_Bonus[client] = 0.0;
	Absorb_Uses[client] = 0;
}

public void CF_OnCharacterCreated(int client)
{
	if (CF_HasAbility(client, SPOOKMASTER, ABSORB) && Absorb_Uses[client] > 0)
		Absorb_SetStats(client, float(Absorb_Uses[client]));
}