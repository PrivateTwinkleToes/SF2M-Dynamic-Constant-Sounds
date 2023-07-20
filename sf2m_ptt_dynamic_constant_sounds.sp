#include <sf2>
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2>
#include <tf2_stocks>
#include <cbasenpc>

#pragma semicolon 1

static bool g_slenderBossDynamicConstantSounds[MAX_BOSSES];

static bool g_slenderBossDynamicConstantSoundHook[MAX_BOSSES];

static bool g_slenderBossIsPlayingIdleConstantSound[MAX_BOSSES] = { false , ... };
static bool g_slenderBossIsPlayingAlertConstantSound[MAX_BOSSES] = { false , ... };
static bool g_slenderBossIsPlayingChaseConstantSound[MAX_BOSSES] = { false , ... };

static char g_slenderBossIdleConstantSound[MAX_BOSSES][PLATFORM_MAX_PATH];
static char g_slenderBossAlertConstantSound[MAX_BOSSES][PLATFORM_MAX_PATH];
static char g_slenderBossChaseConstantSound[MAX_BOSSES][PLATFORM_MAX_PATH];

static float g_slenderBossIdleConstantSoundVolume[MAX_BOSSES];
static float g_slenderBossAlertConstantSoundVolume[MAX_BOSSES];
static float g_slenderBossChaseConstantSoundVolume[MAX_BOSSES];

static int g_slenderBossIdleConstantSoundLevel[MAX_BOSSES];
static int g_slenderBossAlertConstantSoundLevel[MAX_BOSSES];
static int g_slenderBossChaseConstantSoundLevel[MAX_BOSSES];

static int g_slenderBossIdleConstantSoundPitch[MAX_BOSSES];
static int g_slenderBossAlertConstantSoundPitch[MAX_BOSSES];
static int g_slenderBossChaseConstantSoundPitch[MAX_BOSSES];

public Plugin myinfo =
{
	name		=	"Slender Fortress 2: Modifed - Dynamic Constant Sounds",
	author		=	"Private Twinkle Toes",
	description	=	"Allows bosses to emit unique constant sounds while idle, alert, or chasing.",
	version		=	"Custom",
	url 		=	"N/A"
};

public void SF2_OnBossProfileLoaded(const char[] profile, KeyValues kv)
{
	if(!SF2_IsBossProfileValid(profile))
		return;
	
	char buffer[PLATFORM_MAX_PATH];
	
	SF2_GetBossProfileString(profile, "idle_constant_sound", buffer, sizeof(buffer), "");
	TryPrecacheBossProfileSoundPath(buffer, _, true);
	SF2_GetBossProfileString(profile, "alert_constant_sound", buffer, sizeof(buffer), "");
	TryPrecacheBossProfileSoundPath(buffer, _, true);
	SF2_GetBossProfileString(profile, "chase_constant_sound", buffer, sizeof(buffer), "");
	TryPrecacheBossProfileSoundPath(buffer, _, true);
}

public void SF2_OnBossAdded(int bossIndex)
{
	char profile[SF2_MAX_PROFILE_NAME_LENGTH];

	SF2_GetBossName(bossIndex, profile, sizeof(profile));

	g_slenderBossDynamicConstantSounds[bossIndex] = SF2_GetBossProfileNum(profile, "dynamic_constant_sounds", 0) != 0;
	
	g_slenderBossDynamicConstantSoundHook[bossIndex] = SF2_GetBossProfileNum(profile, "dynamic_constant_sound_hook", 0) != 0;
	
	SF2_GetBossProfileString(profile, "idle_constant_sound", g_slenderBossIdleConstantSound[bossIndex], sizeof(g_slenderBossIdleConstantSound[]), "");
	g_slenderBossIdleConstantSoundVolume[bossIndex] = SF2_GetBossProfileFloat(profile, "idle_constant_sound_volume", 1.0);
	g_slenderBossIdleConstantSoundLevel[bossIndex] = SF2_GetBossProfileNum(profile, "idle_constant_sound_level", SNDLEVEL_SCREAMING);
	g_slenderBossIdleConstantSoundPitch[bossIndex] = SF2_GetBossProfileNum(profile, "idle_constant_sound_pitch", 100);
	
	SF2_GetBossProfileString(profile, "alert_constant_sound", g_slenderBossAlertConstantSound[bossIndex], sizeof(g_slenderBossAlertConstantSound[]), "");
	g_slenderBossAlertConstantSoundVolume[bossIndex] = SF2_GetBossProfileFloat(profile, "alert_constant_sound_volume", 1.0);
	g_slenderBossAlertConstantSoundLevel[bossIndex] = SF2_GetBossProfileNum(profile, "alert_constant_sound_level", SNDLEVEL_SCREAMING);
	g_slenderBossAlertConstantSoundPitch[bossIndex] = SF2_GetBossProfileNum(profile, "alert_constant_sound_pitch", 100);

	SF2_GetBossProfileString(profile, "chase_constant_sound", g_slenderBossChaseConstantSound[bossIndex], sizeof(g_slenderBossChaseConstantSound[]), "");
	g_slenderBossChaseConstantSoundVolume[bossIndex] = SF2_GetBossProfileFloat(profile, "chase_constant_sound_volume", 1.0);
	g_slenderBossChaseConstantSoundLevel[bossIndex] = SF2_GetBossProfileNum(profile, "chase_constant_sound_level", SNDLEVEL_SCREAMING);
	g_slenderBossChaseConstantSoundPitch[bossIndex] = SF2_GetBossProfileNum(profile, "chase_constant_sound_pitch", 100);
}

public void SF2_OnBossChangeState(int bossIndex, int oldState, int newState)
{
	if (SF2_BossIndexToBossID(bossIndex) == -1)
		return;
		
	if (SF2_BossIndexToEntIndex(bossIndex) == -1)
		return;
		
	if (g_slenderBossDynamicConstantSounds[bossIndex])
	{
		SF2_PlayDynamicConstantSounds(bossIndex, newState);
	}
}

public void SF2_OnBossSpawn(int bossIndex)
{
	if (SF2_BossIndexToBossID(bossIndex) == -1)
		return;
		
	if (SF2_BossIndexToEntIndex(bossIndex) == -1)
		return;
		
	if (g_slenderBossDynamicConstantSounds[bossIndex])
	{
		if(g_slenderBossIdleConstantSound[bossIndex][0] != '\0')
		{
			if(!g_slenderBossIsPlayingIdleConstantSound[bossIndex])
			{
				g_slenderBossIsPlayingIdleConstantSound[bossIndex] = true;
				EmitSoundToAll(g_slenderBossIdleConstantSound[bossIndex], SF2_BossIndexToEntIndexEx(bossIndex), SNDCHAN_STATIC, g_slenderBossIdleConstantSoundLevel[bossIndex], _, g_slenderBossIdleConstantSoundVolume[bossIndex], g_slenderBossIdleConstantSoundPitch[bossIndex]);
			}
		}
	}
}

public void SF2_OnBossDespawn(int bossIndex)
{
	if (SF2_BossIndexToBossID(bossIndex) == -1)
		return;

	if (SF2_BossIndexToEntIndex(bossIndex) == -1)
		return;

	SF2_StopAllDynamicConstantSounds(bossIndex);
}

public void SF2_StopAllDynamicConstantSounds(int bossIndex)
{
	if (SF2_BossIndexToBossID(bossIndex) == -1)
		return;

	if (SF2_BossIndexToEntIndex(bossIndex) == -1)
		return;

	if (g_slenderBossDynamicConstantSounds[bossIndex])
	{
		if(g_slenderBossIsPlayingIdleConstantSound[bossIndex])
		{
			g_slenderBossIsPlayingIdleConstantSound[bossIndex] = false;
			StopSound(SF2_BossIndexToEntIndex(bossIndex), SNDCHAN_STATIC, g_slenderBossIdleConstantSound[bossIndex]);
		}
	
		if(g_slenderBossIsPlayingAlertConstantSound[bossIndex])
		{
			g_slenderBossIsPlayingAlertConstantSound[bossIndex] = false;
			StopSound(SF2_BossIndexToEntIndex(bossIndex), SNDCHAN_STATIC, g_slenderBossAlertConstantSound[bossIndex]);
		}

		if(g_slenderBossIsPlayingChaseConstantSound[bossIndex])
		{
			g_slenderBossIsPlayingChaseConstantSound[bossIndex] = false;
			StopSound(SF2_BossIndexToEntIndex(bossIndex), SNDCHAN_STATIC, g_slenderBossChaseConstantSound[bossIndex]);
		}
	}
}

public void SF2_PlayDynamicConstantSounds(int bossIndex, int newState)
{
	if (SF2_BossIndexToBossID(bossIndex) == -1)
		return;

	if (SF2_BossIndexToEntIndex(bossIndex) == -1)
		return;

	switch (newState)
	{
		case STATE_IDLE:
		{
			if(g_slenderBossIsPlayingAlertConstantSound[bossIndex])
			{
				g_slenderBossIsPlayingAlertConstantSound[bossIndex] = false;
				StopSound(SF2_BossIndexToEntIndexEx(bossIndex), SNDCHAN_STATIC, g_slenderBossAlertConstantSound[bossIndex]);
			}
				
			if(g_slenderBossIsPlayingChaseConstantSound[bossIndex])
			{
				g_slenderBossIsPlayingChaseConstantSound[bossIndex] = false;
				StopSound(SF2_BossIndexToEntIndexEx(bossIndex), SNDCHAN_STATIC, g_slenderBossChaseConstantSound[bossIndex]);
			}

			if(g_slenderBossIdleConstantSound[bossIndex][0] != '\0')
			{
				if(!g_slenderBossIsPlayingIdleConstantSound[bossIndex])
				{
					g_slenderBossIsPlayingIdleConstantSound[bossIndex] = true;
					EmitSoundToAll(g_slenderBossIdleConstantSound[bossIndex], SF2_BossIndexToEntIndexEx(bossIndex), SNDCHAN_STATIC, g_slenderBossIdleConstantSoundLevel[bossIndex], _, g_slenderBossIdleConstantSoundVolume[bossIndex], g_slenderBossIdleConstantSoundPitch[bossIndex]);
				}
			}
		}
		case STATE_ALERT:
		{
			if(g_slenderBossIsPlayingChaseConstantSound[bossIndex])
			{
				g_slenderBossIsPlayingChaseConstantSound[bossIndex] = false;
				StopSound(SF2_BossIndexToEntIndexEx(bossIndex), SNDCHAN_STATIC, g_slenderBossChaseConstantSound[bossIndex]);
			}

			if(g_slenderBossAlertConstantSound[bossIndex][0] != '\0')
			{
				if(g_slenderBossIsPlayingIdleConstantSound[bossIndex])
				{
					g_slenderBossIsPlayingIdleConstantSound[bossIndex] = false;
					StopSound(SF2_BossIndexToEntIndexEx(bossIndex), SNDCHAN_STATIC, g_slenderBossIdleConstantSound[bossIndex]);
				}

				if(!g_slenderBossIsPlayingAlertConstantSound[bossIndex])
				{
					g_slenderBossIsPlayingAlertConstantSound[bossIndex] = true;
					EmitSoundToAll(g_slenderBossAlertConstantSound[bossIndex], SF2_BossIndexToEntIndexEx(bossIndex), SNDCHAN_STATIC, g_slenderBossAlertConstantSoundLevel[bossIndex], _, g_slenderBossAlertConstantSoundVolume[bossIndex], g_slenderBossAlertConstantSoundPitch[bossIndex]);
				}
			}
			else if(g_slenderBossIdleConstantSound[bossIndex][0] != '\0')
			{		
				if(!g_slenderBossIsPlayingIdleConstantSound[bossIndex])
					{
					g_slenderBossIsPlayingIdleConstantSound[bossIndex] = true;
					EmitSoundToAll(g_slenderBossIdleConstantSound[bossIndex], SF2_BossIndexToEntIndexEx(bossIndex), SNDCHAN_STATIC, g_slenderBossIdleConstantSoundLevel[bossIndex], _, g_slenderBossIdleConstantSoundVolume[bossIndex], g_slenderBossIdleConstantSoundPitch[bossIndex]);
				}
			}
		}
		case STATE_CHASE:
		{
			if(g_slenderBossChaseConstantSound[bossIndex][0] != '\0')
			{
				if(g_slenderBossIsPlayingIdleConstantSound[bossIndex])
				{
					g_slenderBossIsPlayingIdleConstantSound[bossIndex] = false;
					StopSound(SF2_BossIndexToEntIndexEx(bossIndex), SNDCHAN_STATIC, g_slenderBossIdleConstantSound[bossIndex]);
				}

				if(g_slenderBossIsPlayingAlertConstantSound[bossIndex])
				{
					g_slenderBossIsPlayingAlertConstantSound[bossIndex] = false;
					StopSound(SF2_BossIndexToEntIndexEx(bossIndex), SNDCHAN_STATIC, g_slenderBossAlertConstantSound[bossIndex]);
				}

				if(!g_slenderBossIsPlayingChaseConstantSound[bossIndex])
				{
					g_slenderBossIsPlayingChaseConstantSound[bossIndex] = true;
					EmitSoundToAll(g_slenderBossChaseConstantSound[bossIndex], SF2_BossIndexToEntIndexEx(bossIndex), SNDCHAN_STATIC, g_slenderBossChaseConstantSoundLevel[bossIndex], _, g_slenderBossChaseConstantSoundVolume[bossIndex], g_slenderBossChaseConstantSoundPitch[bossIndex]);
				}
			}
			else if(g_slenderBossAlertConstantSound[bossIndex][0] != '\0')
			{
				if(!g_slenderBossIsPlayingAlertConstantSound[bossIndex])
				{
					g_slenderBossIsPlayingAlertConstantSound[bossIndex] = true;
					EmitSoundToAll(g_slenderBossAlertConstantSound[bossIndex], SF2_BossIndexToEntIndexEx(bossIndex), SNDCHAN_STATIC, g_slenderBossAlertConstantSoundLevel[bossIndex], _, g_slenderBossAlertConstantSoundVolume[bossIndex], g_slenderBossAlertConstantSoundPitch[bossIndex]);
				}
			}
			else if(g_slenderBossIdleConstantSound[bossIndex][0] != '\0')
			{
				if(!g_slenderBossIsPlayingIdleConstantSound[bossIndex])
				{
					g_slenderBossIsPlayingIdleConstantSound[bossIndex] = true;
					EmitSoundToAll(g_slenderBossIdleConstantSound[bossIndex], SF2_BossIndexToEntIndexEx(bossIndex), SNDCHAN_STATIC, g_slenderBossIdleConstantSoundLevel[bossIndex], _, g_slenderBossIdleConstantSoundVolume[bossIndex], g_slenderBossIdleConstantSoundPitch[bossIndex]);
				}
			}
		}
		case STATE_ATTACK:
		{
			int flags = SF2_GetBossFlags(bossIndex);

			if(g_slenderBossDynamicConstantSoundHook[bossIndex] || (flags & SFF_FAKE))
			{
				SF2_StopAllDynamicConstantSounds(bossIndex);
			}
		}
		case STATE_STUN:
		{
			int flags = SF2_GetBossFlags(bossIndex);

			if(g_slenderBossDynamicConstantSoundHook[bossIndex] || (flags & SFF_FAKE))
			{
				SF2_StopAllDynamicConstantSounds(bossIndex);
			}
		}
	}
}