/**
 * Called when a character runs any command.
 *
 * @param client			The client who ran the command.
 * @param buttons			The button(s) pressed.
 * @param impulse			Copyback buffer containing the current impulse command.
 * @param weapon			Entity index of the new weapon held by the player, 0 if weapon was not swapped.
 *
 * @return					Return Plugin_Continue to proceed as normal, Plugin_Changed if you altered any of these variables, or Plugin_Handled to prevent the command from being run.
 */
forward Action CF_OnPlayerRunCmd(int client, int &buttons, int &impulse, int &weapon)

/**
 * Called when a character presses M2.
 *
 * @param client			The client who ran the command.
 * @param buttons			The button(s) pressed.
 * @param impulse			Copyback buffer containing the current impulse command.
 * @param weapon			Entity index of the new weapon held by the player, 0 if weapon was not swapped.
 *
 * @return					Return Plugin_Continue to proceed as normal, Plugin_Changed if you altered any of these variables, or Plugin_Handled to prevent the command from being run.
 */
forward Action CF_OnPlayerM2(int client, int &buttons, int &impulse, int &weapon)

/**
 * Called when a character presses M3.
 *
 * @param client			The client who ran the command.
 * @param buttons			The button(s) pressed.
 * @param impulse			Copyback buffer containing the current impulse command.
 * @param weapon			Entity index of the new weapon held by the player, 0 if weapon was not swapped.
 *
 * @return					Return Plugin_Continue to proceed as normal, Plugin_Changed if you altered any of these variables, or Plugin_Handled to prevent the command from being run.
 */
forward Action CF_OnPlayerM3(int client, int &buttons, int &impulse, int &weapon)

/**
 * Called when a character presses their reload button.
 *
 * @param client			The client who ran the command.
 * @param buttons			The button(s) pressed.
 * @param impulse			Copyback buffer containing the current impulse command.
 * @param weapon			Entity index of the new weapon held by the player, 0 if weapon was not swapped.
 *
 * @return					Return Plugin_Continue to proceed as normal, Plugin_Changed if you altered any of these variables, or Plugin_Handled to prevent the command from being run.
 */
forward Action CF_OnPlayerReload(int client, int &buttons, int &impulse, int &weapon)
	
/**
 * Determines whether or not the chosen client was holding M2 during the previous frame.
 *
 * @param client		The client to check.
 *
 * @return True if the client was holding M2, false otherwise.
 */
native CF_GetM2Status(int client);

/**
 * Determines whether or not the chosen client was holding M3 during the previous frame.
 *
 * @param client		The client to check.
 *
 * @return True if the client was holding M3, false otherwise.
 */
native CF_GetM3Status(int client);

/**
 * Determines whether or not the chosen client was holding reload during the previous frame.
 *
 * @param client		The client to check.
 *
 * @return True if the client was holding reload, false otherwise.
 */
native CF_GetReloadStatus(int client);
	
bool b_M2Down[MAXPLAYERS + 1] = { false, ... };
bool b_M3Down[MAXPLAYERS + 1] = { false, ... };
bool b_ReloadDown[MAXPLAYERS + 1] = { false, ... };

GlobalForward g_OnRunCmd;
GlobalForward g_OnM2;
GlobalForward g_OnM3;
GlobalForward g_OnReload;

public void CFB_MakeForwards()
{
	g_OnRunCmd = new GlobalForward("CF_OnPlayerRunCmd", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_OnM2 = new GlobalForward("CF_OnPlayerM2", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_OnM3 = new GlobalForward("CF_OnPlayerM3", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_OnReload = new GlobalForward("CF_OnPlayerReload", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
}

public void CFB_MakeNatives()
{
	CreateNative("CF_GetM2Status", Native_CF_GetM2Status);
	CreateNative("CF_GetM3Status", Native_CF_GetM3Status);
	CreateNative("CF_GetReloadStatus", Native_CF_GetReloadStatus);
}

public Native_CF_GetM2Status(Handle plugin, int numParams)
{
	bool ReturnValue = false;
	
	int client = GetNativeCell(1);
	
	if (IsValidClient(client))
	{
		ReturnValue = b_M2Down[client];
	}
	
	return ReturnValue;
}

public Native_CF_GetM3Status(Handle plugin, int numParams)
{
	bool ReturnValue = false;
	
	int client = GetNativeCell(1);
	
	if (IsValidClient(client))
	{
		ReturnValue = b_M3Down[client];
	}
	
	return ReturnValue;
}

public Native_CF_GetReloadStatus(Handle plugin, int numParams)
{
	bool ReturnValue = false;
	
	int client = GetNativeCell(1);
	
	if (IsValidClient(client))
	{
		ReturnValue = b_ReloadDown[client];
	}
	
	return ReturnValue;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (!CF_IsPlayerCharacter(client))
		return Plugin_Continue;
	
	Action ReturnValue = CFB_CallForward(g_OnRunCmd, client, buttons, impulse, weapon); //NOTE TO SELF: This might be a very, very bad idea since it means we're calling a forward every frame for every player. Could get VERY expensive. The rest of the game mode is fairly light so it shouldn't be en enormous problem, but if it starts to get bad later on in development then definitely REMOVE this.
	
	if (ReturnValue != Plugin_Handled && ReturnValue != Plugin_Stop && (buttons & IN_ATTACK2 != 0) && !CF_GetM2Status(client))
	{
		ReturnValue = CFB_CallForward(g_OnM2, client, buttons, impulse, weapon);
	}
	
	if (ReturnValue != Plugin_Handled && ReturnValue != Plugin_Stop && (buttons & IN_ATTACK3 != 0) && !CF_GetM3Status(client))
	{
		ReturnValue = CFB_CallForward(g_OnM3, client, buttons, impulse, weapon);
	}
	
	if (ReturnValue != Plugin_Handled && ReturnValue != Plugin_Stop && (buttons & IN_RELOAD != 0) && !CF_GetReloadStatus(client))
	{
		ReturnValue = CFB_CallForward(g_OnReload, client, buttons, impulse, weapon);
	}
	
	b_M2Down[client] = (buttons & IN_ATTACK2 != 0);
	b_M3Down[client] = (buttons & IN_ATTACK3 != 0);
	b_ReloadDown[client] = (buttons & IN_RELOAD != 0);
	
	return ReturnValue;
}

public Action CFB_CallForward(GlobalForward forwardToCall, int client, int &buttons, int &impulse, int &weapon)
{
	Call_StartForward(forwardToCall);
	
	Call_PushCell(client);
	Call_PushCell(buttons);
	Call_PushCell(impulse);
	Call_PushCell(weapon);
	
	Action ReturnValue;
	Call_Finish(ReturnValue);
	return ReturnValue;
}