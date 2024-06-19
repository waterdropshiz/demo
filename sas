### Подробное выполнение всех модулей на виртуальных машинах Debian 10

Для выполнения всех заданий из документа "SAD_Demoekzamen.pdf", создадим следующие виртуальные машины (VM), каждая из которых будет работать на Debian 10:

- **ISP**
- **HQ-R**
- **HQ-SRV**
- **BR-R**
- **BR-SRV**
- **HQ-CLI**
- **HQ-AD**

#### Настройка сетевой топологии и IP-адресация

| Виртуальная Машина | IP-адрес           | Дополнительная информация  |
|--------------------|--------------------|-----------------------------|
| CLI                |1.1.1.2/30 255.255.255.252
| ISP | 1.1.1.2/30 255.255.255.252       |                             |
        auto lo
        iface lo inet loopback
        auto ens3
        iface ens3 inet dhcp
        2.2.2.1/30
        3.3.3.1/30
        4.4.4.1/30

| HQ-R               | 172.16.0.0/26 255.255.255.192        |                             |
                       2.2.2.2/30
| HQ-SRV             | 172.16.0.0/26 255.255.255.192        |                             |
| BR-R               | 192.168.0.0/28 255.255.255.240        |                             |
                       3.3.3.2/30 255.255.255.252
| BR-SRV             | 192.168.0.0/28 255.255.255.240 |                             |
| HQ-CLI             | 172.16.0.0/26 255.255.255.192  |                             |
| HQ-AD              | 172.16.0.0/26 255.255.255.192  |

### Модуль 1: Выполнение работ по проектированию сетевой инфраструктуры

#### Задание 1: Базовая настройка всех устройств

##### Присвоение имен

1. **ISP**
   ```bash
   echo "ISP" | sudo tee /etc/hostname
   sudo hostnamectl set-hostname ISP
   ```

2. **HQ-R**
   ```bash
   echo "HQ-R" | sudo tee /etc/hostname
   sudo hostnamectl set-hostname HQ-R
   ```

3. **HQ-SRV**
   ```bash
   echo "HQ-SRV" | sudo tee /etc/hostname
   sudo hostnamectl set-hostname HQ-SRV
   ```

4. **BR-R**
   ```bash
   echo "BR-R" | sudo tee /etc/hostname
   sudo hostnamectl set-hostname BR-R
   ```

5. **BR-SRV**
   ```bash
   echo "BR-SRV" | sudo tee /etc/hostname
   sudo hostnamectl set-hostname BR-SRV
   ```

6. **HQ-CLI**
   ```bash
   echo "HQ-CLI" | sudo tee /etc/hostname
   sudo hostnamectl set-hostname HQ-CLI
   ```

7. **HQ-AD**
   ```bash
   echo "HQ-AD" | sudo tee /etc/hostname
   sudo hostnamectl set-hostname HQ-AD
   ```

##### Расчет и настройка IP-адресов IPv4 и IPv6

Настройка IP-адресов на каждой машине:

1. **ISP**
   ```bash
   sudo ip addr add 192.168.1.1/24 dev eth0
   sudo ip -6 addr add 2001:db8::1/64 dev eth0
   ```

2. **HQ-R**
   ```bash
   sudo ip addr add 192.168.1.2/24 dev eth0
   sudo ip -6 addr add 2001:db8::2/64 dev eth0
   ```

3. **HQ-SRV**
   ```bash
   sudo ip addr add 192.168.1.3/24 dev eth0
   sudo ip -6 addr add 2001:db8::3/64 dev eth0
   ```

4. **BR-R**
   ```bash
   sudo ip addr add 192.168.2.1/24 dev eth0
   sudo ip -6 addr add 2001:db8:1::1/64 dev eth0
   ```

5. **BR-SRV**
   ```bash
   sudo ip addr add 192.168.2.2/24 dev eth0
   sudo ip -6 addr add 2001:db8:1::2/64 dev eth0
   ```

6. **HQ-CLI**
   ```bash
   sudo ip addr add 192.168.1.4/24 dev eth0
   sudo ip -6 addr add 2001:db8::4/64 dev eth0
   ```

7. **HQ-AD**
   ```bash
   sudo ip addr add 192.168.1.5/24 dev eth0
   sudo ip -6 addr add 2001:db8::5/64 dev eth0
   ```

##### Настройка пула адресов

Для офиса BRANCH - до 16 адресов.
Для офиса HQ - до 64 адресов.

Пример конфигурации DHCP для HQ-R:
```bash
subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.10 192.168.1.50;
    option routers 192.168.1.1;
    option domain-name-servers 192.168.1.1;
}
subnet 192.168.2.0 netmask 255.255.255.0 {
    range 192.168.2.10 192.168.2.25;
    option routers 192.168.2.1;
    option domain-name-servers 192.168.2.1;
}
```

#### Задание 2: Настройка внутренней динамической маршрутизации с использованием FRR

1. **Установка FRR**
   Скачайте пакет FRR с локального носителя и установите:
   ```bash
   sudo dpkg -i frr_*.deb
   ```

2. **Настройка OSPF**
   На HQ-R и BR-R:
   ```bash
   sudo vtysh
   configure terminal
   router ospf
   network 192.168.1.0/24 area 0
   network 192.168.2.0/24 area 0
   exit
   write memory
   ```

#### Задание 3: Настройка автоматического распределения IP-адресов на роутере HQ-R

1. **Установка и настройка DHCP сервера**
   Установите isc-dhcp-server:
   ```bash
   sudo dpkg -i isc-dhcp-server_*.deb
   ```

2. **Конфигурация DHCP**
   - Редактируйте файл `/etc/dhcp/dhcpd.conf`:
     ```bash
     subnet 192.168.1.0 netmask 255.255.255.0 {
         range 192.168.1.10 192.168.1.50;
         option routers 192.168.1.1;
         option domain-name-servers 192.168.1.1;
     }
     host HQ-SRV {
         hardware ethernet 00:11:22:33:44:55;
         fixed-address 192.168.1.3;
     }
     ```

3. **Запуск DHCP сервера**
   ```bash
   sudo systemctl restart isc-dhcp-server
   ```

#### Задание 4: Настройка локальных учетных записей

1. **Создание учетных записей**
   - Для HQ-SRV:
     ```bash
     sudo useradd -m admin -p $(openssl passwd -1 'P@ssw0rd')
     sudo useradd -m branch_admin -p $(openssl passwd -1 'P@ssw0rd')
     sudo useradd -m network_admin -p $(openssl passwd -1 'P@ssw0rd')
     ```

#### Задание 5: Измерение пропускной способности сети

1. **Установка iperf3**
   - Установите iperf3 с локального носителя:
     ```bash
     sudo dpkg -i iperf3_*.deb
     ```

2. **Тестирование сети**
   - Запустите сервер и клиент iperf3:
     ```bash
     # На HQ-R (сервер)
     iperf3 -s
     
     # На ISP (клиент)
     iperf3 -c 192.168.1.2
     ```

#### Задание 6: Создание скриптов резервного копирования конфигурации

1. **Пример скрипта резервного копирования**
   ```bash
   #!/bin/bash
   BACKUP_DIR="/backup"
   mkdir -p $BACKUP_DIR
   scp user@HQ-R:/etc/network/interfaces $BACKUP_DIR/HQ-R_interfaces.bak
   scp user@BR-R:/etc/network/interfaces $BACKUP_DIR/BR-R_interfaces.bak
   ```

#### Задание 7: Настройка SSH

1. **Редактирование конфигурации SSH**
   - В файле `/etc/ssh/sshd_config`:
     ```bash
     Port 2222
     AllowUsers admin
     ```

2. **Перезапуск службы SSH**
   ```bash
   sudo systemctl restart ssh
   ```

#### Задание 8: Настройка контроля доступа по SSH

1. **Редактирование конфигурации SSH**
   - В файле `/etc/ssh/sshd_config`:
     ```bash
     Match User admin
         AllowUsers admin
     ```

2. **Перезапуск службы SSH**
   ```bash
   sudo systemctl restart ssh
   ```

### М

одуль 2: Системное администрирование и автоматизация

#### Задание 1: Настройка служб DNS

1. **Установка BIND9**
   - Установите bind9 с локального носителя:
     ```bash
     sudo dpkg -i bind9_*.deb
     ```

2. **Настройка зон**
   - В файле `/etc/bind/named.conf.local`:
     ```bash
     zone "hq.work" {
         type master;
         file "/etc/bind/db.hq.work";
     };
     zone "branch.work" {
         type master;
         file "/etc/bind/db.branch.work";
     };
     ```

3. **Создание файла зоны для HQ**
   - В файле `/etc/bind/db.hq.work`:
     ```bash
     $TTL 604800
     @   IN  SOA hq.work. root.hq.work. (
                  2        ; Serial
                  604800   ; Refresh
                  86400    ; Retry
                  2419200  ; Expire
                  604800 ) ; Negative Cache TTL
     @   IN  NS  hq.work.
     @   IN  A   192.168.1.3
     ```

4. **Перезапуск службы BIND**
   ```bash
   sudo systemctl restart bind9
   ```

#### Задание 2: Настройка служб на сервере HQ-SRV

1. **Установка и настройка Apache**
   - Установите apache2 с локального носителя:
     ```bash
     sudo dpkg -i apache2_*.deb
     ```

2. **Настройка виртуального хоста**
   - В файле `/etc/apache2/sites-available/hq.work.conf`:
     ```bash
     <VirtualHost *:80>
         ServerAdmin webmaster@hq.work
         ServerName hq.work
         DocumentRoot /var/www/hq.work
         ErrorLog ${APACHE_LOG_DIR}/error.log
         CustomLog ${APACHE_LOG_DIR}/access.log combined
     </VirtualHost>
     ```

3. **Активировать виртуальный хост и перезапуск Apache**
   ```bash
   sudo a2ensite hq.work
   sudo systemctl restart apache2
   ```

#### Задание 3: Настройка сетевого администрирования с использованием Ansible

1. **Установка Ansible**
   - Установите ansible с локального носителя:
     ```bash
     sudo dpkg -i ansible_*.deb
     ```

2. **Создание файла инвентаря**
   - В файле `/etc/ansible/hosts`:
     ```ini
     [hq]
     hq.work ansible_host=192.168.1.3 ansible_user=admin
     [branch]
     branch.work ansible_host=192.168.2.2 ansible_user=admin
     ```

3. **Пример простого плейбука**
   - В файле `site.yml`:
     ```yaml
     - hosts: all
       tasks:
         - name: Ensure apache is at the latest version
           apt:
             name: apache2
             state: latest
     ```

4. **Запуск плейбука**
   ```bash
   ansible-playbook site.yml
   ```

### Модуль 3: Управление сетью и безопасность

#### Задание 1: Настройка и управление правилами firewall на HQ-R

1. **Установка и настройка UFW**
   - Установите ufw с локального носителя:
     ```bash
     sudo dpkg -i ufw_*.deb
     ```

2. **Настройка правил UFW**
   ```bash
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 2222/tcp
   sudo ufw enable
   ```

#### Задание 2: Настройка мониторинга сети на HQ-SRV

1. **Установка Nagios**
   - Установите nagios с локального носителя:
     ```bash
     sudo dpkg -i nagios_*.deb
     ```

2. **Настройка конфигурации Nagios**
   - Добавьте хосты в `/usr/local/nagios/etc/servers/hq.cfg`:
     ```cfg
     define host {
       use             linux-server
       host_name       hq-srv
       alias           HQ Server
       address         192.168.1.3
     }
     ```

3. **Перезапуск Nagios**
   ```bash
   sudo systemctl restart nagios
   ```

#### Задание 3: Настройка VPN между офисами

1. **Установка OpenVPN**
   - Установите openvpn с локального носителя:
     ```bash
     sudo dpkg -i openvpn_*.deb
     ```

2. **Создание серверной конфигурации**
   - В файле `/etc/openvpn/server.conf`:
     ```conf
     port 1194
     proto udp
     dev tun
     ca ca.crt
     cert server.crt
     key server.key
     dh dh.pem
     server 10.8.0.0 255.255.255.0
     ifconfig-pool-persist ipp.txt
     push "redirect-gateway def1 bypass-dhcp"
     push "dhcp-option DNS 192.168.1.1"
     ```

3. **Запуск OpenVPN сервера**
   ```bash
   sudo systemctl start openvpn@server
   ```

### Заключение
Следуя этим шагам, вы сможете выполнить все задания из первого до третьего модуля. Убедитесь, что все пакеты и зависимости загружены на локальный носитель перед началом выполнения заданий. Если возникнут дополнительные вопросы, можете задать их для уточнения деталей.
