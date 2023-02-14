#escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2019 as installerbase
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN $ErrorActionPreference = 'Stop'; `
    wget https://github.com/MSOpenTech/redis/releases/download/win-3.2.100/Redis-x64-3.2.100.zip -OutFile Redis-x64-3.2.100.zip ; `
    Expand-Archive Redis-x64-3.2.100.zip -dest 'C:\Redis\'; `
    Remove-Item "Redis-x64-3.2.100.zip" -Force

WORKDIR 'C:\Redis\'
COPY ./redis.conf .

FROM mcr.microsoft.com/windows/nanoserver:ltsc2019 as runtime

WORKDIR /Redis

COPY --from=installerbase C:/Redis/ .

SHELL ["cmd", "/S", "/C"]

EXPOSE 6379
CMD C:/Redis/redis-server.exe C:/Redis/redis.conf
