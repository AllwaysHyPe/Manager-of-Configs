$ErrorActionPreference = 'Stop'

Write-Host ''
Write-Host 'Terraform Azure Starter is ready.' -ForegroundColor Green
Write-Host ''

$commands = @('terraform', 'az', 'gh', 'node', 'pwsh')
foreach ($command in $commands) {
    if (Get-Command $command -ErrorAction SilentlyContinue) {
        $version = switch ($command) {
            'terraform' { (terraform version | Select-Object -First 1) }
            'az' { (az version --query '"azure-cli"' -o tsv) }
            'gh' { (gh --version | Select-Object -First 1) }
            'node' { (node --version) }
            'pwsh' { $PSVersionTable.PSVersion.ToString() }
        }
        Write-Host ("[ok] {0}: {1}" -f $command, $version)
    }
    else {
        Write-Host ("[missing] {0}" -f $command) -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host 'Next steps:' -ForegroundColor Cyan
Write-Host '  1. az login'
Write-Host '  2. Copy-Item terraform.tfvars.example terraform.tfvars'
Write-Host '  3. Edit terraform.tfvars with your resource group and storage account name'
Write-Host '  4. terraform init; terraform validate; terraform plan'
Write-Host ''
Write-Host 'If you are using the Terraform MCP server, install and configure it separately for your environment.' -ForegroundColor DarkCyan