#include <sourcemod>
#include <influx/core>
#include <store>

int gI_Maptier = 0;
bool gB_TierReady = false;
bool gB_GiveCredits = false;

public Plugin myinfo =
{
    name = "influx_maptier",
    author = "cialloo",
    description = "show map tier to surf player",
    version = "0.2.1",
    url = "www.cialloo.com"
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

public void Influx_OnTimerFinishPost( int client, int runid, int mode, int style, float time, float prev_pb, float prev_best, int flags )
{
    if(!gB_GiveCredits)
        gB_GiveCredits = true;
    else
        return;

    switch(gI_Maptier)
    {
        case 0: return;
        case 1: Store_GiveCredits(client, 5);
        case 2: Store_GiveCredits(client, 10);
        case 3: Store_GiveCredits(client, 25);
        case 4: Store_GiveCredits(client, 40);
        case 5: Store_GiveCredits(client, 80);
        case 6: Store_GiveCredits(client, 160);
        case 7: Store_GiveCredits(client, 320);
        case 8: Store_GiveCredits(client, 1000);
    }
}

public void OnMapEnd()
{
    gB_TierReady = false;
    gB_GiveCredits = false;
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

stock void Store_GiveCredits(int client, int credits)
{
    Store_SetClientCredits(client, Store_GetClientCredits(client) + credits);
}