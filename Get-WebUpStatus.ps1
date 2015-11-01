<#	
	.NOTES
	===========================================================================
	 Created on:   	8-Aug-2015 9:10 AM
	 Created by:   	Tito D. Castillote Jr.
					june.castillote@gmail.com
	 Filename:     	Get-WebUpStatus.ps1
	===========================================================================

	.SYNOPSIS
		Use Get-WebUpStatus.ps1 to programmatically check the availability status of Sharepoint Sites or any WebSites.

	.DESCRIPTION
		Script to send web requests to listed Sharepoint Sites or any website and report the returned status.

	.PARAMETER SendEmail
		Switch to instruct the script to send the report to specified recipients.
		If not used, script will only check status and save report to file.

	.PARAMETER AlertsOnly
		If specified, the script will only trigger email delivery of report when a "NOT OK" site status is captured.
		Otherwise, a report will be sent even if there are no "NOT OK" sites status.
	
	.EXAMPLE
		.\Get-WebUpStatus.ps1 -SendEmail

		This example will send an email report to specific recipients regardless of site status

	.EXAMPLE
		.\Get-WebUpStatus.ps1 -AlertsOnly -SendEmail

		This example sends the report only if there are captured "NOT OK" sites status
#>

#region Parameters
[CmdletBinding()]
param (
	[Parameter(Mandatory = $false)]
	[switch]$SendEmail,
	[Parameter(Mandatory = $false)]
	[switch]$AlertsOnly
)
#endregion


#region variables

$cssString = @"
<style type="text/css">
table.titletable {font-size:18px;font-family:Verdana;color:#333333;width:100%;}
table.tftable {font-size:12px;font-family:Verdana;color:#333333;width:100%;border-width: 1px;border-color: #729ea5;border-collapse: collapse;}
table.tftable th {font-size:12px;font-family:Verdana;background-color:#acc8cc;border-width: 1px;padding: 8px;border-style: solid;border-color: #729ea5;text-align:middle;}
table.tftable td {font-size:12px;font-family:Verdana;border-width: 1px;padding: 8px;border-style: solid;border-color: #729ea5;vertical-align: top}
table.tftable td.bad {width:1%;background-color:#FF9900;font-weight:bold;font-size:12px;font-family:Verdana;border-width: 1px;padding: 8px;border-style: solid;border-color: #729ea5;vertical-align: top}
table.tftable td.good {width:1%;background-color:#00FF00;font-size:12px;font-family:Verdana;border-width: 1px;padding: 8px;border-style: solid;border-color: #729ea5;vertical-align: top}
</style>
"@

$today = '{0:dd-MMM-yyyy hh:mm tt}' -f (Get-Date)
$script_root = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$reportfile = $script_root + "\site_status_report.html"

$errorCaptured = $false

#endregion

#Start of Process
Write-Host ""
Write-Host "------START------"
Write-Host ""
Write-Host (Get-Date) -ForegroundColor Yellow
Write-Host ""
Write-Host 'Checking Sites Up Status' -ForegroundColor Yellow
Write-Host ""
Write-Host "===================="

#Read List of Sites and import to variable
$sitesList = gc "$script_root\sites_list.txt"

#Create an empty multi line string to hold the final output/result of checking
$results = @()

#Loop through each of the sites from the list
foreach ($site in $sitesList)
{
	Write-Host "$site" -ForegroundColor Yellow -NoNewline
	$temp = "" | Select Site, StatusDescription, StatusCode
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
Write-Host "===================="
Write-Host ""

#Begin composing the mail body
$mail_body = '<html><head><title>SP Site Check - ' + $today + '</title><meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />'
$mail_body += $cssString
$mail_body += '<table class="tftable" border="1">'
$mail_body += '<tr><th></th><th>Site URL</th><th>Site Status</th><th>Message</th></tr>'

foreach ($result in $results)
{
	if ($result.StatusDescription -ne 'OK')
	{
		$mail_body += '<tr><td class = "bad"></td><td>' + $result.Site + '</td><td>' + $result.StatusDescription + '</td><td>' + $result.StatusCode + '</td></tr>'
	}
	elseif ($result.StatusDescription -eq 'OK')
	{
		$mail_body += '<tr><td class = "good"></td><td>' + $result.Site + '</td><td>' + $result.StatusDescription + '</td><td>' + $result.StatusCode + '</td></tr>'
	}
}
$mail_body += "</table></html>"

#Email Parameters
$mailTO = "admin@x.y"
$mailFrom = "SPSite@x.y"
$mailSubject = "Site Up State as of $today"
$mailServer = "localhost"


#Check if -SendEmail (send report via email) switch is specified
if ($SendEmail)
{
	#Check if -AlertsOnly (send report only for Alerts) switch is specified
	if ($AlertsOnly)
	{
		#Check if there is an Alert captured (NOT OK site)
		if ($errorCaptured -eq $true)
		{
			Write-Host "Sending report to email because -AlertsOnly parameter is specified in command" -ForegroundColor Cyan
			Send-MailMessage -From $mailFrom -To $mailTO -Subject "ALERT!!! $mailSubject" -Body $mail_body -SmtpServer $mailServer -BodyAsHtml -Priority 'High'
		}
	}
	else
	{
		#If -AlertsOnly is not specified, then send the report via email regardless if no sites are down
		Write-Host "Sending report to email because -SendEmail parameter is specified in command" -ForegroundColor Cyan
		Send-MailMessage -From $mailFrom -To $mailTO -Subject "Report - $mailSubject" -Body $mail_body -SmtpServer $mailServer -BodyAsHtml
	}
}
else
{
	#If -SendEmail switch is not specified, the report will be saved to file only and will not be send to email
	Write-Host "Not sending report to email because -SendEmail parameter is not specified in command" -ForegroundColor Cyan
}

#Save the Report to html file
$mail_body | Out-File $reportfile
Write-Host "Report is saved in $reportfile" -ForegroundColor Cyan
Write-Host ""
Write-Host (Get-Date) -ForegroundColor Yellow
Write-Host ""
Write-Host "------END------"
Write-Host ""