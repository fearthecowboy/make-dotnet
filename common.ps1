#!/usr/bin/pwsh
$ErrorActionPreference="stop"


$gz_variants = @('osx-x64', 'linux-x64', 'linux-arm', 'linux-arm64' )
$zip_variants = @('win-x64', 'win-ia32' )

$variants = $gz_variants + $zip_variants
$patch = 1000+ (git rev-list --parents HEAD --count --full-history $PSScriptRoot)
$versions =  @('2.1', '2.2', '3.0')