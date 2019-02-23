#!/usr/bin/pwsh
$ErrorActionPreference="stop"
. ./common.ps1


$versions |% {
  $pkgver = $_

  $variants |% { 
    pushd "dotnet-$pkgver-$_" ; npm publish ; popd 
    pushd "dotnet-sdk-$pkgver-$_" ; npm publish ; popd 
  }
}