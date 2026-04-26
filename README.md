# Zabbix-Windows-Certificate-by-Zabbix-agent-Template
Checks certificate date by it Thumbprint. For Windows. Was written because of the need to check Windows NPS (Network Policy Server) certificate for RADIUS. I didn't used any discovery, so Template can only check one specific certificate. You can aways copy and duplicate elements to add more certificates

Template uses Zabbix agent which launch powershell script

## Macros used
|Name|Description|Default|Type|
|----|-----------|-------|----|
|{$CERT.THUMB}|<p>Thumbprint of the specific certificate</p>|``|Text macro|
|{$CERT.EXPIRES}|<p>Days before certificate expires</p>|30|Number|

## Prerequisites
Place cert-check-thumb.ps1 into Zabbix Agent folder (for example C:\Program Files\Zabbix Agent 2\Script\)
Add User Parameter to Zabbix Agent config:
UserParameter=CheckCert[*],powershell -NoProfile -ExecutionPolicy bypass -File "C:\Program Files\Zabbix Agent 2\Script\cert-check-thumb.ps1" $1
Restart Zabbix Agent

For {$CERT.THUMB} macro you can use this script with filter (2027 in this case):
~~~
        Get-ChildItem -Path 'Cert:\LocalMachine\' -Recurse |
            Where-Object { !$_.PsIsContainer } | 
            ForEach-Object {
        
                # use the same fields as certlm.msc
                $issuer = '{0}' -f ([regex] 'CN=([^,]+)').Match($_.Issuer).Groups[1].Value
                $subject = '{0}' -f ([regex] 'CN=([^,]+)').Match($_.Subject).Groups[1].Value
        
                [PSCustomObject]@{
                    Store        = $_.PSParentPath.SubString($_.PSParentPath.IndexOf("::")+2)
                    IssuedTo      = $subject.Trim(', "') #$_.Subject
                    Expires      = $_.NotAfter
                    Thumb        = $_.Thumbprint
                }
            } | Sort-Object -Property Store, IssuedTo | Select-String "2027"
~~~
It will show all certificates which expires in 2027 year. Just choose one