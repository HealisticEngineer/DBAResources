<#
Scripe is to create a SQL Server certificate that supports an elliptic curve.

When deciding between RSA and ECC, consider the specific requirements of your application:
* If you need high security with small key sizes, choose ECC.
* If compatibility or existing implementation considerations are a priority, choose RSA (but plan to migrate to ECC eventually).

Since not all servers have the same support we need to first get a supported type using Get-TlsEccCurve
#>

# get elliptic curve
Get-TlsEccCurve

# get the host and DNS name, and replace the O=Lab and C=GB with the appropriate one for you.
$Subject = "CN=" + [net.dns]::GetHostEntry($env:computername).Hostname + ", O=Lab, C=GB"
$string = [net.dns]::GetHostEntry($env:computername).Hostname
new-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -subject $Subject  -DnsName $string -FriendlyName SQLServer -NotAfter (Get-Date).AddMonths(24) -KeyAlgorithm nistP256
