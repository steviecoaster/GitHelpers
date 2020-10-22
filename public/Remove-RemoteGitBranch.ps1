function Remove-RemoteGitBranch {
    <#
    .SYNOPSIS
    Removes a branch from a remote repository
    
    .DESCRIPTION
    Removes a branch from a remote repository
    
    .PARAMETER Branch
    The branch to delete
    
    .EXAMPLE
    Remove-RemoteGitBranch -Branch feature/add-new-widget

    .EXAMPLE
    Remove-RemoteGitBranch -Branch GH1234 -Confirm:$false
    
    #>
    [cmdletbinding(HelpUri="https://github.com/steviecoaster/GitHelpers/wiki/Remove-RemoteGitBranch")]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $Branch
    )

    process {

        if ($PSCmdlet.ShouldContinue("$Branch","DELETE remote branch")) {
            $gitArgs = @('push'
                'origin'
                '--delete'
                $Branch)

            git @gitArgs
        }
    }
}