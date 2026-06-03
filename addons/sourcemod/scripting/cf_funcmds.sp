#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <tf2_stocks>
#include <clientprefs>
//Easy use dev plugin

#define TRAINSOUND "ambient/alarms/train_horn2.wav"
#define TRAIN2SOUND "ambient/alarms/razortrain_horn1.wav"

bool overnag = false;

stock bool IsValidClient(int client)
{
	if(!client)
		return false;

	if(client > MaxClients || client < 0)
		return false;
    
	if(!IsClientInGame(client))
		return false;

	return true;
}

public void OnPluginStart()
{
	overnag = false;
    RegAdminCmd("overnag", Cmd_Overnag, ADMFLAG_KICK, "Over-Nag");
    RegAdminCmd("aysay", Cmd_Annoyance, ADMFLAG_KICK, "Fancy text i guess with sound");
	//RegAdminCmd("rp_boss", Cmd_RespawnBoss, ADMFLAG_KICK, "Respawns the player or fixes the player with the same boss");
	//RegAdminCmd("force_slot", Cmd_ForceSlot, ADMFLAG_ROOT, "Force Usage of the Slot");
}

public void OnMapStart()
{
	PrecacheSound(TRAINSOUND, true);
	PrecacheSound(TRAIN2SOUND, true);
}

public Action Cmd_Overnag(int client, int args)
{
	overnag = !overnag;
	if(overnag)
	{
		OverTime();
		CreateTimer(1.0, Timer_OVERNAG, _ ,TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Handled;
}
static Action Timer_OVERNAG(Handle Timer)
{
	if(!overnag)
	{
		//delete Timer;
		KillTimer(Timer);
		return Plugin_Stop;
	}
	OverTime();
	return Plugin_Continue;
}

static void OverTime()
{
	Event event = CreateEvent("overtime_nag");
	event.Fire();
}
public Action Cmd_Annoyance(int client, int args)
{
	if(args < 1)
	{
		return Plugin_Handled;
	}
	char arg[255];
	GetCmdArgString(arg, sizeof(arg));
	if(!arg[0])
	{
		return Plugin_Handled;
	}
	EmitSoundToAll(GetRandomInt(0, 1) ? TRAIN2SOUND : TRAINSOUND, _, _, 120);
	SetHudTextParams(-1.0, 0.45, 3.0, 255, 64, 64, 192);
	for(int clients = 1 ; clients <= MaxClients ; clients++)
	{
		if(!IsValidClient(clients))
		continue;

		ShowHudText(clients, -1, arg);
	}
	
	PrintToChatAll(arg);
	return Plugin_Handled;
}