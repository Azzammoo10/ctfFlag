# ============================================
#  keep_awake_v2.ps1 - Prevents screen sleep
#  using Windows API (no mouse movement)
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
"@

# Tell Windows: keep system + screen awake indefinitely
[SleepUtil]::SetThreadExecutionState(
    [SleepUtil]::ES_CONTINUOUS -bor
    [SleepUtil]::ES_SYSTEM_REQUIRED -bor
    [SleepUtil]::ES_DISPLAY_REQUIRED
) | Out-Null

Write-Host "keep_awake started - screen will NOT sleep"
Write-Host "Stop with: Ctrl+C"

try {
    while ($true) {
        Write-Host "[$([datetime]::Now.ToString('HH:mm:ss'))] Awake..."
        Start-Sleep -Seconds 60
    }
}
finally {
    # Release: allow Windows to sleep again
    [SleepUtil]::SetThreadExecutionState([SleepUtil]::ES_CONTINUOUS) | Out-Null
    Write-Host "keep_awake stopped - sleep restored."
}
