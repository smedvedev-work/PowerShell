#https://github.com/darkoperator/Posh-SSH/blob/master/docs/Get-SCPItem.md
#Install-Module -Name Posh-SSH

$date=Get-Date -Format "yyyyMMdd"
$pass=ConvertTo-SecureString -AsPlainText -Force -String 'VdGW&$J^5&'
$cred=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'master',$pass

Get-SCPItem -ComputerName intrack-01.gmcs.lan -Credential $cred -Path '/data/docker-compose.yaml' -PathType File -Destination "D:\sql-backup\intrack-01\$date\"

Get-SCPItem -ComputerName intrack-01.gmcs.lan -Credential $cred -Path '/data/mysql-data' -PathType Directory -Destination "D:\sql-backup\intrack-01\$date\"

Get-SCPItem -ComputerName intrack-01.gmcs.lan -Credential $cred -Path '/data/redmine-certs' -PathType Directory -Destination "D:\sql-backup\intrack-01\$date\"

Get-SCPItem -ComputerName intrack-01.gmcs.lan -Credential $cred -Path '/data/redmine-config' -PathType Directory -Destination "D:\sql-backup\intrack-01\$date\"
			
Get-SCPItem -ComputerName intrack-01.gmcs.lan -Credential $cred -Path '/data/redmine-files' -PathType Directory -Destination "D:\sql-backup\intrack-01\$date\"
			
Get-SCPItem -ComputerName intrack-01.gmcs.lan -Credential $cred -Path '/data/redmine-plugins' -PathType Directory -Destination "D:\sql-backup\intrack-01\$date\"
			
Get-SCPItem -ComputerName intrack-01.gmcs.lan -Credential $cred -Path '/data/redmine-themes' -PathType Directory -Destination "D:\sql-backup\intrack-01\$date\"			

cd D:\sql-backup\intrack-01\
$name=(Split-Path -leaf -path (Get-Location))+"_"+$date+".zip";
C:\"Program Files"\7-Zip\7z a -mx5 -tzip -mmt $name $date\