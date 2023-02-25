# get eliptic curve
Get-TlsEccCurve

# get host and dns name
$Subject = "CN=" + [net.dns]::GetHostEntry($env:computername).Hostname + ", O=Lab, C=GB"
$string = [net.dns]::GetHostEntry($env:computername).Hostname
new-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -subject $Subject  -DnsName $string -FriendlyName SQLServer -NotAfter (Get-Date).AddMonths(24) -KeyAlgorithm nistP256
