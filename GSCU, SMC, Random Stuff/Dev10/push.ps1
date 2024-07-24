. .\version.ps1

If ($Version.EndsWith('-dev')) {
	Write-Host "Cannot push development version '$Version' to NuGet."
	Exit 1
}

.\nuget\NuGet.exe 'push' ".\nuget\release\Microsoft.VisualStudio.Project.10.0.$Version.nupkg"
.\nuget\NuGet.exe 'push' ".\nuget\release\Microsoft.VisualStudio.Project.11.0.$Version.nupkg"
.\nuget\NuGet.exe 'push' ".\nuget\release\Microsoft.VisualStudio.Project.12.0.$Version.nupkg"
