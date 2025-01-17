<#
    .SYNOPSIS
    Delete a virtual machine image template

    .DESCRIPTION
    Delete a virtual machine image template and its temporary generated resource group

    .PARAMETER ImageTemplateName
    Mandatory. The name of the image template

    .PARAMETER ImageTemplateResourceGroup
    Mandatory. The resource group name of the image template

    .PARAMETER NoWait
    Optional. Run the command asynchronously

    .EXAMPLE
    Remove-ImageTemplate -ImageTemplateName 'vhd-img-template-001-2022-07-29-15-54-01' -ImageTemplateResourceGroup 'validation-rg'

    Delete the image template 'vhd-img-template-001-2022-07-29-15-54-01' from resource group 'validation-rg' and wait for its completion

    .EXAMPLE
    Remove-ImageTemplate -ImageTemplateName 'vhd-img-template-001-2022-07-29-15-54-01' -ImageTemplateResourceGroup 'validation-rg' -NoWait

    Start the deletion of the image template 'vhd-img-template-001-2022-07-29-15-54-01' from resource group 'validation-rg' and do not wait for its completion
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory = $true)]
    [string] $ImageTemplateName,

    [Parameter(Mandatory = $true)]
    [string] $ImageTemplateResourceGroup,

    [Parameter(Mandatory = $false)]
    [switch] $NoWait
)

begin {
    Write-Debug ('{0} entered' -f $MyInvocation.MyCommand)

    # Install required modules
    $currentVerbosePreference = $VerbosePreference
    $VerbosePreference = 'SilentlyContinue'
    $requiredModules = @(
        'Az.ImageBuilder'
    )
    foreach ($moduleName in $requiredModules) {
        if (-not ($installedModule = Get-Module $moduleName -ListAvailable)) {
            Install-Module $moduleName -Repository 'PSGallery' -Force -Scope 'CurrentUser'
            if ($installed = Get-Module -Name $moduleName -ListAvailable) {
                Write-Verbose ('Installed module [{0}] with version [{1}]' -f $installed.Name, $installed.Version) -Verbose
            }
        } else {
            Write-Verbose ('Module [{0}] already installed in version [{1}]' -f $installedModule[0].Name, $installedModule[0].Version) -Verbose
        }
    }
    $VerbosePreference = $currentVerbosePreference
}

process {
    # Remove artifacts from existing image template
    $resourceActionInputObject = @{
        ImageTemplateName   = $imageTemplateName
        ResourceGroupName   = $imageTemplateResourceGroup
    }
    if ($NoWait) {
        $resourceActionInputObject['NoWait'] = $true
    }
    if ($PSCmdlet.ShouldProcess('Image template [{0}]' -f $imageTemplateName, 'Remove')) {
        $null = Remove-AzImageBuilderTemplate @resourceActionInputObject
        Write-Verbose ('Removed image template [{0}] from resource group [{1}]' -f $imageTemplateName, $imageTemplateResourceGroup) -Verbose
    }
}

end {
    Write-Debug ('{0} exited' -f $MyInvocation.MyCommand)
}
