# SSL handling helpers
# Nothing is exported from here
function Disable-SslVerification
{
    [CmdletBinding()]
    Param(
    )

    if (-not ([System.Management.Automation.PSTypeName]"TrustEverything").Type)
    {
        Write-Verbose "Adding the PSType for SSL trust override"
        Add-Type -TypeDefinition  @"
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
public static class TrustEverything
{
    private static bool ValidationCallback(object sender, X509Certificate certificate, X509Chain chain,
        SslPolicyErrors sslPolicyErrors) { return true; }
    public static void SetCallback() { System.Net.ServicePointManager.ServerCertificateValidationCallback = ValidationCallback; }
    public static void UnsetCallback() { System.Net.ServicePointManager.ServerCertificateValidationCallback = null; }
}
"@
    }
    Write-Verbose "Adding the trust everything callback"
    [TrustEverything]::SetCallback()
}
function Enable-SslVerification
{
    [CmdletBinding()]
    Param(
    )

    if (([System.Management.Automation.PSTypeName]"TrustEverything").Type)
    {
        Write-Verbose "Removing the trust everything callback"
        [TrustEverything]::UnsetCallback()
    }
}
function Edit-SslVersionSupport
{
    [CmdletBinding()]
    Param(
    )

    Write-Verbose "Configuring SSL version support to be secure"
    # Remove SSLv3, if present
    if ([bool]([System.Net.ServicePointManager]::SecurityProtocol -band [System.Net.SecurityProtocolType]::Ssl3))
    {
        [System.Net.ServicePointManager]::SecurityProtocol = `
            [System.Net.ServicePointManager]::SecurityProtocol -band (-bnot [System.Net.SecurityProtocolType]::Ssl3)
    }
    # Add TLS 1.0, if missing
    if (-not ([bool]([System.Net.ServicePointManager]::SecurityProtocol -band [System.Net.SecurityProtocolType]::Tls)))
    {
        [System.Net.ServicePointManager]::SecurityProtocol = `
            [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls
    }
    # Add TLS 1.1, if missing
    if (-not ([bool]([System.Net.ServicePointManager]::SecurityProtocol -band [System.Net.SecurityProtocolType]::Tls11)))
    {
        [System.Net.ServicePointManager]::SecurityProtocol = `
            [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls11
    }
    # Add TLS 1.2, if missing
    if (-not ([bool]([System.Net.ServicePointManager]::SecurityProtocol -band [System.Net.SecurityProtocolType]::Tls12)))
    {
        [System.Net.ServicePointManager]::SecurityProtocol = `
            [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
    }
}
