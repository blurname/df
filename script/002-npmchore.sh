#!/bin/bash
npm config set registry=https://registry.npmmirror.com
mkdir -p /home/bl/.npm-global
npm set prefix /home/bl/.npm-global

#mkdir ~/DIY_NPM/
#( cd ~/DIY_NPM/
#wget https://registry.npmjs.org/npm/-/npm-8.12.1.tgz # find latest version from: npm.im/npm, or with: `npm view npm`
#tar xf ./*.tgz # extract
#sudo mkdir -p /usr/lib/node_modules/ # `sudo rm -rf /usr/lib/node_modules/`
#sudo cp -rT ./package /usr/lib/node_modules/npm
## setup bin symlink, from existing install: `ll /usr/bin/np*`
##   lrwxrwxrwx 1 root root    38 May 23 18:01 npm -> ../lib/node_modules/npm/bin/npm-cli.js*
##   lrwxrwxrwx 1 root root    38 May 23 18:01 npx -> ../lib/node_modules/npm/bin/npx-cli.js*
#sudo ln -sfT "../lib/node_modules/npm/bin/npm-cli.js" /usr/bin/npm
#sudo ln -sfT "../lib/node_modules/npm/bin/npx-cli.js" /usr/bin/npx
#)
#rm -rf ~/DIY_NPM/

#sudo npm install -g tsx killport npm yarn pnpm 
