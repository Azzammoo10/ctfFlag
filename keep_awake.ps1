# ============================================
#  keep_awake.ps1 - Prevents screen sleep
#  by moving the mouse every 50 seconds
# ============================================

$interval = 50      # seconds between each move

Add-Type @"
using System;
using System.Runtime.InteropServices;

public class Mouse {
    [DllImport("user32.dll")]
    public static extern bool GetCursorPos(out POINT lpPoint);

    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int X, int Y);

    public struct POINT { public int X; public int Y; }
}
"@

Write-Host "keep_awake started (interval: ${interval}s)"
Write-Host "Stop with: Ctrl+C"
Write-Host ""

# Movement patterns: list of (dx, dy) steps
$patterns = @(
    @(  50,   0),   # right
    @(   0,  50),   # down
    @( -50,   0),   # left
    @(   0, -50),   # up
    @(  80,  80),   # diagonal down-right
    @( -80,  80),   # diagonal down-left
    @(  80, -80),   # diagonal up-right
    @( -80, -80)    # diagonal up-left
)

$step = 0

try {
    while ($true) {
        $point = New-Object Mouse+POINT
        [Mouse]::GetCursorPos([ref]$point) | Out-Null

        $origX = $point.X
        $origY = $point.Y

        # Pick next pattern in rotation
        $move = $patterns[$step % $patterns.Length]
        $step++

        $newX = $origX + $move[0]
        $newY = $origY + $move[1]

        # Move to new position
        [Mouse]::SetCursorPos($newX, $newY) | Out-Null
        Start-Sleep -Milliseconds 300

        # Move back to original position
        [Mouse]::SetCursorPos($origX, $origY) | Out-Null

        Write-Host "[$([datetime]::Now.ToString('HH:mm:ss'))] Moved ($($move[0]), $($move[1])) -> back to ($origX, $origY)"
        Start-Sleep -Seconds $interval
    }
}
finally {
    Write-Host ""
    Write-Host "keep_awake stopped."
}
