#escape=`
##Download/Setup
FROM mcr.microsoft.com/windows/servercore:ltsc2019 as setupcore
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG RABBITMQ_VERSION="3.11.9"
ARG RABBITMQ_HOME="C:\rabbitmq"

ARG ERLANG_VERSION="25.2.2"
ARG ERLANG_HOME="C:\erlang"

ENV URL="http://erlang.org/download/otp_win64_${ERLANG_VERSION}.exe"

RUN Write-Host "Downloading Erlang version: $($env:ERLANG_VERSION), from: $($env:URL)"; `
    Invoke-WebRequest -OutFile erlang.exe -UseBasicParsing -Uri $env:URL

RUN Start-Process erlang.exe -ArgumentList '/S', "/D=$env:ERLANG_HOME" -NoNewWindow -Wait

ENV URL="https://github.com/rabbitmq/rabbitmq-server/releases/download/v${RABBITMQ_VERSION}/rabbitmq-server-windows-${RABBITMQ_VERSION}.zip"

RUN Write-Host "Downloading RabbitMQ version: $($env:RABBITMQ_VERSION), from: $($env:URL)"; `
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -OutFile rabbitmq.zip -UseBasicParsing -Uri $env:URL

RUN Write-Host "Downloading RabbitMQ delayed messaging plugin, from github"; `
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -OutFile rabbitmq_delayed_message_exchange-3.11.1.ez -UseBasicParsing -Uri https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases/download/3.11.1/rabbitmq_delayed_message_exchange-3.11.1.ez

RUN Expand-Archive rabbitmq.zip -DestinationPath C:\; `
    Move-Item "C:\rabbitmq_server-$($env:RABBITMQ_VERSION)" $env:RABBITMQ_HOME; `
    Move-Item "rabbitmq_delayed_message_exchange-3.11.1.ez" "${RABBITMQ_HOME}\plugins"

## Erlang Setup in nano
FROM mcr.microsoft.com/windows/nanoserver:ltsc2019 as otp
ENV HOMEDRIVE=c:\ `
    HOMEPATH=Users\ContainerUser `
    ERLANG_HOME=c:\erlang

COPY --from=setupcore c:\erlang c:\erlang
RUN echo my-cookie > c:\.erlang.cookie
RUN copy c:\.erlang.cookie c:\Users\ContainerUser
#RUN icacls c:\windows\.erlang.cookie /grant %USERNAME%:F

# RabbitMQ Image
#FROM mcr.microsoft.com/powershell:lts-nanoserver-1809
FROM otp as runtime

ARG ERLANG_VERSION="25.2.2"
ARG ERLANG_HOME="C:\erlang"
ARG RABBITMQ_VERSION="3.11.9"
ARG RABBITMQ_HOME="C:\rabbitmq"

ENV PATH="C:\Windows\system32;C:\Windows;C:\erlang\bin"

ENV RABBITMQ_VERSION=${RABBITMQ_VERSION} `
    RABBITMQ_CONFIG_FILE="${RABBITMQ_HOME}" `
    RABBITMQ_BASE="c:\rmq-data" `
    ERLANG_HOME="${ERLANG_HOME}"

VOLUME ${RABBITMQ_BASE}
WORKDIR ${RABBITMQ_HOME}

COPY --from=setupcore ${RABBITMQ_HOME} .

COPY rabbitmq.config .
COPY start.cmd .

RUN mkdir c:\Users\%USERNAME%\AppData\Roaming\RabbitMQ
RUN echo my-cookie > c:\Users\%USERNAME%\.erlang.cookie

# Ports
# 4369: epmd, a peer discovery service used by RabbitMQ nodes and CLI tools
# 5672: used by AMQP 0-9-1 and 1.0 clients without TLS
# 5671: used by AMQP 0-9-1 and 1.0 clients with TLS
# 25672: used by Erlang distribution for inter-node and CLI tools communication and is allocated from a dynamic range (limited to a single port by default, computed as AMQP port + 20000).
# 15672: HTTP API clients and rabbitmqadmin (only if the management plugin is enabled)
EXPOSE 4369 5671 5672 25672 15672
CMD start.cmd
