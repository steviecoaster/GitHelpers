[cmdletBinding()]
Param(
    [Parameter()]
    [Switch]
    $Test,

    [Parameter()]
    [Switch]
    $Build,

    [Parameter()]
    [Switch]
    $Deploy,

    [Parameter()]
    [Switch]
    $TestDeploy,

    [Parameter()]
    [Switch]
    $PublishDocs
)



process {
    $root = Split-Path -Parent $MyInvocation.MyCommand.Definition

    Switch ($true) {

        $Test {}

        $Build {

            If (Test-Path $root\Output) {
                
                Remove-Item $root\Output -Recurse -Force

            }

            $null = New-item "$root\Output\GitHelpers" -ItemType Directory

            Copy-Item "$root\GitHelpers.psd1" "$root\Output\GitHelpers"

            Get-ChildItem -Path $root\Public\*.ps1 | Foreach-Object {

                Get-Content $_.FullName | Add-Content "$root\Output\GitHelpers\GitHelpers.psm1"

            }

        }

        $TestDeploy {

            if (Test-Path "$root\GH-Artifact") {
                Remove-Item "$root\GH-Artifact" -Recurse -Force
            }

            $null = New-Item "$root\GH-Artifact" -ItemType Directory


            $PublishLocation = (Resolve-Path "$root/GH-Artifact").Path
            $SourceLocation = (Resolve-Path "$root/Output/GitHelpers").Path

            if ('GitHelpers' -notin (Get-PSRepository).Name) {
                $testRepo = @{
                    Name               = 'GitHelpers'
                    PublishLocation    = $PublishLocation
                    InstallationPolicy = 'Trusted'
                }

                Register-PSRepository @testRepo

            }

            $publishParams = @{
                Path        = $SourceLocation
                Repository  = 'GitHelpers'
                NugetApiKey = 'FileSystem'
            }

            Publish-Module @publishParams

        }

        $Deploy {

            $psdFile = Resolve-Path "$root\Output\GitHelpers"
            
            $publishParams = @{
                Path        = $psdFile
                NugetApiKey = $env:Nugetkey
            }

            Publish-Module @publishParams
        }

        #This would be code for another pipeline to trigger: https://docs.microsoft.com/en-us/azure/devops/pipelines/process/pipeline-triggers?view=azure-devops&tabs=yaml
        $PublishDocs {

            <#
            1. Import new module code
            2. Go to wiki repo
            3. Update docs for new code
            4. Commit changes w/ date stamp
            5. Drop back to root
            #>

            Import-Module $root/Output/GitHelpers/GitHelpers.psd1

            Push-Location ~/Documents/Git/GitHelpers.wiki/

            $date = (Get-Date).ToShortDateString()

            #From the PlatyPS Module (Install-Module PlatyPS)
            New-MarkdownHelp -Module GitHelpers -OutputFolder . -Force

            git add .
            git commit -m "$date - doc updates"
            git push origin

            Pop-Location

        }
    }

}