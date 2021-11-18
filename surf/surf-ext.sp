#include <sourcemod>

#define EXTENDTIME 1200
#define EXTCHANCE 2

int gI_PlayerExtChance[MAXPLAYERS + 1];

bool gB_PlayerReturn[MAXPLAYERS + 1];

char gC_LogPath[PLATFORM_MAX_PATH];

public OnPluginStart()
{
    RegConsoleCmd("sm_ext", Cmd_Ext);

    BuildPath(Path_SM, gC_LogPath, sizeof(gC_LogPath), "logs/surf-ext-log.txt");
}

public OnMapStart()
{
    for(int i = 0; i < MAXPLAYERS + 1; i++)
    {
        gB_PlayerReturn[i] = false;
    }
}

public OnClientPutInServer(client)
{
    if(!gB_PlayerReturn[client])
    {
        gB_PlayerReturn[client] = true;
        gI_PlayerExtChance[client] = EXTCHANCE;
    }
}

public Action Cmd_Ext(int client, int args)
{
    if(gI_PlayerExtChance[client])
    {
        gI_PlayerExtChance[client]--;
        ExtendMapTimeLimit(EXTENDTIME);

        char steamid[64];
        GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
        LogToFile(gC_LogPath, "%N (steamid: %s) want to extend map", client, steamid);
    }
    else
    {
        ReplyToCommand(client, "您的延长次数已用完");
    }
}