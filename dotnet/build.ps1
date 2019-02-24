pushd $PSScriptRoot
$ErrorActionPreference="stop"
. ../common.ps1


function mkPackageJson($FLAVOR, $SDKORRUNTIME, $SDKORRUN, $BASENAME, $pkgver, $patch) {
return @"
{
  "basename" : "$($BASENAME)",
  "name": "dotnet$($FLAVOR)$($pkgver)",
  "version": "$($pkgver).$($patch)",
  "description": "Platform agnostic installation of .NET Core $SDKORRUNTIME $($pkgver)",
  "engines": {
    "node": ">=6.4.0"
  },
  "dotnet-version": "$pkgver",
  "main": "./dist/call.js",
  "typings": "./dist/main.d.ts",
  "bin": {
    "dotnet": "./dist/call.js",
    "dotnet-$SDKORRUN": "./dist/call.js",
    "dotnet-$SDKORRUN-$($pkgver)": "./dist/call.js",
    "install-dotnet-$SDKORRUNTIME": "./dist/app.js",
    "which-dotnet-$SDKORRUNTIME": "./dist/find.js",
    "which-dotnet": "./dist/find.js"
  },
  "scripts": {
    "postinstall": "node -e \"/*PostInstall: Installs platform-specific .NET framework */try{require('./dist/app.js')}catch(e){}\""
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/fearthecowboy/dotnet.git"
  },
  "keywords": [
    "dotnet",
    ".NET",
    "core",
    "$SDKORRUNTIME",
    "$($pkgver)",
    "install"
  ],
  "license": "MIT"
}
"@

}

$versions |% {
 $pkgver = $_
  rd -recurse -force -ea 0 "./dotnet-${pkgver}"
  rd -recurse -force -ea 0 "./dotnet-sdk-${pkgver}"

  $shh = new-item -type directory -ea 0 "./dotnet-${pkgver}"
  $shh = new-item -type directory -ea 0 "./dotnet-sdk-${pkgver}"

  copy-item -recurse ./dist/ "./dotnet-${pkgver}/dist"
  copy-item -recurse ./dist/ "./dotnet-sdk-${pkgver}/dist"

  set-content "./dotnet-${pkgver}/package.json" -value (mkPackageJson '-' runtime run 'dotnet' $pkgver $patch )
  set-content "./dotnet-sdk-${pkgver}/package.json" -value (mkPackageJson '-sdk-' runtime run 'dotnet-sdk' $pkgver $patch )

  copy-item ./.npmignore "./dotnet-${pkgver}/.npmignore"
  copy-item ./.npmignore "./dotnet-sdk-${pkgver}/.npmignore"

  $README = get-content -raw ./readme.md
  set-content "./dotnet-${pkgver}/readme.md" ($README -replace "{flavor}","-"  -replace "{sdkorruntime}","runtime" -replace "{version}",$pkgver  )
  
  $README = get-content -raw ./readme.md
  set-content "./dotnet-sdk-${pkgver}/readme.md" ($README -replace "{flavor}","-sdk-"  -replace "{sdkorruntime}","sdk" -replace "{version}",$pkgver )
  
  pushd "$PSScriptRoot/dotnet-${pkgver}"
    npm pack 
    cp *.tgz "$PSScriptRoot/../packages/" 
    rm *.tgz
  popd
  
  pushd "$PSScriptRoot/dotnet-sdk-${pkgver}"
    npm pack 
    cp *.tgz "$PSScriptRoot/../packages/" 
    rm *.tgz
  popd
}

popd