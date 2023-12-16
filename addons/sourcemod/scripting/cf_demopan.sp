#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define DEMOPAN		"cf_demopan"
#define PASSIVES	"demopan_passives"
#define BOMB		"demopan_refined_bomb"
#define SHIELD		"demopan_medigun_shield"
#define TRADE		"demopan_ultimate"

int lgtModel;
int glowModel;

#define PARTICLE_REFINED_RED			""
#define PARTICLE_REFINED_BLUE			""

public void OnMapStart()
{
	lgtModel = PrecacheModel("materials/sprites/lgtning.vmt");
	glowModel = PrecacheModel("materials/sprites/glow02.vmt");
}

DynamicHook g_DHookRocketExplode;

public void OnPluginStart()
{
	GameData gamedata = LoadGameConfigFile("chaos_fortress");
	g_DHookRocketExplode = DHook_CreateVirtual(gamedata, "CTFBaseRocket::Explode");
	delete gamedata;
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, DEMOPAN))
		return;
		
	if (StrContains(abilityName, BOMB) != -1)
		Bomb_Activate(client, abilityName);
		
	if (StrContains(abilityName, SHIELD) != -1)
		Shield_Activate(client, abilityName);
		
	if (StrContains(abilityName, TRADE) != -1)
		Trade_Activate(client, abilityName);
}

public Action CF_OnSpecialResourceApplied(int client, float current, float &amt)
{
	if (!CF_HasAbility(client, DEMOPAN, PASSIVES))
		return Plugin_Continue;
		
	int iCurrent = RoundFloat(current);
	int iAmt = RoundFloat(amt);
		
	//TODO: Add or remove special resource props as needed.
		
	return Plugin_Continue;
}

int Bomb_Particle[2049] = { -1, ... };

public void Bomb_Activate(int client, char abilityName[255])
{
	
}

public void Shield_Activate(int client, char abilityName[255])
{
	
}

public void Trade_Activate(int client, char abilityName[255])
{
	
}

public void CF_OnGenericProjectileTeamChanged(int entity, TFTeam newTeam)
{
	int oldParticle = EntRefToEntIndex(Bomb_Particle[entity]);
	if (IsValidEntity(oldParticle))
		RemoveEntity(oldParticle);
		
	Bomb_Particle[entity] = EntIndexToEntRef(AttachParticleToEntity(entity, newTeam == TFTeam_Red ? PARTICLE_REFINED_RED : PARTICLE_REFINED_BLUE, ""));
	SetEntityRenderColor(entity, newTeam == TFTeam_Red ? 255 : 120, 120, newTeam == TFTeam_Blue ? 255 : 120, 255);
}

public void OnEntityDestroyed(int entity)
{
	if (entity > 0 && entity < 2049)
	{
		Bomb_Particle[entity] = -1;
	}
}

public void CF_OnCharacterRemoved(int client)
{
	//TODO: Remove all resource props and delete the resource props handle.
}