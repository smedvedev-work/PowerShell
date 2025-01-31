# rsync on windows

## Install GitBash

[Source](https://gitforwindows.org/)

## Install rsync and dependences

[Source](https://stackoverflow.com/questions/75752274/rsync-for-windows-that-runs-with-git-for-windows-mingw-tools)

### From Git Bash (run as admin)

```bash
mkdir tmp && cd tmp
```

### Install zstd unpacker for tar

```bash
curl -L https://github.com/facebook/zstd/releases/download/v1.5.5/zstd-v1.5.5-win64.zip --output xxx
unzip xxx
cp zstd-v1.5.5-win64/zstd.exe  'c:\Program Files\Git\usr\bin\'
rm -r * .*
```

### Install rsync

```bash
curl -L https://repo.msys2.org/msys/x86_64/rsync-3.2.7-2-x86_64.pkg.tar.zst --output xxx
tar -I zstd -xvf xxx
cp usr/bin/rsync.exe 'c:\Program Files\Git\usr\bin\'
rm -r * .*

curl -L https://repo.msys2.org/msys/x86_64/libzstd-1.5.5-1-x86_64.pkg.tar.zst --output xxx
tar -I zstd -xvf xxx
cp usr/bin/msys-zstd-1.dll 'c:\Program Files\Git\usr\bin\'
rm -r * .*

curl -L https://repo.msys2.org/msys/x86_64/libxxhash-0.8.1-1-x86_64.pkg.tar.zst --output xxx
tar -I zstd -xvf xxx
cp usr/bin/msys-xxhash-0.dll 'c:\Program Files\Git\usr\bin\'
rm -r * .*

curl -L https://repo.msys2.org/msys/x86_64/liblz4-1.9.4-1-x86_64.pkg.tar.zst --output xxx
tar -I zstd -xvf xxx
cp usr/bin/msys-lz4-1.dll 'c:\Program Files\Git\usr\bin\'

curl -L https://repo.msys2.org/msys/x86_64/libopenssl-3.1.1-1-x86_64.pkg.tar.zst --output xxx
tar -I zstd -xvf xxx
cp usr/bin/msys-crypto-3.dll 'c:\Program Files\Git\usr\bin\'

cd .. && rm -r tmp
```

## Create and configure keys

[Source](https://www.atlassian.com/git/tutorials/git-ssh)

### Create new key

```bash
ssh-keygen -t rsa -b 4096 -C "backup@gmcs.ru"
cat ~/.ssh/id_rsa.pub
```

```text
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDC7Tp3Geo2bZ7NSnlkjjGAjV1iBazNwkpwhZEov8UZNtu55J0+4ipKmNhKmmgi4AvVES68MfSeVKB9QGOGzyNWHlkS2TaRN4OhfgKMLZoPBzgzU+oHa1Itwgn76fGB6QA0qajW4hjPBM9KBg1eGWvVFdw9IHWxWA97yN8ukuGyzW8yx3wQWO6R7xgzdfx8NaxPA4vVnP6lPPhg1aGYix/g42BzBFg47CYFpkQODzYM3y88YbkR8cWl2NKUqylAmfHAVrMhmIEXOYqT0U96G/Rmi483LlxPWGuqzVdYbkko7o4gFIoNWDyQfwKo55eBFh1fc2MLeJ8xgLkaGsTRRNjIoHyw9+LLXSdcakUml3Mrs+9XwOwSXuZHHMl+23xdmAD4oMOqpdlfSdn4Y7m3TfkvvgEl+VFouFXivgfbYR459OMQuYOcWFMdXVmD5C3+rb8DBL7j+jf+68qbK/+LavTL/EAcnKZm2Zk0aB4VGfJiw5YdtGCwyxslQ/albUYXeH54/T/R9LKTFDJY3O++FbK36DyJGrgBZ87N2Cen1eHl+C6eudKHMUOltgUjP0DaY7jaW0sVK9yfGoWvpRdw0buGJQ64jSR1iIOzTSvl9HI/he2cn40PYUK01aBlSQ3seIC+sbJHQmhznzeoinUJtSfigDjoj3DUafJ5HK9SYPvaTQ== srv-gback@gmcs.ru
```

### Add key to authorized_keys

```bash
nano ./.ssh/authorized_keys
```

### Test connection

```bash
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa
touch tst
rsync -avz tst master@bx-app.gmcs.lan:/home/master/
```

### Configure backup

[Source](https://www.reddit.com/r/PowerShell/comments/16y0uqg/how_do_i_run_a_command_in_git_bash_from_powershell/?rdt=57532)

```powershell
$date=Get-Date -Format "yyyyMMdd"
$outputPath="D:/sql-backup/bx-app/$date/"

md $outputPath -ea 0

Start-Process -FilePath "$env:ProgramFiles\Git\git-bash.exe" -ArgumentList @('-i', '-l', '-c',
    '"eval $(ssh-agent -s);
    cd D:/sql-backup/bx-app/$(date +%Y%m%d);
    ssh-add ~/.ssh/id_rsa;
    rsync -rvog --exclude=/var/www/html/bx-site/upload/disk/ master@bx-app.gmcs.lan:/var/www/html ./;
    exit;"')  -NoNewWindow -Wait

cd D:\sql-backup\bx-app\
$name=(Split-Path -leaf -path (Get-Location))+"_"+$date+".zip";
C:\"Program Files"\7-Zip\7z a -mx5 -tzip -mmt $name $date\;
rm -r -force .\$date;
exit;
```