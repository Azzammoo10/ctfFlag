# ============================================
#  keep_awake_v3.ps1 - Prevents screen sleep
#  + keeps Teams/Slack status Green
# ============================================

Add-Type @"
using System;
using System.Runtime.InteropServices;

public class SleepUtil {
    [DllImport("kernel32.dll")]
    public static extern uint SetThreadExecutionState(uint esFlags);
    public const uint ES_CONTINUOUS       = 0x80000000;
    public const uint ES_SYSTEM_REQUIRED  = 0x00000001;
    public const uint ES_DISPLAY_REQUIRED = 0x00000002;
}

public class KeySim {
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, int dwExtraInfo);
    public const uint KEYEVENTF_KEYUP = 0x0002;
    public const byte VK_F15 = 0x7E;  // F15 - unused key, invisible to apps
}
"@

# Prevent Windows sleep + screen off
[SleepUtil]::SetThreadExecutionState(
    [SleepUtil]::ES_CONTINUOUS -bor
    [SleepUtil]::ES_SYSTEM_REQUIRED -bor
    [SleepUtil]::ES_DISPLAY_REQUIRED
) | Out-Null

Write-Host "keep_awake v3 started"
Write-Host "  - Screen will NOT sleep"
Write-Host "  - Teams/Slack status stays Green"
Write-Host "Stop with: Ctrl+C"
Write-Host ""

try {
    while ($true) {
        # Press + release F15 (invisible key, no effect on any app)
        [KeySim]::keybd_event([KeySim]::VK_F15, 0, 0, 0)
        Start-Sleep -Milliseconds 50
        [KeySim]::keybd_event([KeySim]::VK_F15, 0, [KeySim]::KEYEVENTF_KEYUP, 0)

        Write-Host "[$([datetime]::Now.ToString('HH:mm:ss'))] Awake + Active"
        Start-Sleep -Seconds 50
    }
}
finally {
    [SleepUtil]::SetThreadExecutionState([SleepUtil]::ES_CONTINUOUS) | Out-Null
    Write-Host "keep_awake stopped - sleep restored."
}
