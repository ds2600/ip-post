$LOCAL_LOG = "C:\ip-post\ip-post.log"
$LOG_SIZE = (Get-Item $LOCAL_LOG).length/1MB
If ($LOG_SIZE -gt 10) { Remove-Item $LOCAL_LOG }

Get-Date >> C:\ip-post\ip-post.log
Get-Content "C:\ip-post\settings.ini" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } } 
$UUID = (wmic csproduct get uuid)[2]

$ADDITIONAL_PAR = @{
    uuid = $UUID
    key = $h.Get_Item("API_KEY")
} 

# The below line is used if using a proper IPInfo Token
# $IP_INFO = Invoke-RestMethod -Uri ('http://ipinfo.io/'+(Invoke-WebRequest -uri "http://ifconfig.me/ip")+'?token='+($h.Get_Item("IPINFO_TOKEN")))

$IP_INFO = Invoke-RestMethod -Uri ('http://ipinfo.io/'+(Invoke-WebRequest -uri "http://ifconfig.me/ip").Content)
$IP_INFO | Add-Member $ADDITIONAL_PAR
$BODY = $IP_INFO | ConvertTo-Json

Write-Output "Sending request to: " + $h.Get_Item("API_URI") >> C:\ip-post\ip-post.log
$RESP = Invoke-WebRequest -Method Post -Uri $h.Get_Item("API_URI") -Body $BODY -UseBasicParsing >> C:\ip-post\ip-post.log
$RESP >> C:\ip-post\ip-post.log
Write-Output "==============="  >> C:\ip-post\ip-post.log