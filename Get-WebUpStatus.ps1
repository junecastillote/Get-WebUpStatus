<#
	.NOTES
		===========================================================================
		Created on:   	8-Aug-2015 9:10 AM
		Created by:   	Tito D. Castillote Jr.
						june.castillote@gmail.com
		Filename:     	Get-WebUpStatus.ps1
		===========================================================================
		- V1.0.0.1 date: 13 August 2018
			Updated to support pipeline input, instead of relying on a hard-coded text file.

	.LINK
		https://www.lazyexchangeadmin.com/
		
	.SYNOPSIS
		Use Get-WebUpStatus.ps1 to programmatically check the availability status of Sharepoint Sites or any WebSites.

	.DESCRIPTION
		Script to send web requests to listed Sharepoint Sites or any website and report the returned status.

	.PARAMETER Sites
		Comma-separated list of URLs to test. Accepts pipeline input.

	.PARAMETER SendEmail
		Switch to instruct the script to send the report to specified recipients.
		If not used, script will only check status and save report to file.

	.PARAMETER MailTo
		Report recipient. Required when -SendEmail is used.

	.PARAMETER MailFrom
		Report sender. Required when -SendEmail is used.

	.PARAMETER MailSubject
		Report subject line.

	.PARAMETER MailServer
		E-mail relay server. Required when -SendEmail is used.

	.PARAMETER AlertsOnly
		If specified, the script will only trigger email delivery of report when a "NOT OK" site status is captured.
		Otherwise, a report will be sent even if there are no "NOT OK" sites status.
	
	.EXAMPLE
		.\Get-WebUpStatus.ps1 -Sites google.com -SendEmail -MailTo recipient@domain.com -MailFrom sender@domain.com -MailServer relay.domain.com

		This example will send an email report to specific recipients regardless of site status

	.EXAMPLE
		.\Get-WebUpStatus.ps1 -AlertsOnly -SendEmail

		This example sends the report only if there are captured "NOT OK" sites status

	.EXAMPLE
		.\Get-WebUpStatus.ps1 -Sites google.com,xyz.local

		This example generates the report with all listed sites, but does not send an e-mail

	.EXAMPLE
		Get-Content C:\Temp\sites_list.txt | .\Get-WebUpStatus.ps1 -SendEmail

		This example generates a report for each site in sites_lists.txt (one per line). An e-mail is sent, for each site.
#>

#region Parameters
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
    [string[]]$Sites,
    [Parameter(Mandatory = $false, ParameterSetName = "SendEmail")]
	[switch]$SendEmail,
    [Parameter(Mandatory = $True, ParameterSetName = "SendEmail")]
    [string]$MailTo,
    [Parameter(Mandatory = $True, ParameterSetName = "SendEmail")]
    [string]$MailFrom,
    [Parameter(ParameterSetName = "SendEmail")]
    [string]$MailSubject = "Site Up State as of {0}" -f (Get-Date -f dd-MMM-yyyy-HH:mm),
    [Parameter(Mandatory = $True, ParameterSetName = "SendEmail")]
    [string]$MailServer,
	[Parameter(Mandatory = $false)]
	[switch]$AlertsOnly
)
#endregion

Begin {
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
}

Process {
    #Start of Process
    Write-Host ""
    Write-Host "------START------"
    Write-Host ""
    Write-Host (Get-Date) -ForegroundColor Yellow
    Write-Host ""
    Write-Host 'Checking Sites Up Status' -ForegroundColor Yellow
    Write-Host ""
    Write-Host "===================="

    #Create an empty multi line string to hold the final output/result of checking
    $results = @()

    #Loop through each of the sites from the list
    foreach ($site in $Sites) {
        Write-Host "$site" -ForegroundColor Yellow -NoNewline
        $temp = "" | Select Site, StatusDescription, StatusCode
        Try {
            #if all sites are OK
            $site_status = Invoke-WebRequest -Uri $site -UseDefaultCredentials -TimeoutSec 10
            $temp.Site = $site
            $temp.StatusDescription = $site_status.StatusDescription
            $temp.StatusCode = ""
            Write-Host ": ---> $($temp.StatusDescription)" -ForegroundColor Green
        }
        Catch {
            #if some sites are NOT OK
            $temp.Site = $site
            $temp.StatusDescription = "NOT OK"
            $temp.StatusCode = $_.Exception.Message.Replace("`n", "<br>")
            $errorCaptured = $true
            #Write-Host ": ---> $($temp.StatusDescription)" -ForegroundColor Red
            Write-Host ": ---> $($temp.StatusCode)" -ForegroundColor Red
        }
        Finally {
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

    foreach ($result in $results) {
        if ($result.StatusDescription -ne 'OK') {
            $sitestring = $result.Site.Replace(" ", "%20")
            $mail_body += '<tr><td class = "bad"></td><td>' + $sitestring + '</td><td>' + $result.StatusDescription + '</td><td>' + $result.StatusCode + '</td></tr>'
        }
        elseif ($result.StatusDescription -eq 'OK') {
            $sitestring = $result.Site.Replace(" ", "%20")
            $mail_body += '<tr><td class = "good"></td><td>' + $sitestring + '</td><td>' + $result.StatusDescription + '</td><td>' + $result.StatusCode + '</td></tr>'
        }
    }
    $mail_body += "</table></html>"

    #Check if -SendEmail (send report via email) switch is specified
    if ($SendEmail) {
        #Check if -AlertsOnly (send report only for Alerts) switch is specified
        if ($AlertsOnly) {
            #Check if there is an Alert captured (NOT OK site)
            if ($errorCaptured -eq $true) {
                Write-Host "Sending report to email because -AlertsOnly parameter is specified in command" -ForegroundColor Cyan
                Send-MailMessage -From $mailFrom -To $mailTO -Subject "ALERT!!! $mailSubject" -Body $mail_body -SmtpServer $mailServer -BodyAsHtml -Priority 'High'
            }
        }
        else {
            #If -AlertsOnly is not specified, then send the report via email regardless if no sites are down
            Write-Host "Sending report to email because -SendEmail parameter is specified in command" -ForegroundColor Cyan
            Send-MailMessage -From $mailFrom -To $mailTO -Subject "Report - $mailSubject" -Body $mail_body -SmtpServer $mailServer -BodyAsHtml
        }
    }
    else {
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
}