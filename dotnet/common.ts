import {join, normalize} from 'path';
import {platform, homedir, arch}  from 'os';
import {statSync} from 'fs';
const pkg = require("../package.json");

export const basename = pkg.basename;
const dotnetVersion = pkg['dotnet-version'];

export const basePath = process.env.DOTNET_SHARED_HOME || normalize(`${homedir()}/.net/${dotnetVersion}`);
const architecture = process.env.DOTNET_SHARED_ARCH || detectArchitecture();

export const dotnetPackageName = `${basename}-${dotnetVersion}-${architecture}`;
export const installationPath = join(basePath, `node_modules/${dotnetPackageName}/`);
export const packageJsonPath = join(installationPath , "package.json");

export const fileExists = (path: string)=> { try{ return statSync(path).isFile(); } catch { return false; } }

function detectArchitecture(): string {
  switch (platform()) {
    case 'darwin': 
      return `osx-${arch()}`;
    case 'linux': 
      return `linux-${arch()}`;
    case 'win32': 
      return `win-${arch()}`;
  }
  throw new Error(`Unsupported Platform: ${platform()}`);
}