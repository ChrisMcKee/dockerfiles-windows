# escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2019 AS downloader
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG ES_VERSION="6.8.23"
ENV ES_HOME="C:/elasticsearch" `
    ES_ROOT_URL="https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch"

WORKDIR /temp

RUN Invoke-WebRequest "$env:ES_ROOT_URL-$env:ES_VERSION.zip.sha512" -OutFile 'elasticsearch.zip.sha' -UseBasicParsing; `
    $env:ES_SHA = (Get-Content -Raw elasticsearch.zip.sha).Split(' ')[0]; `
    Invoke-WebRequest "$env:ES_ROOT_URL-$env:ES_VERSION.zip" -OutFile 'elasticsearch.zip' -UseBasicParsing; `
    if ((Get-FileHash elasticsearch.zip -Algorithm sha512).Hash.ToLower() -ne $env:ES_SHA) {exit 1}; `
    Expand-Archive elasticsearch.zip -DestinationPath C:\ ; `
    Rename-Item c:\elasticsearch-$($env:ES_VERSION) elasticsearch;

# Elasticsearch
FROM openjdk:11-nanoserver-1809
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

ARG ES_VERSION="6.8.23"
ENV ES_VERSION=${ES_VERSION} `
    ES_HOME="C:/elasticsearch" `
    ES_JAVA_OPTS="-Xms800m -Xmx800m" `
    TEMP="c:/data/temp" `
    TMP="c:/data/temp"

# Volume and drive mount
VOLUME C:/data

WORKDIR $ES_HOME
COPY --from=downloader C:/elasticsearch/ .
COPY config ./config

EXPOSE 9200 9300
SHELL ["cmd", "/S", "/C"]
CMD "c:/elasticsearch/bin/elasticsearch.bat"

HEALTHCHECK --interval=5s `
    CMD curl --fail http://localhost:9200 || exit 1