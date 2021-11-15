#include <sourcemod>

Handle g_hStore = null;         //  store database handle
Handle g_hChat = null;          //  chat colors database handle

char g_cTag[MAXPLAYERS][32];        // store player's tag

enum
{
    TAGPRICE = 100,
    TAGCOLORPRICE = 150,
    NAMECOLORPRICE = 200,
    CHATCOLORPRICE = 300
};

public Plugin myinfo =
{
    name = "store-tag",
    author = "达达",
    description = "allow players to buy chat stuff in store",
    version = "1.1.0",
    url = "https://cialloo.com"
};

public OnPluginStart()
{
    RegConsoleCmd("sm_buytag", Cmd_BuyTag);
}

public OnAllPluginsLoaded()
{
    SQL_TConnect(SQL_StoreConnected, "store");
    SQL_TConnect(SQL_ChatConnected, "custom-chatcolors");
}

public Action Cmd_BuyTag(int client, int args)
{
    if(g_hChat != INVALID_HANDLE && g_hStore != INVALID_HANDLE)         // check if database connected
    {
        int i = GetCmdArgs();

        if(i < 1)
        {
            PrintToChat(client, "请输入您想要的tag");
            return;
        }

        char query[256];
        int steam = GetSteamAccountID(client);
        FormatEx(query, 256, "SELECT credits FROM store_users WHERE auth = %d;", steam);
        SQL_TQuery(g_hStore, SQL_FetchCredits, query, client, DBPrio_Normal);       // check if player have enough credits

        GetCmdArgString(g_cTag[client], 32);
    }
}

public void SQL_FetchCredits(Handle owner, Handle hndl, const char[] error, int client)
{
    if(hndl != INVALID_HANDLE)
    {
        if(SQL_FetchRow(hndl))
        {
            int credits = SQL_FetchInt(hndl, 0);
            if(credits < TAGPRICE)
            {
                PrintToChat(client, "您的比特币只有 %d,购买tag需要 %d 比特币", credits, TAGPRICE);
                return;
            } else {
                int steam = GetSteamAccountID(client);
                char query[256], steamid[64];
                FormatEx(query, 256, "UPDATE store_users SET credits = %d WHERE auth = %d;", (credits - TAGPRICE), steam);
                SQL_TQuery(g_hStore, SQL_DoNothing, query, 0, DBPrio_Normal);

                GetClientAuthId(client, AuthId_Steam2, steamid, 64);
                Format(query, 256, "SELECT identity FROM custom_chatcolors WHERE identity = '%s';", steamid);
                SQL_TQuery(g_hChat, SQL_SetTag, query, client, DBPrio_Normal);
            }
        }
    } else PrintToServer("%s", error);
}

public void SQL_SetTag(Handle owner, Handle hndl, const char[] error, int client)
{
    if(hndl != INVALID_HANDLE)
    {
        if(SQL_FetchRow(hndl))
        {
            char query[256], steamid[64];
            GetClientAuthId(client, AuthId_Steam2, steamid, 64);
            FormatEx(query, 256, "UPDATE custom_chatcolors SET tag = '%s ' WHERE identity = '%s';", g_cTag[client], steamid);       //  update player tag
            PrintToChat(client, "已成功购买tag,系统将在6小时内自动刷新");
            SQL_TQuery(g_hChat, SQL_DoNothing, query, 0, DBPrio_Normal);
        } else {
            char query[256], steamid[64];
            GetClientAuthId(client, AuthId_Steam2, steamid, 64);
            FormatEx(query, 256, "SELECT * FROM `custom_chatcolors` ORDER BY `index` ASC;");        //  insert a new player's tag
            SQL_TQuery(g_hChat, SQL_Insert, query, client, DBPrio_Normal);
        }
    } else PrintToServer("%s", error);
}

public void SQL_Insert(Handle owner, Handle hndl, const char[] error, int client)
{
    int index = 0;
    char steamid[64], query[256];
    GetClientAuthId(client, AuthId_Steam2, steamid, 64);

    while(SQL_FetchRow(hndl))
    {
        index++;
    }

    FormatEx(query, 256, "INSERT INTO `custom_chatcolors` (`index`, `identity`, `flag`, `tag`, `tagcolor`, `namecolor`, `textcolor`) VALUES ('%d', '%s', NULL, '%s ', 'O', NULL, NULL);", index, steamid, g_cTag[client]);
    SQL_TQuery(g_hChat, SQL_DoNothing, query, client, DBPrio_Normal);
    PrintToChat(client, "已成功购买tag,系统将在6小时内自动刷新");
}

public void SQL_StoreConnected(Handle owner, Handle hndl, const char[] error, any data)
{
    if(hndl != INVALID_HANDLE)
    {
        SQL_SetCharset(hndl, "utf8");
        g_hStore = hndl;
    } else PrintToServer("%s", error);
}

public void SQL_ChatConnected(Handle owner, Handle hndl, const char[] error, any data)
{
    if(hndl != INVALID_HANDLE)
    {
        SQL_SetCharset(hndl, "utf8");
        g_hChat = hndl;
    } else PrintToServer("%s", error);
}

public void SQL_DoNothing(Handle owner, Handle hndl, const char[] error, any data)
{

}