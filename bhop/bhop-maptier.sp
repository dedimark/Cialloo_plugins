#include <Cialloo/Cialloo_core>
#include <sourcemod>
#include <shavit>

#define VERSION "0.1.0"

bool g_bLoadName = false;
char g_sHostname[128];
Handle g_hHostname = null;

public Plugin myinfo =
{
    name = "bhop-maptier",
    author = PLUGIN_AUTHOR,
    description = "Show map tier on hostname",
    version = VERSION,
    url = PLUGIN_URL
};

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