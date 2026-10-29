#include "NEXUSGameModeBase.h"
#include "NEXUSPreLobbyCharacter.h"

ANEXUSGameModeBase::ANEXUSGameModeBase()
{
    DefaultPawnClass = ANEXUSPreLobbyCharacter::StaticClass();
}
