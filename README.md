#                                                               1. NFS Сетевая файловая система


Network File System (NFS) – протокол распределенной файловой системы для организации общего доступа к файлам и папками. За основу в NFS взят протокол удаленных процедур (ONC RPC).  Протокол NFS позволяет монтировать удалённые файловые системы через сеть в локальное дерево каталогов, как если бы это была примонтирована дисковая файловая система. 

##                                                              2. Домашнее задание



###                                         2.1 Настройка сервера NFS

1. Сначала необходимо установить нужный пакет для работы как клиента так и сервера. Пакет - nfs-utils, который устанавливает демон для NFS-сервера ядра и связанные с ним инструменты. По умолчанию, если не ставится сервер в минимальной конфигурации, пакет уже установлен.

            [root@nfssrv ~]# yum install nfs-utils

2. Проверяем статус фаервола, запущен или нет, и включаем если нет.
        
            [root@nfssrv ~]# firewall-cmd --state || systemctl enable --now firewalld.service
            
3. Добавляем правила для работы с nfs сервером через firewalld ( доступ к портам на которых работют nfsd, rpcbuind, mountd)
            
            [root@nfssrv ~]# firewall-cmd --permanent --zone=public --add-service=nfs
            success
            [root@nfssrv ~]# firewall-cmd --permanent --zone=public --add-service=mountd
            success
            [root@nfssrv ~]# firewall-cmd --permanent --zone=public --add-service=rpc-bind
            success
            [root@nfssrv ~]# firewall-cmd --reload
            success
           
           [root@nfssrv ~]# firewall-cmd --list-all
            public (active)
            target: default
            icmp-block-inversion: no
            interfaces: eth0 eth1
            sources: 
            services: mountd nfs rpc-bind ssh
            ports: 
            protocols: 
            masquerade: no
            forward-ports: 
            source-ports: 
            icmp-blocks: 
            rich rules:
        
        
4. Создадим структуру экспортируемого каталога nfs_share:

            [root@nfssrv ~]# mkdir -p  /vagrant/nfs_share/upload
            

            
5. Создание файла экпорта, с нужными нам параметрами
        
*           Настройка файла /etc/exports
            В простейшем случае, файл /etc/exports является единственным файлом, требующим редактирования для настройки NFS-сервера.  Данный файл управляет следующими аспектами:

            Какие клиенты могут обращаться к файлам на сервере
            К каким иерархиям каталогов на сервере может обращаться каждый клиент
            Как пользовательские имена клиентов будут отображаться на локальные имена пользователей
            Каждая строка файла exports имеет следующий формат:

            точка_экспорта клиент1(опции) [клиент2(опции)  ...]

             где точка_экспорта абсолютный путь экспортируемой иерархии каталогов, клиент1 - n имя одного или более клиентов или IP-адресов, разделенные пробелами, которым разрешено монтировать точку_экспорта.
        
   
*   auth_nlm (no_auth_nlm) или secure_locks (insecure_locks) - указывает, что сервер должен требовать аутентификацию запросов на блокировку (с помощью протокола NFS Lock Manager (диспетчер блокировок NFS)).
        
*   nohide (hide) - если сервер экспортирует две иерархии каталогов, при этом одна вложенна (примонтированна) в другую. Клиенту необходимо явно смонтировать вторую (дочернюю) иерархию, иначе точка монтирования дочерней иерархии будет выглядеть как пустой каталог. Опция nohide приводит к появлению второй иерархии каталогов без явного монтирования. (прим: я данную опцию так и не смог заставить работать... )

*   ro (rw) - Разрешает только запросы на чтение (запись). (в конечном счете - возможно прочитать/записать или нет определяется на основании прав файловой системы, при этом сервер не способен отличить запрос на чтение файла от запроса на исполнение, поэтому разрешает чтение, если у пользователя есть права на чтение или исполнение.)

*   secure (insecure) - требует, чтобы запросы NFS поступали с защищенных портов (< 1024), чтобы программа без прав root не могла монтировать иерархию каталогов.

*   subtree_check (no_subtree_check) - Если экспортируется подкаталог фаловой системы, но не вся файловая система, сервер проверяет, находится ли запрошенный файл в экспортированном подкаталоге. Отключение проверки уменьшает безопасность, но увеличивает скорость передачи данных.

*   sync (async) - указывает, что сервер должен отвечать на запросы только после записи на диск изменений, выполненных этими запросами. Опция async указывает серверу не ждать записи информации на диск, что повышает производительность, но понижает надежность, т.к. в случае обрыва соединения или отказа оборудования возможна потеря информации.

*   wdelay (no_wdelay) - указывает серверу задерживать выполнение запросов на запись, если ожидается последующий запрос на запись, записывая данные более большими блоками. Это повышает производительность при отправке больших очередей команд на запись. no_wdelay указывает не откладывать выполнение команды на запись, что может быть полезно, если сервер получает большое количество команд не связанных друг с другом.

#           Опции отображения (соответствия) идентификаторов пользователей при настройке экспорта 

*   root_squash (no_root_squash) - При заданной опции root_squash, запросы от пользователя root отображаются на анонимного uid/gid, либо на пользователя, заданного в параметре anonuid/anongid.

*   no_all_squash (all_squash) - Не изменяет UID/GID подключающегося пользователя. Опция all_squash задает отображение ВСЕХ пользователей (не только root), как анонимных или заданных в параметре anonuid/anongid. { Для разрешения на папку uploads, в ДЗ, можно использовать эту опцию и на папку настроить доступ пользователю "nfsnobody" на запись т.к. трансляция всех подключаемых пользователей будет производится в этого локального пользователя/ } 

*   anonuid=UID и anongid=GID - Явно задает UID/GID для анонимного пользователя.

*   map_static=/etc/file_maps_users - Задает файл, в котором можно задать сопоставление удаленных UID/GID - локальным UID/GID.


    Экспорт символических ссылок и файлов устройств. При экспорте иерархии каталогов, содержащих символические ссылки, необходимо, чтобы объект ссылки был доступен клиентской (удаленной) системе, то есть должно выполняться одно из следующих правил:
    в клиентской  файловой системе должен существовать объект ссылки
    необходимо экспортировать и смонтировать объект ссылки
    Файл устройства относится к интерфейсу ядра Linux. При экспорте файла устройства экспортируется этот интерфейс. Если клиентская система  не имеет устройства такого же типа, то экспортированное устройство не будет работать. В клиентской системе, при монтировании NFS объектов можно использовать опцию nodev, чтобы файлы устройств в монтируемых каталогах не использовались.
    Опции по умолчанию в разных системах могут различаться, их можно посмотреть в файле /var/lib/nfs/etab. После описания экспортированного каталога в /etc/exports и перезапуска сервера NFS все недостающие опции (читай: опции по-умолчанию) будут отражены в файле /var/lib/nfs/etab.


        
        
        
        root@nfssrv nfs_share]# vi /etc/exports
        
        /nfs_share               192.168.50.11(rw,sync,root_squash,no_subtree_check)

        rw - монтирование в режиме чтения/записи, (может быть ro - только чтение)
        

        Управление сервером NFS

#           Управление сервером NFS осуществляется с помощью следующих утилит:

- nfsstat
- showmount
- exportfs

    --- nfsstat: статистика NFS и RPC
            
    Утилита nfsstat позволяет посмотреть статистику RPC и NFS серверов. Опции команды можно посмотреть в man nfsstat.

    --- showmount: вывод информации о состоянии NFS

    Утилита showmount запрашивает демон rpc.mountd на удалённом хосте о смонтированных файловых системах. По умолчанию выдаётся отсортированный список клиентов. Ключи:

        -all(-a) \- выдаётся список клиентов и точек монтирования с указанием куда клиент примонтировал каталог. Эта информация может быть не надежной.
        -directories(-d) \- выдаётся список точек монтирования.
        -exports(-e) \- выдаётся список экспортируемых файловых систем с точки зрения nfsd.
    
    При запуске showmount без аргументов, на консоль будет выведена информация о системах, которым разрешено монтировать локальные каталоги. Например, хост ARCHIV нам предоставляет список экспортированных каталогов с IP адресами хостов, которым разрешено монтировать указанные каталоги:
     
    --- exportfs: управление экспортированными каталогами

    Данная команда обслуживает экспортированные каталоги, заданные в файле /etc/exports, точнее не обслуживает, а синхронизирует с файлом /var/lib/nfs/xtab и удаляет из xtab несуществующие. exportfs выполняется при запуске демона nfsd с аргументом -r. Без параметров выдаёт список текущих экспортируемых файловых систем.

        Параметры exportfs:

        [клиент:имя-каталога] - добавить или удалить указанную файловую систему для указанного клиента)
        -v - выводить больше информации
        -r - переэкспортировать все каталоги (синхронизировать /etc/exports и /var/lib/nfs/xtab)
        -u - удалить из списка экспортируемых
        -a - добавить или удалить все файловые системы
        -o - опции через запятую (аналогичен опциям применяемым в /etc/exports; т.о. можно изменять опции уже смонтированных файловых систем)
        -i - не использовать /etc/exports при добавлении, только параметры текущей командной строки
        -f - сбросить список экспортируемых систем
        -s - отобразить текущие экпортируемые каталоги из файла /rtc/exportfs ( то же, что и запуск программы exportfs без параметров)
        
6. Стартуем сервисы nfs-server rpcbind,  и проверяем что стали доступны ресурсы для монтировани:
    
            [root@nfssrv ~]# systemctl start nfs-server rpcbind rpc-statd
            
            [root@nfssrv nfs_share]# exportfs -s         <----- ключ "s" программы exportfs отображает экпортируемые ресурсы
             
            /nfs_share  192.168.50.11(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
            /nfs_share/uploads  192.168.51.11(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)

            Команда exportfs показывает какие ресурс опубликованы, а также может выполнять реэкпорт директорий ( ручное перечитывание настроек экпорта, без необходимости презапуска всего сервера) при обновленни конфигурации файла /etc/exports. Ключи "а", "r". 
            
            Для отмены экспорта файловой системы введите:

            exportfs -u /имя-каталога  <-----   где имя-каталога - имя изменяемой файловой системы.
            
7. На клиентской машине (192.168.50.11), после установки пакета nfs-utils, проверяем доступеые сервисы для монтирования через nfs:         
        
        
        [root@nfscln mnt]# showmount -e 192.168.50.10   <----- сервер nfs
        Export list for 192.168.50.10:
        /nfs_share/uploads 192.168.51.11              <------| доступные ресурсы
        /nfs_share         192.168.50.11              <------|
       
 
 
##                                          2.2 Настройка NFS клиента


Прежде чем обратиться к файлу на удалённой файловой системе клиент (ОС клиента) должен смонтировать её и получить от сервера указатель на неё. Монтирование NFS может производиться с помощью команды mount или автоматически, прописа соответтвующую запись в файле /etc/fstab. 
На клиентах NFS никаких демонов запускать не нужно, функции клиента выполняет модуль ядра kernel/fs/nfs/nfs.ko, который используется при монтировании удаленной файловой системы. Экспортированные каталоги с сервера могут монтироваться на клиенте следующими способами:

 - вручную, с помощью команды mount
 - автоматически при загрузке, при монтировании файловых систем, описанных в /etc/fstab

 
        Автоматическое монтирование, с использованием systemd юнита
        
        [root@nfscln mnt]# cat /etc/fstab

        #
        # /etc/fstab
        # Created by anaconda on Sat May 12 18:50:26 2018
        #
        # Accessible filesystems, by reference, are maintained under '/dev/disk'
        # See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
        #
        /dev/mapper/VolGroup00-LogVol00 /                       xfs     defaults        0 0
        UUID=570897ca-e759-4c81-90cf-389da6eee4cc /boot                   xfs     defaults        0 0
        /dev/mapper/VolGroup00-LogVol01 swap                    swap    defaults        0 0
        192.168.50.10:/nfs_share  /mnt/nfs    nfs     rw,noatime,noauto,x-systemd.automount,noexec,nosuid,udp,vers=3  0 0
        

Для автоматического варианта запуска, создаём юнит файл с именем соответствующим точке монтирования, где "/" заменяется на "-" Например:
        
        [Unit]
        Description=mount NFS Share from Server
        Requires=network-online.service
        After=network-online.service


        [Mount]
        What=192.168.50.10:/nfs_share
        Where=/mnt/nfs      <------ Этот путь прописывается в имени файла mnt-nfs.mount
        Type=nfs

        [Install]
        WantedBy=default.target
        
        
        
       2.2.1 Опции монтирование каталога на клиентской машине

*   nosuid - Данная опция запрещает исполнять setuid программы из смонтированного каталога.

*   nodev (no device - не устройство) - Данная опция запрещает использовать в качестве устройств символьные и блочные специальные файлы.

*   lock (nolock) - Разрешает блокировку NFS (по умолчанию). nolock отключает блокировку NFS (не запускает демон lockd) и удобна при работе со старыми серверами, не поддерживающими блокировку NFS.

*   mounthost=имя - Имя хоста, на котором запущен демон монтирования NFS - mountd.

*   mountport=n - Порт, используемый демоном mountd.

*   port=n - порт, используемый для подключения к NFS серверу (по умолчанию 2049, если демон rpc.nfsd не зарегистрирован на RPC-сервере). Если n=0 (по 
умолчанию), то NFS посылает запрос к portmap на сервере, чтобы определить порт.

*   rsize=n (read block size - размер блока чтения) - Количество байтов, читаемых за один раз с NFS-сервера. Стандартно - 32768.

*   wsize=n (write block size - размер блока записи) - Количество байтов, записываемых за один раз на NFS-сервер. Стандартно - 32768.

*   tcp или udp - Для монтирования NFS использовать протокол TCP или UDP соответственно.

*   bg - При потери доступа к серверу, повторять попытки в фоновом режиме, чтобы не блокировать процесс загрузки системы.

*   fg - При потери доступа к серверу, повторять попытки в приоритетном режиме. Данный параметр может заблокировать процесс загрузки системы повторениями попыток монтирования. По этой причине параметр fg используется преимущественно при отладке.

        2.2.2 Опции, влияющие на кэширование атрибутов при монтировании NFS
        
*   ac (noac) (attrebute cache - кэширование атрибутов) - Разрешает кэширование атрибутов (по-умолчанию). Хотя опция noac замедляет работу сервера, она позволяет избежать устаревания атрибутов, когда несколько клиентов активно записывают информацию в общию иерархию.

*   acdirmax=n (attribute cache directory file maximum - кэширование атрибута максимум для файла каталога) - Максимальное количество секунд, которое NFS ожидает до обновления атрибутов каталога (по-умолчанию 60 сек.)

*   acdirmin=n (attribute cache directory file minimum - кэширование атрибута минимум для файла каталога) - Минимальное количество секунд, которое NFS ожидает до обновления атрибутов каталога (по-умолчанию 30 сек.)

*   acregmax=n (attribute cache regular file maximum - кэширование атрибута максимум для обычного файла) - Максимаьное количество секунд, которое NFS ожидает до обновления атрибутов обычного файла (по-умолчанию 60 сек.)

*   acregmin=n (attribute cache regular file minimum- кэширование атрибута минимум для обычного файла) - Минимальное количество секунд, которое NFS ожидает до обновления атрибутов обычного файла (по-умолчанию 3 сек.)

*   actimeo=n (attribute cache timeout - таймаут кэширования атрибутов) - Заменяет значения для всех вышуказаных опций. Если actimeo не задан, то вышеуказанные значения принимают значения по умолчанию.

        2.2.3 Опции обработки ошибок NFS

*   hard (soft) - выводит на консоль сообщение "server not responding" при достижении таймаута и продолжает попытки монтирования. При заданной опции soft - при таймауте сообщает вызвавшей операцию программе об ошибке ввода/вывода. (опцию soft советуют не использовать)

*   nointr (intr) (no interrupt - не прерывать) - Не разрешает сигналам прерывать файловые операции в жестко смонтированной иерархии каталогов при достижении большого таймаута. intr - разрешает прерывание.

*   retrans=n (retransmission value - значение повторной передачи) - После n малых таймаутов NFS генерирует большой таймаут (по-умолчанию 3). Большой таймаут прекращает выполнение операций или выводит на консоль сообщение "server not responding", в зависимости от указания опции hard/soft.

*   retry=n (retry value - значение повторно попытки) - Количество минут повторений службы NFS операций монтирования, прежде чем сдаться (по-умолчанию 10000).

*   timeo=n (timeout value - значение таймаута) - Количество десятых долей секунды ожидания службой NFS до повторной передачи в случае RPC или малого таймаута (по-умолчанию 7). Это значение увеличивается при каждом таймауте до максимального значения 60 секунд или до наступления большого таймаута. В случае занятой сети, медленного сервера или при прохождении запроса через несколько маршрутизаторов или шлюзов увеличение этого значения может повысить производительность.




