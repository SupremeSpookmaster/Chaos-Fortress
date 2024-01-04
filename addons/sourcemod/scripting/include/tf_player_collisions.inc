#if defined _tf2pc_included_
  #endinput
#endif
#define _tf2pc_included_

/**
 * Called when a player is close enough to an enemy that a collision is imminent.
 *
 * @param client			The client who is close.
 * @param other				The enemy they are near.
 * @param result			Set to false and return Plugin_Changed to prevent collision. Otherwise, ignore and return Plugin_Continue.
 *
 * @return Return Plugin_Continue to leave player collision logic unchanged. Return Plugin_Changed with result set to false to prevent player collision.
 */
forward Action PlayerCollisions_OnCheckCollision(int client, int other, bool &result);