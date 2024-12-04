# zabbix
ZabbixSSL
руководство по настройке мониторинга и проверке SSL сертификатов в Zabbix для администраторов

    Существенно уменьшено количество файлов. Для работы шаблона достаточно самого шаблона, одного скрипта и одного конфигурационного файла с пользовательскими переменными.
    Механизм crontab больше не используется для получения данных SSL сертификатов.
    Добавлена поддержка SSL сертификатов для FTP серверов.
    Добавлена поддержка SSL сертификатов для SMTP серверов.
    Добавлена поддержка международных доменных имён (IDN). Например, “пример.рф”.
    Добавлена возможность указать номер порта.
    Добавлена возможность указать IP адрес сервера.
    Добавлена возможность указать название SSL сертификата, которое используется в именах триггеров.
    Кроме срока действия сертификата отслеживаются дополнительные данные.
    Все данные сертификата получаются одним запросом, скрипт можно использовать для просмотра данных SSL сертификата из Linux.
    Мониторинг как внешних, так и локальных сертификатов.
    Не стал делать проверку валидности сертификата, это требует дополнительного запроса в скрипте. Да и локальные сертификаты, подписанные корпоративным центром сертификации, проверку всё равно не проходят.
    Тайминги настраиваются в макросах шаблона.
    И самое главное, список проверяемых SSL сертификатов можно менять в самом шаблоне, он больше не хранится на хосте. Для получения данных SSL сертификатов используется низкоуровневое обнаружение.
https://kalyuzhnyy.ru/monitoring-ssl-sertifikatov-sredstvami-zabbix-7/
