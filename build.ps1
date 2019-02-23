#!/usr/bin/pwsh
$ErrorActionPreference="stop"

$pkgver='2.2'
$gz_variants = @('osx-x64', 'linux-x64', 'linux-arm', 'linux-arm64' )
$zip_variants = @('win-x64', 'win-ia32' )
<#
write-host -fore green "Removing existing files %_"
rd -force -recurse -ea 0 dotnet-*
rd -force -recurse -ea 0 dotnet-sdk-*

$gz_variants |% {
  write-host -fore green "RUNTIME: $_"
  # runtime
  New-Item -type Directory -ea 0  "dotnet-$pkgver-$_"
  $gzipfile = (resolve-path "files/$pkgver/dotnet-runtime-*-$_.tar.gz").Path
  $shh = tar xvf $gzipfile -C "dotnet-$pkgver-$_/"
  if( $LASTEXITCODE -ne 0) {
    write-host $shh
    write-error "FAILED"
  }
  
  write-host -fore green "SDK: $_"
  # sdk
  New-Item -type Directory -ea 0  "dotnet-sdk-$pkgver-$_"
  $gzipfile = (resolve-path "files/$pkgver/dotnet-sdk-$pkgver.*-$_.tar.gz").Path
  $shh = tar xvf $gzipfile -C "dotnet-sdk-$pkgver-$_/"
  if( $LASTEXITCODE -ne 0) {
    write-host $shh
    write-error "FAILED"
  }
}
#>

$zip_variants |% {
  $vname = $_ -replace "ia32","x86"
  
  write-host -fore green "RUNTIME: $_"
  # runtime
  New-Item -type Directory -ea 0 "dotnet-$pkgver-$_"
  $zipfile = (resolve-path "files/$pkgver/dotnet-runtime-*-$vname.zip").Path
  $shh= unzip $zipfile -d "dotnet-$pkgver-$_"
  if( $LASTEXITCODE -gt 1) {
    write-host $shh
    write-error "FAILED"
  }

  write-host -fore green "SDK:   $_"
  # SDK
  New-Item -type Directory -ea 0  "dotnet-sdk-$pkgver-$_"
  $zipfile = (resolve-path "files/$pkgver/dotnet-sdk-$pkgver.*-$vname.zip").Path 
  $shh = unzip $zipfile -d "dotnet-sdk-$pkgver-$_" 
  if( $LASTEXITCODE -gt 1) {
    write-host $shh
    write-error "FAILED"
  }
}
