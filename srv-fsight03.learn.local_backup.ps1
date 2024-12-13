#cd "C:\Program Files\pgAdmin 4\v6\runtime\"
#https://stackoverflow.com/questions/30401460/postgres-psql-not-recognized-as-an-internal-or-external-command
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

###--->GLOBAL VARIABLES<---###
[string]$dir="\\srv-aback.axapta.local\axbackup\SQLBackup"
[string]$host="srv-fsight03.learn.local"
#[string]$host="172.21.42.104"
[string]$port="5432"
[string]$username="postgres"
[string]$userpass="QweAsd123"
#[string]$userpass="postgres"
[string]$dbname="LR_BUDGET"
[string]$dburl="postgresql://"+$username+":"+$userpass+"@"+$host+":"+$port+"/"+$dbname

SET PGPASSWORD=$userpass
SET PGUSER=$username
[string]$rights="GRANT CONNECT ON DATABASE ""LR_BUDGET"" TO "+$username+"; "+
    "ALTER USER "+$username+" WITH SUPERUSER; ALTER ROLE;"
    "GRANT SELECT ON ALL TABLES IN SCHEMA public TO "+$username+"; "+
    "GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO "+$username+";" | psql --csv $dburl

New-item -Force –itemtype Directory -Path $dir -Name $host | Out-null
[string]$dir=$dir+'\'+$host
New-item -Force –itemtype Directory -Path $dir -Name $dbname | Out-null
[string]$dir=$dir+'\'+$dbname

[string]$date=Get-Date -Format "yyMMdd"
[string]$time=Get-Date -Format "hhmmss"

###--->FULL BACKUP VARIABLES<---###
[string]$file_full=$dir+"\"+$dbname+"_full"+"_"+$date+"_"+$time+".dump"
[string]$db_log=$dir+"\"+$dbname+"_full"+"_"+$date+"_"+$time+".log"
echo $file_full > $db_log
pg_dump.exe --file $file_full --format=c --blobs --no-unlogged-table-data --lock-wait-timeout=10  $dburl 2>> $db_log #--exclude-table=table

###--->USER BACKUP VARIABLES<---###
[string]$file_usr=$dir+"\"+$dbname+"_usr"+"_"+$date+"_"+$time+".dump"
[string]$usr_log=$dir+"\"+$dbname+"_usr"+"_"+$date+"_"+$time+".log"
echo $file_usr > $usr_log
pg_dumpall.exe -h $host -p $port -U $username -v --globals-only -f $file_usr 2>> $usr_log

###--->SCHEMA BACKUP VARIABLES<---###
#$schemas="SELECT nspname FROM pg_catalog.pg_namespace where nspname = 'demo_ktsp'" | psql --csv $dburl | ConvertFrom-Csv
$schemas="SELECT nspname FROM pg_catalog.pg_namespace" | psql --csv $dburl | ConvertFrom-Csv
foreach ($nspname in $schemas){
  [string]$schema=$nspname.nspname
    if ($schema -notlike "*temp*"){
      [string]$date=Get-Date -Format "yyMMdd"
      [string]$time=Get-Date -Format "hhmmss"

      New-item -Force –itemtype Directory -Path $dir -Name $schema | Out-null
      [string]$file_predata=$dir+'\'+$schema+"\"+$schema+"_pre-data"+"_"+$date+"_"+$time+'.dump'
      [string]$file_data=$dir+'\'+$schema+"\"+$schema+"_data"+"_"+$date+"_"+$time+'.dump'
      [string]$file_postdata=$dir+'\'+$schema+"\"+$schema+"_post-data"+"_"+$date+"_"+$time+'.dump'
      [string]$schema_log=$dir+'\'+$schema+"\"+$schema+"_"+$date+"_"+$time+'.log'

      echo $file_predata > $schema_log
      pg_dump.exe --file $file_predata --format=c --no-blobs --schema=$schema --section=pre-data $dburl 2>> $schema_log
      
      echo $file_data >>  $schema_log
      pg_dump.exe --file $file_data --format=c --no-blobs --schema=$schema --section=data $dburl 2>> $schema_log
      echo $file_postdata >> $schema_log
      pg_dump.exe --file $file_postdata --format=c --no-blobs --schema=$schema --section=post-data $dburl 2>> $schema_log
      #pause
    }
}