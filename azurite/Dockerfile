ARG core=mcr.microsoft.com/windows/servercore:ltsc2019
ARG target=mcr.microsoft.com/powershell:lts-nanoserver-1809
FROM $core as download

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV NODE_VERSION 14.21.3
RUN Invoke-WebRequest $('https://nodejs.org/dist/v{0}/SHASUMS256.txt.asc' -f $env:NODE_VERSION) -OutFile 'SHASUMS256.txt.asc' -UseBasicParsing
RUN Invoke-WebRequest $('https://nodejs.org/dist/v{0}/node-v{0}-win-x64.zip' -f $env:NODE_VERSION) -OutFile 'node.zip' -UseBasicParsing ; \
    Expand-Archive node.zip -DestinationPath C:\ ; \
    Rename-Item -Path $('C:\node-v{0}-win-x64' -f $env:NODE_VERSION) -NewName 'C:\nodejs'

ENV GIT_VERSION 2.43.0
ENV GIT_DOWNLOAD_URL https://github.com/git-for-windows/git/releases/download/v${GIT_VERSION}.windows.1/MinGit-${GIT_VERSION}-busybox-64-bit.zip

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; \
    Invoke-WebRequest -UseBasicParsing $env:GIT_DOWNLOAD_URL -OutFile git.zip; \
    Expand-Archive git.zip -DestinationPath C:\git; \
    Remove-Item git.zip

ENV DOWNLOAD_URL https://github.com/Azure/Azurite/archive/refs/tags/v3.27.0.zip

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; \
    Invoke-WebRequest -UseBasicParsing $env:DOWNLOAD_URL -OutFile azurite.zip; \
    Expand-Archive azurite.zip -DestinationPath C:\tmp; \
    move c:\tmp\Azurite-3.27.0 c:\azurite; \
    Remove-Item azurite.zip

FROM $target as base

ENV NPM_CONFIG_LOGLEVEL info

COPY --from=download /nodejs /nodejs
COPY --from=download /git /git
COPY --from=download /azurite /azurite

ARG SETX=/M
USER ContainerAdministrator
RUN setx %SETX% PATH "%PATH%;C:\nodejs;C:\git\cmd;C:\git\mingw64\bin;C:\git\usr\bin"

FROM base as builder

RUN dir c:\azurite

WORKDIR /azurite

RUN npm config set unsafe-perm=true && \
    npm ci && \
    npm run build && \
    npm install -g --loglevel verbose

ENV NODE_ENV=production

RUN npm config set unsafe-perm=true && \
    npm install -g --loglevel verbose

FROM builder as runtime
WORKDIR /nodejs

RUN mkdir c:\\data

# Blob Storage Port
EXPOSE 10000
# Queue Storage Port
EXPOSE 10001
# Table Storage Port
EXPOSE 10002


CMD ["azurite.cmd", "-l", "/data", "--blobHost", "0.0.0.0","--queueHost", "0.0.0.0", "--tableHost", "0.0.0.0"]