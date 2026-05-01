<#
.SYNOPSIS
    Script to monitor physical hard drive status and report it to a URI

.PARAMETER GoodURI
    Send the good status to there

.PARAMETER BadURI
    Send the bad status to there

.EXAMPLE
    .\Invoke-HDDMonitoring.ps1

.EXAMPLE
    .\Invoke-HDDMonitoring.ps1 -GoodURI 'https://path.to.uri/api?status=good' -BadURI 'https://path.to.uri/api?status=bad'
#>

param(
    [string]$GoodURI = 'https://path.to.uri/api?status=good',
    [string]$BadURI = 'https://path.to.uri/api?status=bad',
    [switch]$Legacy
)

if (-not $Legacy) {
    if (Get-PhysicalDisk | Where-Object HealthStatus -eq 'Healthy') {
        Invoke-WebRequest -Uri $GoodURI
    } else {
        Invoke-WebRequest -Uri $BadURI
    }
} else {
    $NumberOfDisks = 3
    $AllDisksStatus = $false
    ('list disk' | diskpart) | Select-Object -Skip 9 -First $NumberOfDisks | ForEach-Object {
        $DiskInfo = -split $_
        $DiskNumber = $DiskInfo[1]
        $DiskStatus = $DiskInfo[2]

        if ($DiskStatus -ne 'Online') {
            Write-Host "Error for Disk $DiskNumber"
            $AllDisksStatus = $true
        } else {
            Write-Host "No Error for Disk $DiskNumber"
        }
    }
    if ($AllDisksStatus -eq $true) {
        Write-Host 'One Disk is on Error'
        Invoke-Webrequest -Uri $BadURI
    } else {
        Write-Host 'No Disk is on Error'
        Invoke-Webrequest -Uri $GoodURI
    }
}
