[CmdletBinding(HelpUri = 'https://docs.chocolatey.org/en-us/c4b-environments/quick-start-environment/advanced-client-configuration/')]
param(
    # The DNS name of the server that hosts your repository, Jenkins, and Chocolatey Central Management
    [String]$Fqdn = 'chocolatey.allwayshype.com',

    # Client salt value used to populate the centralManagementClientCommunicationSaltAdditivePassword value in the Chocolatey config file
    [String]$ClientCommunicationSalt = '{{ Replace with ccmClientCommunicationSalt (This value is in your Azure KeyVault) }}',

    # Server salt value used to populate the centralManagementServiceCommunicationSaltAdditivePassword value in the Chocolatey config file
    [String]$ServiceCommunicationSalt = '{{ Replace with ccmServiceCommunicationSalt (This value is in your Azure KeyVault) }}',

    # The credential for accessing your Nexus repository, e.g. for 'chocouser'
    $RepositoryCredential = [System.Net.NetworkCredential]@{
        'userName' = 'chocouser'
        'password' = 'o.czf899BBi=!5zQORQ>oG3=G*QvIEA_3\GWH9lLS_cSD6.8y@MHn71VSLxuAN]W'
    },

    # The URL of a proxy server to use for connecting to the repository.
    [String]$ProxyUrl,

    # The credentials, if required, to connect to the proxy server.
    [PSCredential]$ProxyCredential,

    # Install the Chocolatey Licensed Extension with right-click context menus available
    [Switch]$IncludePackageTools,

    # Allows for the application of user-defined configuration that is applied after the base configuration.
    # Can override base configuration with this parameter
    [Hashtable]$AdditionalConfiguration,

    # Allows for the toggling of additional features that is applied after the base configuration.
    # Can override base configuration with this parameter
    [Hashtable]$AdditionalFeatures,

    # Allows for the installation of additional packages after the system base packages have been installed.
    [Hashtable[]]$AdditionalPackages,

    # Allows for the addition of alternative sources after the base configuration  has been applied.
    # Can override base configuration with this parameter
    [Hashtable[]]$AdditionalSources
)
$RepositoryCredential = [PSCredential]::new($RepositoryCredential.UserName, $RepositoryCredential.SecurePassword)
$params = $PSBoundParameters
$PSCmdlet.MyInvocation.MyCommand.Parameters.Keys.Where{
    $_ -notin [System.Management.Automation.PSCmdlet]::CommonParameters + "FQDN" -and -not $params.ContainsKey($_)
}.ForEach{ $params[$_] = (Get-Variable -Name $_ -Scope 0 -ErrorAction SilentlyContinue).Value }
$params.RepositoryUrl = "https://$($fqdn)/nexus/repository/ChocolateyInternal/index.json"

$downloader = [System.Net.WebClient]::new()
$downloader.Credentials = $RepositoryCredential

$script = $downloader.DownloadString("https://$($FQDN)/nexus/repository/choco-install/ClientSetup.ps1")

& ([scriptblock]::Create($script)) @params