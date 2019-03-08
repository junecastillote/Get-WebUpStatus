<#	
	.NOTES
	===========================================================================
	 Created on:   	8-Aug-2015
	 Created by:   	June Castillote
					june.castillote@gmail.com
	 Filename:     	Get-WebUpStatus.ps1
	 Version:		1.2 (9-Mar-2019)
	===========================================================================

	.LINK
		https://www.lazyexchangeadmin.com/2018/08/checking-website-up-status-using.html
		https://github.com/junecastillote/Get-WebUpStatus
		
	.SYNOPSIS
		Use Get-WebUpStatus.ps1 to programmatically check the availability status of Sharepoint Sites or any WebSites.

	.DESCRIPTION
		Script to send web requests to listed Sharepoint Sites or any website and report the returned status.

	.PARAMETER configFile
		Specify the configuration xml file to use for the script.
	
	.EXAMPLE
		.\Get-WebUpStatus.ps1 -configFile c:\config.xml

		This example uses the configuration file c:\config.xml
#>

#region Parameters

#[CmdletBinding()]
param (
	[Parameter(Mandatory = $true)]
	[string]$configFile
)
#endregion

Function Stop-TxnLogging
{
	$txnLog=""
	Do {
		try {
			Stop-Transcript | Out-Null
		} 
		catch [System.InvalidOperationException]{
			$txnLog="stopped"
		}
    } While ($txnLog -ne "stopped")
    #Write-host (Get-Date) ": Transcript Logging Stopped"
}

Function Start-TxnLogging {
    param (
    [Parameter(Mandatory=$true)]
    [string]$logPath
    )
	Stop-TxnLogging
    Start-Transcript $logPath
}

#region variables

$scriptVersion = "1.2"

[xml]$config = get-content $configFile
$enableDebug = $config.Parameters.enableDebug
$alertsOnly = $config.Parameters.alertsOnly
$sendEmail = $config.Parameters.sendEmail
$mailTO = ($config.Parameters.mailTO).Split(",")
$mailFrom = $config.Parameters.mailFrom
$mailServerName = $config.Parameters.mailServerName
$mailServerPort = $config.Parameters.mailServerPort
$sitesListFile = $config.Parameters.sitesListFile
$sitesList = Get-Content $sitesListFile

$today = '{0:dd-MMM-yyyy hh:mm tt}' -f (Get-Date)
$script_root = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$reportfile = "$script_root\site_status_report.html"
$cssString = Get-Content "$script_root\style.txt"
$errorCaptured = $false

#endregion

#Start of Process
if ($enableDebug) {Start-TxnLogging -logPath "$script_root\debug.txt"}

Write-Host ""
Write-Host "------START------"
Write-Host ""
Write-Host (Get-Date) -ForegroundColor Yellow
Write-Host ""
Write-Host 'Checking Sites Up Status' -ForegroundColor Yellow
Write-Host ""
Write-Host "===================="

#Read List of Sites and import to variable
#$sitesList = Get-Content "$script_root\sites_list.txt"

#Create an empty multi line string to hold the final output/result of checking
$results = @()

#Loop through each of the sites from the list
foreach ($site in $sitesList)
{
	Write-Host "$site" -ForegroundColor Yellow -NoNewline
	$temp = "" | Select-Object Site, StatusDescription, StatusCode
	Try
	{
		#if all sites are OK
		$site_status = Invoke-WebRequest -Uri $site -UseDefaultCredentials -TimeoutSec 10
		$temp.Site = $site
		$temp.StatusDescription = $site_status.StatusDescription
		$temp.StatusCode = ""
		Write-Host ": ---> $($temp.StatusDescription)" -ForegroundColor Green
	}
	Catch
	{
		#if some sites are NOT OK
		$temp.Site = $site
		$temp.StatusDescription = "NOT OK"
		$temp.StatusCode = $_.Exception.Message.Replace("`n", "<br>")
		$errorCaptured = $true
		#Write-Host ": ---> $($temp.StatusDescription)" -ForegroundColor Red
		Write-Host ": ---> $($temp.StatusCode)" -ForegroundColor Red
	}
	Finally
	{
		$results += $temp
	}
}
$results = $results | Sort-Object Site,StatusDescription
Write-Host "===================="
Write-Host ""

#Begin composing the mail body
$html = '<html><head><title>SP Site Check - ' + $today + '</title><meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />'
$html += $cssString
$html += "</head><body>"
$html += '<table id="HeadingInfo">'
$html += '<tr><th>WebSite Up Status Report</th></tr>'
$html += '<tr><th>' + ("{0:MMM-dd-yyyy}" -f $today) + '</th></tr>'
$html += '</table>'
$html += '<table id="data">'
$html += '<tr><th>Site URL</th><th>Site Status</th><th>Message</th></tr>'

foreach ($result in $results)
{
	if ($result.StatusDescription -ne 'OK')
	{
		$sitestring = $result.Site.Replace(" ", "%20")
		$html += '<tr><td>' + $sitestring + '</td><td class = "bad">' + $result.StatusDescription + '</td><td>' + $result.StatusCode + '</td></tr>'
	}
	elseif ($result.StatusDescription -eq 'OK')
	{
		$sitestring = $result.Site.Replace(" ", "%20")
		$html += '<tr><td>' + $sitestring + '</td><td class = "good">' + $result.StatusDescription + '</td><td>' + $result.StatusCode + '</td></tr>'
	}
}
$html += "</table>"

$html += '<p><table id="section">'
$html += '<tr><th>----END of REPORT----</th></tr></table></p>'
$html += '<p><font size="2" face="Tahoma"><u>Report Paremeters</u><br />'
$html += '<b>[REPORT DETAILS]</b><br />'
$html += 'Generated from Server: ' + (Get-Content env:computername) + '<br />'
$html += 'Script File: ' + $MyInvocation.MyCommand.Definition + '<br />'
$html += 'Config File: ' + $configFile + '<br />'
$html += 'Sites List File: ' + $sitesListFile + '<br />'
$html += 'Recipients: ' + ($mailTO -join ",") + '<br /><br />'
$html += '</p><p>'
$html += '<a href="https://www.lazyexchangeadmin.com/2018/08/checking-website-up-status-using.html/">Get-WebUpStatus.ps1 v.'+$scriptVersion+'</a></p>'
$html += "</table></html>"
$mailSubject = "Web Up Status Report - $today"

#Check if -SendEmail (send report via email) switch is specified
if ($SendEmail)
{
	#Check if -AlertsOnly (send report only for Alerts) switch is specified
	if ($AlertsOnly)
	{
		#Check if there is an Alert captured (NOT OK site)
		if ($errorCaptured -eq $true)
		{
			Write-Host "Sending report to email" -ForegroundColor Cyan
			Send-MailMessage -From $mailFrom -To $mailTO -Subject "ALERT!!! $mailSubject" -Body $html -SmtpServer $mailServerName -BodyAsHtml -Priority 'High' -Port $mailServerPort
		}
	}
	else
	{
		#If -AlertsOnly is not specified, then send the report via email regardless if no sites are down
		Write-Host "Sending report to email" -ForegroundColor Cyan
		Send-MailMessage -From $mailFrom -To $mailTO -Subject "Report - $mailSubject" -Body $html -SmtpServer $mailServerName -BodyAsHtml -Port $mailServerPort
	}
}
else
{
	#If -SendEmail switch is not specified, the report will be saved to file only and will not be send to email
	Write-Host "Not sending report to email because it is disabled" -ForegroundColor Cyan
}

#Save the Report to html file
$html | Out-File $reportfile
Write-Host "Report is saved in $reportfile" -ForegroundColor Cyan
Write-Host ""
Write-Host (Get-Date) -ForegroundColor Yellow
Write-Host ""
Write-Host "------END------"
Write-Host ""
Stop-TxnLogging