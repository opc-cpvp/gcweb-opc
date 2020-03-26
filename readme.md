# Centre Block

## Dependencies

- Docker

To install docker through chocolatey, run this script through powershell as admin:
```
#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -y allowGlobalConfirmation

#Docker
choco install docker-cli -y
choco install docker-desktop -y
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V, Containers -All

``` 

## Local Development

1. open a command prompt and move to the project's root folder containing the 'src' folder
2. run 'docker-compose build'
3. run 'docker-compose up'
4. start making your needed changes in the src folder
5. the docker container will build the src into the dist folder automatically
