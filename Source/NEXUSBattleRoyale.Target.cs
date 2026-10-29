using UnrealBuildTool;
using System.Collections.Generic;

public class NEXUSBattleRoyaleTarget : TargetRules
{
    public NEXUSBattleRoyaleTarget(TargetInfo Target) : base(Target)
    {
        Type = TargetType.Game;
        DefaultBuildSettings = BuildSettingsVersion.V5;
        IncludeOrderVersion = EngineIncludeOrderVersion.Unreal5_6;
        ExtraModuleNames.Add("NEXUSBattleRoyale");
    }
}
