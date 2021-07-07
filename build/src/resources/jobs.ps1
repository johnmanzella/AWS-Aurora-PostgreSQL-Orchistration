$hookFile="C:\temp\jobs.ps1"         # Hook FileName
$HOOK=@'
#########################################################
#                     DELPHIX CORP                      #
#########################################################

$APIPATH="C:\\Temp"
$LOG="C:\temp\azsqlw.log"
$DT = $((Get-Date).ToString('yyyy-MM-dd_hh:mm:ss'))
echo "${DT} -------------------- Jobs API Started" >> $LOG

#
# Environment Info ...
#
#echo "Environment: " >> ${LOG}
###$env:PATH >> ${LOG}
#Get-ChildItem Env: | Out-File $LOG -Append

#########################################################
## Subroutines and Parameter Initialization ...

#
# Delphix Engine Variables ...
#
$BaseURL = "http://$env:DELPHIX_HOST/resources/json/delphix"    	#"http://13.90.196.157/resources/json/delphix"
$DMUSER = $env:DELPHIX_USER     	#"delphix_admin"
$DMPASS = $env:DELPHIX_PASS		#"delphix"
$SOURCE_SID = $env:VDB_NAME   

#
# Application Variables ...
#
$nl = [Environment]::NewLine
$CONTENT_TYPE = "Content-Type: application/json"
$COOKIE = "cookies.txt"
$DELAYTIMESEC=10
$ignore="No"                 # Ignore Exiting when hitting an API Error 
$DT=Get-Date -Format s

#########################################################
#         NO CHANGES REQUIRED BELOW THIS POINT          #
#########################################################

#########################################################
## Authentication ...

echo "Authenticating on ${BaseURL} ... ${nl}" >> ${LOG}
echo "${nl} Parameters: $DMUSER $DMPASS $COOKIE ${SOURCE_SID} ${nl}" >> ${LOG}

#
# Delphix Session API ...
#
echo "${nl}Calling Session API ...${nl}" >> ${LOG}
$arr=@{}
$arr["type"] = "APISession"
$arr["version"] = @{}
$arr["version"]["type"]="APIVersion"
$arr["version"]["major"]=1
$arr["version"]["minor"]=10
$arr["version"]["micro"]=0
$json = $arr | ConvertTo-Json
$results = Invoke-RestMethod -URI "${BaseURL}/session" -SessionVariable session -Method Post -Body $json -ContentType 'application/json'
#$results |get-member
$results.error | Out-File $LOG -Append
$results.status | Out-File $LOG -Append
##$status = ParseStatus $results "${ignore}"
echo "Session API Results: ${status}" >> ${LOG}

#
# Delphix Login API ...
#
echo "${nl}Calling Login API ...${nl}" >> ${LOG}
$person = @{}
$person["type"]="LoginRequest"
$person["username"]="${DMUSER}"
$person["password"]="${DMPASS}"
$json = $person | ConvertTo-Json
$results = Invoke-RestMethod -URI "${BaseURL}/login" -WebSession $session -Method Post -Body $json -ContentType 'application/json'
$results.error | Out-File $LOG -Append
$results.status | Out-File $LOG -Append
##$status = ParseStatus $results "${ignore}"
echo "${nl}Login API Results: ${results}" >> ${LOG}
echo "Login Successful ..." >> ${LOG}

#########################################################
## Get running job ...

#STATE="RUNNING"
#STATUS=`curl -s -X GET -k "${BaseURL}/job?pageSize=${PAGESIZE}&jobState=${STATE}" -b "${COOKIE}" -H "${CONTENT_TYPE}"`
#STATUS=`curl -s -X GET -k "${BaseURL}/action?parentAction=ACTION-600181" -b "${COOKIE}" -H "${CONTENT_TYPE}"`
#STATUS=`curl -s -X GET -k "${BaseURL}/action/ACTION-600181" -b "${COOKIE}" -H "${CONTENT_TYPE}"`

$results = Invoke-RestMethod -Method Get -ContentType "application/json" -WebSession $session -URI "${BaseURL}/job?jobState=RUNNING"
##$status = ParseStatus $results "${ignore}"
$results | Out-File $LOG -Append
$results.status | Out-File $LOG -Append
$results.error | Out-File $LOG -Append
$results.error.details | Out-File $LOG -Append 

try {
   #$str = ConvertFrom-Json $results
   $str = $results | ConvertTo-Json 
   echo "$str"
   echo "====" >> ${LOG}
   echo "$str" >> ${LOG}
   $env:JSON = $str
   #$a = $results.result
   #$a | Out-File $LOG -Append 

} catch {
   echo "No current running jobs" >> ${LOG}
}
############## E O F ####################################
$DT = $((Get-Date).ToString('yyyy-MM-dd_hh:mm:ss'))
echo "${DT} -------------------- Jobs API Ended"  >> ${LOG}
exit 0

'@

#########################################################
## Write-Execute Hook Script using local powershell ... 

Out-File -FilePath $hookFile -InputObject $HOOK -Encoding ASCII
Set-Alias pslocal32 "$env:windir\System32\WindowsPowerShell\v1.0\powershell.exe"
Set-Alias pslocal64 "$env:windir\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"
if (Test-Path $hookFile -PathType Leaf) {
  pslocal64 $hookFile
  echo $env:JSON        		# return stdout to calling Python method
  ##DEBUG Comment out Remove-Item##
  ##Remove-Item $hookFile -ErrorAction Ignore
}
Remove-Variable -Name DMPASS -ErrorAction SilentlyContinue

