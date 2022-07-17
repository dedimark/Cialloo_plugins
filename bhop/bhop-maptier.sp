#include <sourcemod>
#include <shavit>
#include <store>

#define VERSION "2.1.1"

bool g_bLoadName = false;
bool g_bGiveCredits = false;
char g_sHostname[128];
Handle g_hHostname = null;

public Plugin myinfo =
{
    name = "bhop-maptier",
    author = "cialloo",
    description = "Show map tier on hostname",
    version = VERSION,
    url = "www.cialloo.com"
};

public void OnMapEnd()
{
    g_bGiveCredits = false;
}

public void OnConfigsExecuted()
{
    if(!g_bLoadName)
    {
        g_hHostname = FindConVar("hostname");
        GetConVarString(g_hHostname, g_sHostname, sizeof(g_sHostname));

        g_bLoadName = true;
    }

    char mapname[128], hostname[256];
    GetCurrentMap(mapname, sizeof(mapname));
    int tier = Shavit_GetMapTier(mapname);

    FormatEx(hostname, sizeof(hostname), "%s Current: *T%d*", g_sHostname, tier);
    SetConVarString(g_hHostname, hostname);
}

public void Shavit_OnFinish(int client, int style, float time, int jumps, int strafes, float sync, int track, float oldtime, float perfs, float avgvel, float maxvel, int timestamp)
{
    if(g_bGiveCredits)
        return;
    else
        g_bGiveCredits = true;

    char mapname[MAX_NAME_LENGTH];
    GetCurrentMap(mapname, sizeof(mapname));
    switch(Shavit_GetMapTier(mapname))
    {
        case 0: return;
        case 1: Store_GiveCredits(client, 2);
        case 2: Store_GiveCredits(client, 5);
        case 3: Store_GiveCredits(client, 15);
        case 4: Store_GiveCredits(client, 25);
        case 5: Store_GiveCredits(client, 50);
        case 6: Store_GiveCredits(client, 80);
        case 7: Store_GiveCredits(client, 120);
        default: Store_GiveCredits(client, 300); // 8 9 10
    }
}

stock void Store_GiveCredits(int client, int credits)
{
    Store_SetClientCredits(client, Store_GetClientCredits(client) + credits);
}