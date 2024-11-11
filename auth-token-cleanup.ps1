Write-Output '-------------------------------------------'
Write-Output 'Thales CipherTrust Manager '
Write-Output 'Refresh Token cleanup script'
Write-Output ''

$command = ksctl version | Out-Null
write-host $command

if ($LASTEXITCODE -eq 0)
    {
        write-host "Utility ksctl found"
    }
else{
    write-host "Utility ksctl not found. Please install ksctl."
    exit 1
    }
Write-Output ''

$name = Read-Host 'Username '
$securepass = Read-Host 'Password ' -AsSecureString

$pass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securepass))


$url = Read-Host 'CipherTrust FQDN/IP '

$fqdn ="https://" + $url


write-host "Connecting to:  " $fqdn


$cmd = ksctl.exe tokens list --user $name --password $pass  --url $fqdn --nosslverify -l 200 2> $null 3> $null


if ($LASTEXITCODE -eq 0)
  {
    Write-Output ''
    write-host "There are : "  ($cmd | jq .total)  " active sessions. "
    Write-Output ''
    $action = read-Host 'Do you want clean-up them? [y/n]'

    $tokens = $cmd | jq .resources[0].id

    if ($action -eq "y"){
        Write-Output ''
        write-host "Cleanup in process...."

        foreach ($item in $tokens)
         { 
            ksctl.exe --user admin --password $pass tokens delete --id $item 2> $null 3> $null
        }
    }
    Write-Output ''
    write-host "Cleanup completed"
  }
else{
   write-host "Connection error."
   }
