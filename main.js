#!/usr/bin/env node 
process.env["DOTNET_MULTILEVEL_LOOKUP"] = "0";
require("child_process").
  spawn( `${__dirname}/dotnet`, process.argv.slice(2) , { 
    argv0:"dotnet" , stdio :'inherit' 
  }).on('close' , code=> {
    process.exit(code);
  });