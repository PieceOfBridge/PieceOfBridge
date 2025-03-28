# Terraform Модуль: Управление DNS-записями

## Описание
Этот модуль Terraform предназначен для управления DNS-записями и зонами хостинга в облачной инфраструктуре. Он позволяет создавать и управлять как внутренними, так и внешними DNS-записями, используя предоставленные переменные.

## Возможности
- **Создание DNS-зоны**: Определение и настройка зоны хостинга.
- **Управление внутренними и внешними DNS-записями**: Автоматическое создание записей для виртуальных машин.
- **Гибкая настройка параметров DNS**: Поддержка TTL, типа записи (A, CNAME и др.).
- **Интеграция с VPC и виртуальными машинами**: Автоматическое привязка IP-адресов виртуальных машин к DNS-записям.

## Структура каталога
```
├── data.tf          # Определение источников данных
├── records.tf       # Определение DNS-записей
├── hosting_zone.tf  # Определение зоны хостинга
├── variable.tf      # Переменные модуля
├── outputs.tf       # Выходные переменные
├── README.md        # Документация модуля
```

## Предварительные требования
- **Terraform** (`>=1.0.0`)
- **Настроенные учетные данные облачного провайдера**
- **Доступ к управлению DNS-записями**

## Использование
### 1. Инициализация Terraform
```sh
terraform init
```

### 2. Проверка конфигурации
```sh
terraform validate
```

### 3. Планирование развертывания
```sh
terraform plan
```

### 4. Применение изменений
```sh
terraform apply -auto-approve
```

### 5. Удаление ресурсов (при необходимости)
```sh
terraform destroy -auto-approve
```

## Переменные
| Имя                | Описание                                       | Значение по умолчанию |
|---------------------|----------------------------------------------|------------------|
| `ttl_default`      | Время жизни DNS-записи (TTL)                 | `3600` |
| `zone_name_default`| Имя зоны хостинга DNS                        | `dsoid.mts-corp.ru.` |
| `type_A`           | Тип DNS-записи                               | `A` |
| `space_name`       | Название пространства ресурсов               | `identity-dso-scope` |
| `default_site_id`  | Идентификатор основного сайта                | `f9fc337a-a53e-46c0-bb69-8a1a1d66dbe2` |
| `vpc_name`         | Имя виртуальной частной сети (VPC)           | - |
| `vms`             | Конфигурация виртуальных машин                | - |
| `ext_ip`           | Список внешних IP-адресов                     | - |

## Выходные переменные
| Имя           | Описание                                      |
|--------------|--------------------------------------------|
| `dns_records` | Список созданных DNS-записей              |
| `hosting_zone`| Информация о зоне хостинга DNS           |

