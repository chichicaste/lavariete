# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

################################
# This script takes a range of commits and generates
# a commit log with the git2git-excluded file changes
# filtered out.
#
# It also replaces GitHub issue numbers with GH-XXX so
# as to not confuse Git2Git or Azure DevOps.
# Community contributions are tagged with CC- so they
# can be detected later.

$vesion = '1.0.0'

# Add reference to the Windows.Forms assembly
Add-Type -AssemblyName System.Windows.Forms

<#
# Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Shell32 {
  [DllImport("Shell32.dll")]
  public static extern int SHChangeNotify(int eventId, int flags, IntPtr item1, IntPtr item2);
}
"@
#>

# Define the languages you want to install
$languages = @('en-US', 'es-US', 'es-MX', 'es-SV', 'es-419')

# Get the current list of user languages
$installedLanguages = (Get-WinUserLanguageList).LanguageTag

# Filter the languages that are not yet installed
$languagesToInstall = $languages | Where-Object { $installedLanguages -notcontains $_ }
$totalLanguages = $languagesToInstall.Count
$currentLanguage = 0

# Install the missing languages
foreach ($language in $languagesToInstall) {
  $currentLanguage++
  Write-Progress -Activity "Installing languages" -Status "$language" -PercentComplete (($currentLanguage / $totalLanguages) * 100)
  $languagePack = New-WinUserLanguageList $language
  $languagePack[0].InstallLanguagePack()
}

# Set Spanish (United States) as the default language
$languageList = New-WinUserLanguageList es-US
Set-WinUserLanguageList $languageList -Force
# Set-WinHomeLocation -GeoId 244
Set-Culture es-US

# Apply changes
Start-Process "RUNDLL32.EXE" "USER32.DLL,UpdatePerUserSystemParameters" -NoNewWindow

<#
[Shell32]::SHChangeNotify(0x8000000, 0x1000, [IntPtr]::Zero, [IntPtr]::Zero)
#>

# Show an alert window
[System.Windows.Forms.MessageBox]::Show("Keep in mind that some system elements may not recognize language changes until a full restart", "Warning", 0, [System.Windows.Forms.MessageBoxIcon]::Warning)

# Close the progress bar
Write-Progress -Activity "Installing languages" -Completed
