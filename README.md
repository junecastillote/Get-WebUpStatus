<h3>
Overview</h3>
<div>
This script can be used to query a list of sites and produce an HTML report of their status. I created this script in order to get a report of SharePoint sites that my team manage without having to check the site one by one to see if they are up or not.</div>
<div>

</div>
<h3>
Download</h3>
<div>
https://github.com/junecastillote/Get-WebUpStatus</div>
<div>

</div>
<h3>
How to use</h3>
<h4>
Modify the configuration file</h4>
<div class="separator" style="clear: both; text-align: center;">
<a href="https://4.bp.blogspot.com/-IK6GWPEvTtw/XIKoGysGo5I/AAAAAAAAFcY/O18o46ePOPkTsC2hamjfHC50bpnGMEO3ACPcBGAYYCw/s1600/mRemoteNG_2019-03-09_01-35-53.png" imageanchor="1" style="display: inline !important; margin-left: 1em; margin-right: 1em; text-align: center;"><img border="0" data-original-height="255" data-original-width="500" src="https://4.bp.blogspot.com/-IK6GWPEvTtw/XIKoGysGo5I/AAAAAAAAFcY/O18o46ePOPkTsC2hamjfHC50bpnGMEO3ACPcBGAYYCw/s1600/mRemoteNG_2019-03-09_01-35-53.png" /></a></div>
<div>
</div>
<div>

</div>
<div>
<ul>
<li><b>enableDebug&nbsp;</b>(1 = ON, blank = OFF)</li>
<ul>
<li>Enable or disable the transcript logging</li>
</ul>
<li><b>sendEmail </b>(1 = ON, blank = OFF)</li>
<ul>
<li>Enable of disable sending of the report via email</li>
</ul>
<li><b>alertsOnly </b>(1 = ON, blank = OFF)</li>
<ul>
<li>Indicates whether the report will only be sent if there are errors</li>
</ul>
<li><b class="">mailFrom</b></li>
<ul>
<li>mail sender address</li>
</ul>
<li><b class="">mailTo</b></li>
<ul>
<li>mail recipient addresses. multiple addresses can be separated by comma</li>
</ul>
<li><b class="">mailServerName</b></li>
<ul>
<li>IP address, hostname or FQDN of the smtp&nbsp;relay server</li>
</ul>
<li><b class="">mailServerPort</b></li>
<ul>
<li>SMTP server port to use. Normally this does not need changing, unless your SMTP server is listening on a different port.</li>
</ul>
<li><b class="">sitesListFile</b></li>
<ul>
<li>this indicates the location of the text file containing the list of sites to query</li>
</ul>
</ul>
<div class="separator" style="clear: both; text-align: center;">
<a href="https://4.bp.blogspot.com/-Y5Bsfih5KIc/XIKsCL0-myI/AAAAAAAAFck/ABCR8gWbNVEyBg9CTk02T4A1ooNNcrc5wCPcBGAYYCw/s1600/mRemoteNG_2019-03-09_01-52-52.png" imageanchor="1" style="margin-left: 1em; margin-right: 1em;"><img border="0" data-original-height="123" data-original-width="298" src="https://4.bp.blogspot.com/-Y5Bsfih5KIc/XIKsCL0-myI/AAAAAAAAFck/ABCR8gWbNVEyBg9CTk02T4A1ooNNcrc5wCPcBGAYYCw/s1600/mRemoteNG_2019-03-09_01-52-52.png" /></a></div>
<div class="separator" style="clear: both; text-align: center;">

</div>
<h4>
Run the script</h4>
</div>
<div>
Syntax: <i>.</i><i>\Get-WebUpStatus.ps1 -configFile <file location=""></file></i></div>
<div>

</div>
<div class="separator" style="clear: both; text-align: center;">
<a href="https://2.bp.blogspot.com/-c8k_aVgvR5c/XIKswYNxFLI/AAAAAAAAFcs/Xd3LpQx_jP0_ueTZpHkADHnWSYiljBTZQCPcBGAYYCw/s1600/mRemoteNG_2019-03-09_01-55-51.png" imageanchor="1" style="margin-left: 1em; margin-right: 1em;"><img border="0" data-original-height="370" data-original-width="512" src="https://2.bp.blogspot.com/-c8k_aVgvR5c/XIKswYNxFLI/AAAAAAAAFcs/Xd3LpQx_jP0_ueTZpHkADHnWSYiljBTZQCPcBGAYYCw/s1600/mRemoteNG_2019-03-09_01-55-51.png" /></a></div>
<div class="separator" style="clear: both; text-align: center;">

</div>
<h3>
Output</h3>
<div>
The HTML file report will be created inside the same folder where the script is located</div>
<div>

</div>
<div class="separator" style="clear: both; text-align: center;">
<a href="https://3.bp.blogspot.com/-pO5DAYtojFg/XIKtbW82CDI/AAAAAAAAFc0/KCHEWVYo5VEJru2OUdP32uFC4rYRecJKwCPcBGAYYCw/s1600/mRemoteNG_2019-03-09_01-57-57.png" imageanchor="1" style="margin-left: 1em; margin-right: 1em;"><img border="0" data-original-height="183" data-original-width="518" src="https://3.bp.blogspot.com/-pO5DAYtojFg/XIKtbW82CDI/AAAAAAAAFc0/KCHEWVYo5VEJru2OUdP32uFC4rYRecJKwCPcBGAYYCw/s1600/mRemoteNG_2019-03-09_01-57-57.png" /></a></div>
<div class="separator" style="clear: both; text-align: center;">

</div>

And if the <i>sendEmail&nbsp;</i>parameter is turned on, the same HTML content will be sent via email

<div class="separator" style="clear: both; text-align: center;">

</div>
<div class="separator" style="clear: both; text-align: left;">
<a href="https://2.bp.blogspot.com/-xTEhRbZu-O4/XIKt_6W0X6I/AAAAAAAAFc8/bDA1F9Ymm2s_CiXmNfcfigNeM-GZuyefgCPcBGAYYCw/s1600/mRemoteNG_2019-03-09_02-00-14.png" imageanchor="1" style="margin-left: 1em; margin-right: 1em;"><img border="0" data-original-height="373" data-original-width="604" src="https://2.bp.blogspot.com/-xTEhRbZu-O4/XIKt_6W0X6I/AAAAAAAAFc8/bDA1F9Ymm2s_CiXmNfcfigNeM-GZuyefgCPcBGAYYCw/s1600/mRemoteNG_2019-03-09_02-00-14.png" /></a></div>
<div class="separator" style="clear: both; text-align: left;">

</div>
<h3>
Use as Scheduled Task</h3>
<div>
If you plan to use the script with Task Scheduler, here's a sample reference.</div>
<div class="separator" style="clear: both; text-align: center;">
<a href="https://2.bp.blogspot.com/-MXXq7MBim4g/XIKvL5SFWBI/AAAAAAAAFdQ/nkVjJS8xjcY3xGg5WRUJuM0EUU_FpGeZgCPcBGAYYCw/s1600/mRemoteNG_2019-03-09_02-04-51.png" imageanchor="1" style="margin-left: 1em; margin-right: 1em;"><img border="0" data-original-height="480" data-original-width="632" src="https://2.bp.blogspot.com/-MXXq7MBim4g/XIKvL5SFWBI/AAAAAAAAFdQ/nkVjJS8xjcY3xGg5WRUJuM0EUU_FpGeZgCPcBGAYYCw/s1600/mRemoteNG_2019-03-09_02-04-51.png" /></a></div>

<div class="separator" style="clear: both; text-align: center;">
<a href="https://4.bp.blogspot.com/-ShNxYkP3NPU/XIKvL8w7XiI/AAAAAAAAFdU/HKHr054BKAU3wSP0JlvTvj1MNfeJASbsQCPcBGAYYCw/s1600/mRemoteNG_2019-03-09_02-05-27.png" imageanchor="1" style="margin-left: 1em; margin-right: 1em;"><img border="0" data-original-height="517" data-original-width="594" src="https://4.bp.blogspot.com/-ShNxYkP3NPU/XIKvL8w7XiI/AAAAAAAAFdU/HKHr054BKAU3wSP0JlvTvj1MNfeJASbsQCPcBGAYYCw/s1600/mRemoteNG_2019-03-09_02-05-27.png" /></a></div>

<div class="separator" style="clear: both; text-align: center;">
</div>
<div class="separator" style="clear: both; text-align: center;">
<a href="https://4.bp.blogspot.com/-gx3CyKJegRY/XIKvL69WmtI/AAAAAAAAFdU/nJcbKjQPBeQ-DWWJwkv3qnanhts6kQEBQCPcBGAYYCw/s1600/mRemoteNG_2019-03-09_02-05-41.png" imageanchor="1" style="margin-left: 1em; margin-right: 1em;"><img border="0" data-original-height="500" data-original-width="456" src="https://4.bp.blogspot.com/-gx3CyKJegRY/XIKvL69WmtI/AAAAAAAAFdU/nJcbKjQPBeQ-DWWJwkv3qnanhts6kQEBQCPcBGAYYCw/s1600/mRemoteNG_2019-03-09_02-05-41.png" /></a></div>
<div>

</div>
<div>
Program/script:&nbsp;</div>
<div>
<span style="background-color: yellow;"><i>powershell</i></span></div>
<div>
Arguments:&nbsp;</div>
<div>
<i style="background-color: yellow;">-command C:\Get-WebUpStatus\Get-WebUpStatus.ps1 -configFile C:\Get-WebUpStatus\config.xml</i></div>
<div>

</div>
<h3>
End of Post</h3>
<div>
Please report issues in the Github repository.</div>
<ul><ul></ul>
</ul>
