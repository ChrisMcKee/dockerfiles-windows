@echo off

if not exist %RABBITMQ_BASE%\enabled_plugins (
    call c:\rabbitmq\sbin\rabbitmq-plugins.bat enable rabbitmq_management --offline
    call c:\rabbitmq\sbin\rabbitmq-plugins.bat enable rabbitmq_delayed_message_exchange --offline
)

call c:\rabbitmq\sbin\rabbitmq-server.bat