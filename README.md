# IPMI Simulator
Простой IPMI симулятор на основе [ipmi_sim](https://github.com/cminyard/openipmi), собранный в контейнер на базе Alpine.
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

Значения данных сенсоров динамически изменяются. 
## Сборка и запуск

Образ контейнера можно загрузить с Docker Hub:
```
docker pull nissanissa/ipmi-sim:latest
```

Либо собрать самостоятельно из исходников в репозитории:

```bash
docker build -t ipmi-sim .
```

Запустить контейнер необходимо следующей командой:
```
docker run -d --name ipmi-sim \
  -p 623:623/udp \
  ipmi-sim
```
## Проверка

```bash
ipmitool -I lanplus -H 127.0.0.1 -p 623 -U ADMIN -P ADMIN sdr elist -C 3
```

Примерный вывод, который должен быть получен:
```
CPU Temp         | 01h | ok  |  3.1 | 49 degrees C
System Temp      | 02h | ok  |  7.1 | 37 degrees C
Periph Temp      | 03h | ok  |  7.1 | 32 degrees C
FAN1             | 04h | ok  | 29.1 | 2500 RPM
FAN2             | 05h | ok  | 29.2 | 2700 RPM
12V              | 06h | ok  | 10.1 | 11,50 Volts
5.5V             | 07h | ok  | 10.1 | 4,80 Volts
3.3V             | 08h | ok  | 10.1 | 3,30 Volts
Vcore            | 09h | ok  |  3.1 | 1,39 Volts
PSU Status       | 0Ah | ok  | 10.1 | Presence detected
Chassis Intru    | 0Bh | ok  | 23.1 | General Chassis intrusion
```

## Изменение данных IPMI или правил динамического изменения

Чтобы изменить данные симулятора (общая информация, пользователи, сенсоры), необходимо изменить содержимое файлов `sim.emu`, `sim.sdrs` и `lan.conf` в корне репозитория согласно синтаксису `ipmi_sim`. Компилировать из `sim.sdrs` не нужно, это делается при сборке образа контейнера.

В `sim.emu` при добавлении сенсора можно определить подгрузку данных из определенного файла. 

Пример:
```
sensor_add 0x20 0 1 0x01 0x01 poll 1000 file "/tmp/ipmi/cpu_temp.ipm"
```

С помощью записи в файл конкретных значений можно сымитировать динамическое изменение данных сенсора. В данном симуляторе это делается с помощью скрипта `dynamic.sh`. Если необходимо внести изменения в логику динамического изменения данных, нужно написать скрипт, который будет вносить изменения в файлы, указанные в `sim.emu` и собрать образ контейнера.
