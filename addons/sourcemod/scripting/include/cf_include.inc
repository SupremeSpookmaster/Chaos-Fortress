#if defined _cfinc_included_
  #endinput
#endif
#define _cfinc_included_

  ////////////////////////////////////////
 ////////////// FORWARDS: ///////////////
////////////////////////////////////////

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
 * Called when a character presses their scoreboard button.
 *
 * @param client			The client who ran the command.
 * @param buttons			The button(s) pressed.
 * @param impulse			Copyback buffer containing the current impulse command.
 * @param weapon			Entity index of the new weapon held by the player, 0 if weapon was not swapped.
 *
 * @return					Return Plugin_Continue to proceed as normal, Plugin_Changed if you altered any of these variables, or Plugin_Handled to prevent the command from being run.
 */
forward Action CF_OnPlayerTab(int client, int &buttons, int &impulse, int &weapon)

/**
 * Called when a character presses their jump button. NOTICE: This runs even if they are already in the air, it is purely to detect the button press.
 *
 * @param client			The client who ran the command.
 * @param buttons			The button(s) pressed.
 * @param impulse			Copyback buffer containing the current impulse command.
 * @param weapon			Entity index of the new weapon held by the player, 0 if weapon was not swapped.
 *
 * @return					Return Plugin_Continue to proceed as normal, Plugin_Changed if you altered any of these variables, or Plugin_Handled to prevent the command from being run.
 */
forward Action CF_OnPlayerJump(int client, int &buttons, int &impulse, int &weapon)

/**
 * Called when a character presses their crouch button. NOTICE: This runs even if they are already in the air, it is purely to detect the button press.
 *
 * @param client			The client who ran the command.
 * @param buttons			The button(s) pressed.
 * @param impulse			Copyback buffer containing the current impulse command.
 * @param weapon			Entity index of the new weapon held by the player, 0 if weapon was not swapped.
 *
 * @return					Return Plugin_Continue to proceed as normal, Plugin_Changed if you altered any of these variables, or Plugin_Handled to prevent the command from being run.
 */
forward Action CF_OnPlayerCrouch(int client, int &buttons, int &impulse, int &weapon)

/**
 * Called when a character calls for medic, AKA when they press the E key.
 *
 * @param client			The client who ran the command.
 */
forward void CF_OnPlayerCallForMedic(int client)

/**
 * Called when a character takes damage, before any modifications have been made by Chaos Fortress.
 *
 * For the sake of organization and to avoid plugin execution conflicts: 
 *
 * - Put damage bonuses in CF_OnTakeDamageAlive_Bonus.
 * - Put damage penalties, such as damage resistance, in CF_OnTakeDamageAlive_Resistance.
 * - Put anything which depends on the damage dealt (for example: gaining 1 imaginary token for every 40 points of damage dealt) in 
 * 		CF_OnTakeDamageAlive_Post.
 *
 * @param victim					The player who took damage.
 * @param attacker					The player who dealt the damage.
 * @param inflictor					The entity which inflicted the damage (EX: Engineer's sentry gun in vanilla TF2)
 * @param damage					The damage dealt.
 * @param damagetype				The type of damage dealt.
 * @param weapon					The weapon which dealt the damage.
 * @param damageForce				The force of the damage, used for ragdolls.
 * @param damagePosition			The position from which damageForce is applied to ragdolls.
 * @param damagecustom				Custom damage flags such as backstabs.
 *
 * @return	Return Plugin_Continue to proceed as normal, Plugin_Changed if you changed any of the values, Plugin_Stop or Plugin_Handled to prevent the damage altogether.
 */
forward Action CF_OnTakeDamageAlive_Pre(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon,
	float damageForce[3], float damagePosition[3], int &damagecustom)
	
/**
 * Called when a character takes damage, after CF_OnTakeDamageAlive_Pre has been called.
 * This is where you should put your damage bonuses.
 *
 * @param victim					The player who took damage.
 * @param attacker					The player who dealt the damage.
 * @param inflictor					The entity which inflicted the damage (EX: Engineer's sentry gun in vanilla TF2)
 * @param damage					The damage dealt.
 * @param damagetype				The type of damage dealt.
 * @param weapon					The weapon which dealt the damage.
 * @param damageForce				The force of the damage, used for ragdolls.
 * @param damagePosition			The position from which damageForce is applied to ragdolls.
 * @param damagecustom				Custom damage flags such as backstabs.
 *
 * @return	Return Plugin_Continue to proceed as normal, Plugin_Changed if you changed any of the values, Plugin_Stop or Plugin_Handled to prevent the damage altogether.
 */
forward Action CF_OnTakeDamageAlive_Bonus(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon,
	float damageForce[3], float damagePosition[3], int &damagecustom)

/**
 * Called when a character takes damage, after CF_OnTakeDamageAlive_Pre and CF_OnTakeDamageAlive_Bonus have been called.
 * This is where you should put your damage penalties/resistances.
 *
 * @param victim					The player who took damage.
 * @param attacker					The player who dealt the damage.
 * @param inflictor					The entity which inflicted the damage (EX: Engineer's sentry gun in vanilla TF2)
 * @param damage					The damage dealt.
 * @param damagetype				The type of damage dealt.
 * @param weapon					The weapon which dealt the damage.
 * @param damageForce				The force of the damage, used for ragdolls.
 * @param damagePosition			The position from which damageForce is applied to ragdolls.
 * @param damagecustom				Custom damage flags such as backstabs.
 *
 * @return	Return Plugin_Continue to proceed as normal, Plugin_Changed if you changed any of the values, Plugin_Stop or Plugin_Handled to prevent the damage altogether.
 */
forward Action CF_OnTakeDamageAlive_Resistance(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon,
	float damageForce[3], float damagePosition[3], int &damagecustom)
	
/**
 * Called when a character takes damage, after all of Chaos Fortress' other OnTakeDamageAlive forwards have been called.
 * This is where you should put anything that depends on damage dealt, such as gaining 1 imaginary token for every 40 points of damage dealt.
 *
 * @param victim					The player who took damage.
 * @param attacker					The player who dealt the damage.
 * @param inflictor					The entity which inflicted the damage (EX: Engineer's sentry gun in vanilla TF2)
 * @param damage					The damage dealt.
 * @param damagetype				The type of damage dealt.
 * @param weapon					The weapon which dealt the damage.
 * @param damageForce				The force of the damage, used for ragdolls.
 * @param damagePosition			The position from which damageForce is applied to ragdolls.
 * @param damagecustom				Custom damage flags such as backstabs.
 *
 * @return	Return Plugin_Continue to proceed as normal, Plugin_Changed if you changed any of the values, Plugin_Stop or Plugin_Handled to prevent the damage altogether.
 */
forward Action CF_OnTakeDamageAlive_Post(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon,
	float damageForce[3], float damagePosition[3], int &damagecustom)
	
/**
 * Called when a player's Chaos Fortress killstreak is changed.
 *
 * @param client			The client whose killstreak was changed.
 * @param kills				The new killstreak.
 */
forward void CF_OnKillstreakChanged(int client, int kills)

/**
 * Called when a character is killed.
 *
 * @param victim			The player who was killed.
 * @param inflictor			The entity which inflicted the killing blow.
 * @param attacker			The player who is credited for the kill.
 * @param deadRinger		0 if the kill was real, 1 if it was a dead ringer.
 */
forward void CF_OnPlayerKilled(int victim, int inflictor, int attacker, int deadRinger)

/**
 * Called when the Chaos Fortress round state is changed.
 *
 * @param state				The new round state. 0: Pre-game/setup time/waiting for players, 1: round in progress, 2: round has ended.
 */
forward void CF_OnRoundStateChanged(int state)
	
  ///////////////////////////////////////
 ////////////// NATIVES: ///////////////
///////////////////////////////////////
	
/**
 * Retrieves the killstreak of a given client.
 *
 * @param client		The client whose killstreak to retrieve.
 *
 * @return The player's current killstreak. 0 if dead, -1 if invalid client.
 */
native CF_GetKillstreak(int client);

/**
 * Sets the killstreak of a given client.
 *
 * @param client		The client whose killstreak to set.
 * @param kills			The new killstreak.
 * @param killer		The player who scored the kill. Used for announcing the end of a long killstreak.
 */
native CF_SetKillstreak(int client, int kills, int killer)

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

/**
 * Determines whether or not the chosen client was holding their jump key during the previous frame.
 *
 * @param client		The client to check.
 *
 * @return True if the client was holding jump, false otherwise.
 */
native CF_GetJumpStatus(int client);

/**
 * Determines whether or not the chosen client was holding their scoreboard button during the previous frame.
 *
 * @param client		The client to check.
 *
 * @return True if the client was holding tab, false otherwise.
 */
native CF_GetTabStatus(int client);

/**
 * Determines whether or not the chosen client was holding crouch during the previous frame.
 *
 * @param client		The client to check.
 *
 * @return True if the client was holding crouch, false otherwise.
 */
native CF_GetCrouchStatus(int client);

/**
 * Retrieves the current round state.
 *
 * @return The current round state. 0: pre-game/waiting for players/setup, 1: round in progress, 2: round has ended.
 */
native CF_GetRoundState();

/**
 * Retrieves the client's current character config.
 *
 * @param client		The client whose config to retrieve.
 * @param buffer		Output buffer.
 * @param size			Output buffer size.
 *
 * @return The config used by the client's current character, stored in the buffer. Returns an empty string is the client is invalid, or not currently a character. 
 */
native CF_GetPlayerConfig(int client, char[] buffer, int size);

/**
 * Sets the client's current character config.
 *
 * @param client		The client whose config to set.
 * @param confName		The new config.
 */
native CF_SetPlayerConfig(int client, char[] confName);

/**
 * Determines whether or not the chosen client is a character.
 *
 * @param client		The client to check.
 *
 * @return True if the client is a character, false if they are invalid or not a character.
 */
native bool CF_IsPlayerCharacter(int client);

/**
 * Gives a weapon to the given client.
 *
 * @param client		The client to give the weapon to.
 * @param name			The weapon's classname.
 * @param index			The weapon's index.
 * @param level			The weapon's level.
 * @param qual			The weapon's quality.
 * @param slot			The weapon's slot. 0 for primary, 1 for secondary, 2 for melee.
 * @param reserve		The weapon's reserve ammo.
 * @param clip			The ammo held in the weapon's clip/magazine/whatever.
 * @param att			The weapon's attributes.
 * @param override		Optional weapon model override.
 * @param visible		Should the weapon be visible?
 * @param unequip		Should whichever weapon(s) currently in this weapon's slot be removed before equipping this weapon?
 * @param useVC			Should this weapon use the ViewChange system? EX: If we give the scout a wrench, this will switch his first-person and third-person animations to that of the engineer while he has the wrench out, making it look like he is actually holding the wrench. USE THIS WITH CAUTION! Certain animations look VERY bad on certain models, such as Heavy animations turning every other class into abominations.
 * @param ForceClass	Class to force this weapon to use the animations of, if using ViewChange. 1-9 for the mercs, anything above 9 is considered all-class.
 *
 * @return The entity index of the spawned weapon, -1 if not valid.
 */
native int CF_SpawnWeapon(int client, char[] name, int index, int level, int qual, int slot, int reserve, int clip, const char[] att, char override[255] = "", bool visible = true, bool unequip = true, bool useVC = false, int ForceClass = 0);

/**
 * Gets the class of the player's current character.
 *
 * @param client		The client to check.
 *
 * @return The class of the player's character, TFClass_Unknown if invalid.
 */
native TFClassType CF_GetCharacterClass(int client);