# IPMI Simulator (Docker)

OpenIPMI 2.0.25 ipmi_sim в контейнере с динамической генерацией значений сенсоров.

## Файлы

| Файл           | Описание                                              |
|----------------|-------------------------------------------------------|
| `Dockerfile`   | Сборка образа: OpenIPMI 2.0.25, SDR, конфиги, скрипты |
| `lan.conf`     | Сетевой конфиг ipmi_sim (порт 623, user ADMIN/ADMIN)  |
| `sim.sdrs`     | SDR-описания сенсоров (12 шт.)                        |
| `sim.emu`      | Конфигурация BMC и сенсоров с poll file для динамики   |
| `dynamic.sh`   | Скрипт генерации псевдослучайных значений сенсоров    |
| `entrypoint.sh`| Точка входа: запуск dynamic.sh + ipmi_sim             |

## Сенсоры

| #  | Имя           | Тип         | Диапазон динамики       |
|----|---------------|-------------|-------------------------|
| 1  | CPU Temp      | Temperature | 30..70 °C               |
| 2  | System Temp   | Temperature | 25..55 °C               |
| 3  | Periph Temp   | Temperature | 20..50 °C               |
| 4  | FAN1          | Fan         | 2500..3500 RPM          |
| 5  | FAN2          | Fan         | 2700..3700 RPM          |
| 6  | 12V           | Voltage     | 11.5..12.5 V            |
| 7  | 5V            | Voltage     | 4.8..5.2 V              |
| 8  | 3.3V          | Voltage     | 3.2..3.4 V              |
| 9  | Vcore         | Voltage     | 1.20..1.40 V            |
| 10 | PSU Status    | Discrete    | статичный               |
| 11 | Chassis Intru | Discrete    | статичный               |

## Сборка и запуск

```bash
docker build -t my-ipmi-sim .

docker run -d --name ipmi-sim \
  --network zbx-lab_zbx-net \
  -p 623:623/udp \
  my-ipmi-sim
```

Интервал обновления значений (по умолчанию 5 секунд):

```bash
docker run -d --name ipmi-sim \
  --network zbx-lab_zbx-net \
  -p 623:623/udp \
  -e DYNAMIC_INTERVAL=10 \
  my-ipmi-sim
```

## Проверка

```bash
ipmitool -I lanplus -H 127.0.0.1 -p 623 -U ADMIN -P ADMIN sensor
```

## Подключение к Zabbix

1. Убедись, что `StartIPMIPollers=3` в конфиге Zabbix-сервера
   (env: `ZBX_IPMIPOLLERS=3`)
2. Узнай IP контейнера в сети Zabbix:
   ```bash
   docker inspect ipmi-sim | jq '.[0].NetworkSettings.Networks."zbx-lab_zbx-net".IPAddress'
   ```
3. В Zabbix: Configuration → Hosts → Create host
   - IPMI interface: IP из шага 2, Port 623
   - IPMI auth: MD5, Privilege: Admin
   - Username: ADMIN, Password: ADMIN
4. Привяжи шаблон IPMI (Template IPMI)
