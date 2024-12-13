$DBdir = '\\srv-aback.axapta.local\axbackup\SQLBackup\srv-fsight03.learn.local\LR_BUDGET'
$Filter = '*.dump'

$count = (Get-ChildItem -File $DBdir -Filter $Filter | Measure-Object).Count

if ($count -ge 8){
Get-ChildItem -Path $DBdir | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-7)} | Remove-Item
}

$schemadirs = Get-ChildItem -Path $DBdir -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName
foreach ($schemadir in $schemadirs){
$schemacount = (Get-ChildItem -File $schemadir.Fullname -Filter $Filter | Measure-Object).Count
if ($schemacount -ge 22){
Get-ChildItem -Path $schemadir.Fullname | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-7)} | Remove-Item
}}

