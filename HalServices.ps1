$hash = @{}
$vmhash = @{}


$locations = Get-AzLocation


foreach ($location in $locations) {
    
    $resourceProviders = [System.Collections.ArrayList]@()
    
    $hash.Add($location.DisplayName, $resourceProviders)
   
    foreach ($resourceProvider in $location.Providers) {
        $index = $resourceProviders.Add($resourceProvider)
    }
            
}
$vmTypes = Get-AzComputeResourceSku | Where-Object { $_.ResourceType.Contains("virtualMachines") }

foreach ($vmType in $vmTypes) {   
    $location = $vmType.Locations[0]
    $vmlocationsList = $vmhash[$location]
    if ($null -eq $vmlocationsList) {
        $vmLocationsList = [System.Collections.ArrayList]@() 
        $vmhash.Add($location, $vmLocationsList)
    }
    $added = $vmlocationsList.Add($vmType.Name)
}
        
$HalAppData = Get-Content -Raw -Path C:\hal\hal_app_deps.json | ConvertFrom-Json
$header = "Application Name"
$firstrow = $true
foreach ( $app in $HalAppData.applications) {
    
    $row = $app.appName
    

    foreach ( $location in $hash.Keys) { 
        if ($firstrow -eq $true) {
            $header += ", " + $location 
        }
        

        $resources = $hash[ $location ]
        $hasResources = $true
        
        foreach ($resourceProvider in $app.resourceProviders) {
            if (-not($resources.Contains($resourceProvider))) { 
                $hasResources = $false

            }
            
        } 
        $vmLocationsList = $vmhash[$location]
        foreach ($vmType in $app.$vmTypes) {
            
            if (-not ($vmLocationsList.Contains($vmType.Name))) { 
                $hasResources = $false
            }
        }
 
        if ($hasresources) { 
            $row += ", Y"
        }
        else {
            $row += ", N"
        } 
        

    }
    
    if ($firstrow -eq $true){
        $header
        $firstrow = $false
    }

    $row

    
}