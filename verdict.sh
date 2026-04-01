#!/usr/bin/env bash

RESULT_FILE="/var/log/ipmi-sim/verdict.txt"

mkdir -p "$(dirname "${RESULT_FILE}")"

echo "========================="
echo "  Завершение упражнения"
echo "========================="
echo
echo "Какую основную проблему вы обнаружили в системе?"
echo
echo "  1 - Перегрев CPU"
echo "  2 - Проблема с напряжением питания"
echo "  3 - Отказ вентилятора"
echo "  4 - Другая проблема"
echo

CHOICE=""

while true; do
  read -r -p "Введите номер варианта (1-4): " CHOICE
  case "${CHOICE}" in
  1 | 2 | 3 | 4)
    break
    ;;
  *)
    echo "Неверный ввод. Введите число от 1 до 4."
    ;;
  esac
done

cat >"${RESULT_FILE}" <<EOF
choice=${CHOICE}
EOF

echo
echo "Ваш ответ сохранён"
echo
echo "Выполняется анализ..."
./analyze.sh
echo
echo "Сессия завершена. Можете выйти из контейнера (exit)."
