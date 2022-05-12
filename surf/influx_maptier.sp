#include <sourcemod>
#include <cialloo/core>
#include <influx/core>

int gI_Maptier = 0;
bool gB_TierReady = false;

public Plugin myinfo =
{
    name = "influx_maptier",
    author = PLUGIN_AUTHOR,
    description = "show map tier to surf player",
    version = "0.2.1",
    url = PLUGIN_URL
};

public void OnPluginStart()
{
    RegAdminCmd("sm_settier", Cmd_Settier, ADMFLAG_CHANGEMAP, "set tier to map");
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

public Action Cmd_Settier(int client, int args)
{
    char buffer[8], mapname[128], query[256];
    GetCmdArg(1, buffer, sizeof(buffer));
    
    int tier = StringToInt(buffer);
    
    if(tier < 0 || tier > 8)
    {
        PrintToChat(client, "Invalid tier");
        return Plugin_Handled;
    }

    GetCurrentMap(mapname, sizeof(mapname));
    FormatEx(query, sizeof(query), 
    "UPDATE `inf_maps` \
    SET `maptier` = %d \
    WHERE `inf_maps`.`mapname` = \'%s\';",
    tier, 
    mapname);
    SQL_TQuery(Influx_GetDB(), DB_OnSetMaptier, query, client);

    return Plugin_Handled;
}

public void DB_OnSetMaptier(Handle owner, Handle hndl, const char[] error, int client)
{
    if(hndl == null)
    {
        PrintToChat(client, "Set map tier fail.\nError: %s", error);
    }
    else 
    {
        PrintToChat(client, "Successfully set map tier.");
    }
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