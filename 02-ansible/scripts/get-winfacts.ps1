# Ansible Fact Script to get Windows Services

$enabled_services =  (get-service | where-object status -eq running).name

$services = @{}

# Add services to hashtable
foreach ($service in $enabled_services) {
    $services.add($service, 'running')
}

# Output a hashtable with all custom ansible facts
@{
    services = $services
}