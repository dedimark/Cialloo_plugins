#include <sourcemod>
#include <Cialloo/Cialloo_core>
#include <influx/core>

int gI_Maptier = 0;
bool gB_TierReady = false;

public Plugin myinfo =
{
    name = "influx_maptier",
    author = PLUGIN_AUTHOR,
    description = "show map tier to surf player",
    version = "0.1.0",
    url = PLUGIN_URL
};

public void OnPluginStart()
{
    HookEvent("player_spawn", Event_PlayerSpawn);
}

public void OnMapStart()
{
    char map[128], query[256];
    GetCurrentMap(map, sizeof(map));
    FormatEx(query, sizeof(query), 
    "SELECT `maptier` \
    FROM `inf_maps` \
    WHERE `mapname` = \'%s\';", map);

    SQL_TQuery(Influx_GetDB(), DB_OnGetMapTier, query, 0, DBPrio_Normal);
}

public void OnMapEnd()
{
    gB_TierReady = false;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    if(!gB_TierReady)
        return;

    SetHudTextParams(-1.0, 0.1, 6.5, 255, 255, 0, 200);
    ShowHudText(GetClientOfUserId(event.GetInt("userid")), -1, "当前地图难度: T%d", gI_Maptier);
}

public void DB_OnGetMapTier(Handle owner, Handle hndl, const char[] error, any data)
{
    SQL_FetchRow(hndl);
    gI_Maptier = SQL_FetchInt(hndl, 0);
    gB_TierReady = true;

    CreateTimer(3.0, Timer_SetHostname);
}

public Action Timer_SetHostname(Handle timer)
{
    if(!gB_TierReady)
        return;

    char hostname[128], buffer[256];
    ConVar cv_hostname = FindConVar("hostname");

    GetConVarString(cv_hostname, hostname, sizeof(hostname));
    FormatEx(buffer, sizeof(hostname), "%s Current: *T%d*", hostname, gI_Maptier);
    SetConVarString(cv_hostname, buffer);
}