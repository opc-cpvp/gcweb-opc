# Centre Block

## Global Dependencies

- NodeJS v4.8.0 to v8.12.0
- Latest Java version

To install global node dependencies run:
```
$ npm install -g bower grunt-cli
``` 
To install winodws build tools
```
$ npm install --global --production windows-build-tools
``` 

## Local Development

1. Install local dependencies: `$ npm install`

1. On your initial setup run: `$ grunt init` and grab a coffee... This is probably going to take awhile.

1. Run `grunt dist` to build the site

1. Start a local server and watcher with: `$ grunt server`

1. Make changes... Wait forever for assembler.

## Distribution

To build a dist run:
```
$ grunt dist
```
