#include <sourcemod>
#include <sdktools>
#include <ripext>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0"

ConVar jf_enablejokes;
ConVar jf_enablefacts;
ConVar jf_automatic_facts;
ConVar jf_automatic_jokes;
ConVar jf_jokes_timer;
ConVar jf_facts_timer;
Handle autojokes;
Handle autofacts;

public Plugin myinfo = 
{
	name = "Random jokes & facts",
	author = "Nathy",
	description = "Get some random jokes and facts by command",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/id/nathyzinhaa"
};

public void OnPluginStart()
{   
    RegConsoleCmd("sm_joke", Command_joke);
    RegConsoleCmd("sm_fact", Command_facts);
    RegConsoleCmd("sm_jokes", Command_joke);
    RegConsoleCmd("sm_facts", Command_facts);
    jf_enablejokes = CreateConVar("sm_enable_jokes", "1");
    jf_enablefacts = CreateConVar("sm_enable_facts", "1");
    jf_automatic_facts = CreateConVar("sm_automatic_facts", "1");
    jf_automatic_jokes = CreateConVar("sm_automatic_jokes", "1");
    jf_jokes_timer = CreateConVar("sm_jokestimer", "30");
    jf_facts_timer = CreateConVar("sm_factstimer", "30");
    AutoExecConfig(true, "JokeAndFacts");
}

public void OnConfigsExecuted()
{
    RestartFactsTimer();
    RestartJokesTimer();
}

void OnFactsReceived(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_OK) {
        return;
    }

    JSONObject facts = view_as<JSONObject>(response.Data);

    char fact[256];
    facts.GetString("fact", fact, sizeof(fact));

    PrintToChatAll("\x01 \x04[Fact] \x01%s", fact);
} 

void OnJokesReceived(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_OK) {
        return;
    }

    JSONObject jokes = view_as<JSONObject>(response.Data);

    char joke[256];
    jokes.GetString("joke", joke, sizeof(joke));

    PrintToChatAll("\x01 \x04[Joke] \x01%s", joke);
}

public Action Command_joke(int client, int args)
{
	if(GetConVarInt(jf_enablejokes) == 1)
	{
    HTTPRequest jokereq = new HTTPRequest("https://api.popcat.xyz/joke");
    
    jokereq.Get(OnJokesReceived);
    }
}

public Action Command_facts(int client, int args)
{
	if(GetConVarInt(jf_enablefacts) == 1)
	{
    HTTPRequest factreq = new HTTPRequest("https://api.popcat.xyz/fact");
    factreq.Get(OnFactsReceived);
    }
}

public Action factstimer(Handle timer)
{
	if(GetConVarInt(jf_automatic_facts) == 1)
	{
	    HTTPRequest factreq = new HTTPRequest("https://api.popcat.xyz/fact");
	    factreq.Get(OnFactsReceived);
	}
}

public Action jokestimer(Handle timer)
{
	if(GetConVarInt(jf_automatic_jokes) == 1)
    {
	    HTTPRequest jokereq = new HTTPRequest("https://api.popcat.xyz/joke");
	    jokereq.Get(OnJokesReceived);
    }
}

void RestartFactsTimer()
{
    delete autofacts;
    autofacts = CreateTimer(float(jf_facts_timer.IntValue), factstimer, _, TIMER_REPEAT);
}

void RestartJokesTimer()
{
    delete autojokes;
    autojokes = CreateTimer(float(jf_jokes_timer.IntValue), jokestimer, _, TIMER_REPEAT);
}
