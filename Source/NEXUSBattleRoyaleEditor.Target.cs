using UnrealBuildTool;
using System.Collections.Generic;

public class NEXUSBattleRoyaleEditorTarget : TargetRules
{
    public NEXUSBattleRoyaleEditorTarget(TargetInfo Target) : base(Target)
    {
        Type = TargetType.Editor;
        DefaultBuildSettings = BuildSettingsVersion.V5;
        IncludeOrderVersion = EngineIncludeOrderVersion.Unreal5_6;
        ExtraModuleNames.Add("NEXUSBattleRoyale");
    }
}
