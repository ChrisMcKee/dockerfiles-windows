#escape=`
# ltsc2019 or ltsc2022
ARG SERVER_VERSION='ltsc2019'
FROM mcr.microsoft.com/windows/servercore:${SERVER_VERSION}

LABEL Description="RabbitMQ" Vendor="Pivotal" Version="3.11.9"
ARG ERLANG_VERSION="25.2.2"

# ERLANG_HOME: erlang will install to this location and rabbitmq will use this environment variable to locate it
# RABBITMQ_VERSION: rabbitmq version used in download url and to rename folder extracted from zip file
# RABBITMQ_CONFIG_FILE: tell rabbitmq where to find our custom config file
ENV ERLANG_HOME="c:\erlang" `
    RABBITMQ_VERSION="3.11.9" `
    RABBITMQ_CONFIG_FILE="c:\rabbitmq.conf"

# setup powershell options for RUN commands
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV URL="http://erlang.org/download/otp_win64_${ERLANG_VERSION}.exe"
ENV RABBITURL="https://github.com/rabbitmq/rabbitmq-server/releases/download/v${RABBITMQ_VERSION}/rabbitmq-server-windows-${RABBITMQ_VERSION}.zip"

RUN Invoke-WebRequest -Uri $env:URL -OutFile "c:\erlang_install.exe" ; `
    Start-Process -Wait -FilePath "c:\erlang_install.exe" -ArgumentList /S, /D=$env:ERLANG_HOME ; `
    Remove-Item -Force -Path "C:\erlang_install.exe"

RUN Write-Host "Downloading RabbitMQ version: $($env:RABBITMQ_VERSION), from: $($env:URL)"; `
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -OutFile rabbitmq.zip -UseBasicParsing -Uri $env:RABBITURL ; `
    Expand-Archive -Path c:\rabbitmq.zip -DestinationPath c:\ ; `
    dir ; `
    Remove-Item -Force -Path "c:\rabbitmq.zip" ; `
    Rename-Item -Path "C:\rabbitmq_server-$($env:RABBITMQ_VERSION)" -NewName "c:\rabbitmq"

RUN Invoke-WebRequest -OutFile rabbitmq_delayed_message_exchange-3.11.1.ez -UseBasicParsing -Uri https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases/download/3.11.1/rabbitmq_delayed_message_exchange-3.11.1.ez ; `
    Expand-Archive rabbitmq.zip -DestinationPath C:\ ; `
    Move-Item "rabbitmq_delayed_message_exchange-3.11.1.ez" "c:\rabbitmq\plugins"



WORKDIR c:\rabbitmq
COPY rabbitmq.config .
COPY start.cmd .

RUN mkdir c:\Users\%USERNAME%\AppData\Roaming\RabbitMQ ; `
    echo my-cookie > c:\Users\%USERNAME%\.erlang.cookie

# Ports
# 4369: epmd, a peer discovery service used by RabbitMQ nodes and CLI tools
# 5672: used by AMQP 0-9-1 and 1.0 clients without TLS
# 5671: used by AMQP 0-9-1 and 1.0 clients with TLS
# 25672: used by Erlang distribution for inter-node and CLI tools communication and is allocated from a dynamic range (limited to a single port by default, computed as AMQP port + 20000).
# 15672: HTTP API clients and rabbitmqadmin (only if the management plugin is enabled)
EXPOSE 4369 5671 5672 25672 15672
CMD start.cmd
