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