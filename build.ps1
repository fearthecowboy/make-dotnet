#!/usr/bin/pwsh
$ErrorActionPreference="stop"
. ./common.ps1


# ----------------------------------------------------------------------------------------
function getPkg( $PKG, $OS, $CPU, $FLAVOR, $OSNAME, $CMD, $EXE, $pkgver, $patch ) {
  return @"
{
  "name": "$PKG-$pkgver-$OS-$CPU",
  "version": "$pkgver.$patch",
  "description": "dotnet core $FLAVOR for $OS",
  "main": "main.js",
  "os" : [ "$OSNAME" ],
  "cpu" : [ "$CPU" ],
  "bin": {
    "dotnet": "./main.js",
    "dotnet-$CMD": "./main.js",
    "dn": "./dotnet$EXE",
    "find-dotnet-$CMD": "./find.js"
  },
  "author": "Microsoft",
  "license": "MIT"
}
"@
}


write-host -fore green "Removing existing files"
rd -force -recurse -ea 0 dotnet-*
rd -force -recurse -ea 0 dotnet-sdk-*

write-host -fore yellow "Stage 1: Unpack .NET binaries"

$versions |% {
  $pkgver = $_
  
 
  $gz_variants |% {
    write-host -fore green "RUNTIME: $_/$pkgver"
    # runtime
    $shh = New-Item -type Directory -ea 0  "dotnet-$pkgver-$_"
    $gzipfile = (resolve-path "files/$pkgver/dotnet-runtime-*-$_.tar.gz").Path
    $shh = tar xvf $gzipfile -C "dotnet-$pkgver-$_/"
    if( $LASTEXITCODE -ne 0) {
      write-host $shh
      write-error "FAILED"
    }
    
    write-host -fore green "SDK: $_/$pkgver"
    # sdk
    $shh = New-Item -type Directory -ea 0  "dotnet-sdk-$pkgver-$_"
    $gzipfile = (resolve-path "files/$pkgver/dotnet-sdk-$pkgver.*-$_.tar.gz").Path
    $shh = tar xvf $gzipfile -C "dotnet-sdk-$pkgver-$_/"
    if( $LASTEXITCODE -ne 0) {
      write-host $shh
      write-error "FAILED"
    }
  }

  $zip_variants |% {
    $vname = $_ -replace "ia32","x86"
    
    write-host -fore green "RUNTIME: $_/$pkgver"
    # runtime
    $shh = New-Item -type Directory -ea 0 "dotnet-$pkgver-$_"
    $zipfile = (resolve-path "files/$pkgver/dotnet-runtime-*-$vname.zip").Path
    $shh= unzip $zipfile -d "dotnet-$pkgver-$_"
    if( $LASTEXITCODE -gt 1) {
      write-host $shh
      write-error "FAILED"
    }

    write-host -fore green "SDK:   $_/$pkgver"
    # SDK
    $shh = New-Item -type Directory -ea 0  "dotnet-sdk-$pkgver-$_"
    $zipfile = (resolve-path "files/$pkgver/dotnet-sdk-$pkgver.*-$vname.zip").Path 
    $shh = unzip $zipfile -d "dotnet-sdk-$pkgver-$_" 
    if( $LASTEXITCODE -gt 1) {
      write-host $shh
      write-error "FAILED"
    }
  }
}

write-host -fore yellow "Stage 2: Pack platform-dependent variants"
$versions |% {
  $pkgver = $_
  set-content "dotnet-$pkgver-win-x64/package.json" -value (getpkg dotnet win x64 runtime win32 run .exe $pkgver $patch )
  set-content "dotnet-$pkgver-win-ia32/package.json" -value (getpkg dotnet win ia32 runtime win32 run .exe $pkgver $patch  )
  set-content "dotnet-$pkgver-osx-x64/package.json" -value (getpkg dotnet osx x64 runtime darwin run '' $pkgver $patch )
  set-content "dotnet-$pkgver-linux-x64/package.json" -value (getpkg dotnet linux x64 runtime linux run '' $pkgver $patch )
  set-content "dotnet-$pkgver-linux-arm/package.json" -value (getpkg dotnet linux arm runtime linux run '' $pkgver $patch )
  set-content "dotnet-$pkgver-linux-arm64/package.json" -value (getpkg dotnet linux arm64 runtime linux run '' $pkgver $patch )

  set-content "dotnet-sdk-$pkgver-win-x64/package.json" -value (getpkg dotnet-sdk win x64 sdk win32 sdk .exe $pkgver $patch )
  set-content "dotnet-sdk-$pkgver-win-ia32/package.json" -value (getpkg dotnet-sdk win ia32 sdk win32 sdk .exe $pkgver $patch  )
  set-content "dotnet-sdk-$pkgver-osx-x64/package.json" -value (getpkg dotnet-sdk osx x64 sdk darwin sdk '' $pkgver $patch )
  set-content "dotnet-sdk-$pkgver-linux-x64/package.json" -value (getpkg dotnet-sdk linux x64 sdk linux sdk '' $pkgver $patch )
  set-content "dotnet-sdk-$pkgver-linux-arm/package.json" -value (getpkg dotnet-sdk linux arm sdk linux sdk '' $pkgver $patch )
  set-content "dotnet-sdk-$pkgver-linux-arm64/package.json" -value (getpkg dotnet-sdk linux arm64 sdk linux sdk '' $pkgver $patch )

  $variants |% { 
    copy main.js "dotnet-$pkgver-$_/main.js" 
    copy find.js "dotnet-$pkgver-$_/find.js" 
    copy main.js "dotnet-sdk-$pkgver-$_/main.js" 
    copy find.js "dotnet-sdk-$pkgver-$_/find.js" 
    
    pushd "dotnet-$pkgver-$_" ; $shh = npm pack ; cp *.tgz ../packages/ ; rm *.tgz ; popd 
    pushd "dotnet-sdk-$pkgver-$_" ; $shh = npm pack ; cp *.tgz ../packages/ ; rm *.tgz ; popd 
  }
}

push "$PSScriptRoot/dotnet"
npm run build
popd 

