# Переменная для хранения данных о виртуальных машинах (VM)
# Представляет собой карту (map), где:
# - Ключ (первый уровень) — группа виртуальных машин (например, "tool", "test").
# - Ключ (второй уровень) — имя виртуальной машины внутри группы.
# - Значение — объект с параметрами виртуальной машины.
variable "vm" {
  description = "Список виртуальных машин с их характеристиками"
  type = map(map(object({
    # Идентификатор сайта, на котором будет развернута ВМ
    site_id = string
    # Уникальное имя ВМ
    name = string
    # Описание виртуальной машины
    description = string
    # Состояние питания ВМ (например, "running" или "stopped")
    power_status = string

    # Шаблон образа для развертывания ВМ
    template = object({
      name        = string # Название шаблона ВМ
      description = string # Описание шаблона ВМ
    })

    # Настройки внешнего IP-адреса
    external_ip = object({
      external_ip_state    = bool   # Включен ли внешний IP-адрес
      count_of_external_ip = number # Количество внешних IP-адресов
      use_as_egress        = bool   # Используется ли как egress-адрес
    })

    # Характеристики оборудования ВМ
    equipment_spec = object({
      equipment_type_name        = string # Тип оборудования (например, "intel")
      cpu                        = number # Количество ядер CPU
      cpu_reservation_percentage = number # Процент зарезервированного CPU
      ram                        = number # Объем оперативной памяти (ГБ)
      storage_policy_name        = string # Название политики хранения
      storage_size               = string # Размер хранилища (например, "default")
      storage_size_mb            = number # Размер хранилища в мегабайтах
    })

    # Настройки DNS для ВМ
    dns = object({
      state            = bool         # Включен ли DNS-запись
      external_records = list(string) # Список внешних DNS-записей
      internal_records = list(string) # Список внутренних DNS-записей
    })
  })))

  default = {
    # Группа виртуальных машин "tool"
    tool = {
      # Виртуальная машина "passm" для хостинга Vaultwarden
      passm = {
        site_id      = "***"
        name         = "passm"
        description  = "для vaultwarden"
        power_status = "running"

        template = {
          name        = "oel-9-cloud-template_1.2.3"
          description = "Oracle Linux 9"
        }

        external_ip = {
          external_ip_state    = true
          count_of_external_ip = 1
          use_as_egress        = true
        }

        equipment_spec = {
          equipment_type_name        = "intel"
          cpu                        = 2
          cpu_reservation_percentage = 5
          ram                        = 4
          storage_policy_name        = "Silver"
          storage_size               = "default"
          storage_size_mb            = 0
        }

        dns = {
          state            = true
          external_records = ["passman"]
          internal_records = ["passman"]
        }
      },

      # Виртуальная машина "runner" для работы GitLab Runner
      runner = {
        site_id      = "***"
        name         = "runner"
        description  = "для gitlab runner"
        power_status = "running"

        template = {
          name        = "oel-9-cloud-template_1.2.3"
          description = "Oracle Linux 9"
        }

        external_ip = {
          external_ip_state    = true
          count_of_external_ip = 1
          use_as_egress        = true
        }

        equipment_spec = {
          equipment_type_name        = "intel"
          cpu                        = 2
          cpu_reservation_percentage = 5
          ram                        = 4
          storage_policy_name        = "Silver"
          storage_size               = "default"
          storage_size_mb            = 0
        }

        dns = {
          state            = true
          external_records = ["gitrun"]
          internal_records = ["gitrun"]
        }
      }
    },
    test = {
      # Группа "test" пока не содержит виртуальных машин
    }
  }
}

# ------------- Прочие переменные ----------------------------------------

# Имя пространства ресурсов (Resource Manager Space)
# Определяет логическое пространство, в котором будут развернуты виртуальные машины
variable "space_name" {
  description = "Имя пространства ресурсов"
  default     = "***"
  type        = string
}

# Идентификатор основного сайта, в котором будут развернуты ресурсы
# Используется для фильтрации ресурсов по сайту развертывания
variable "default_site_id" {
  description = "Идентификатор основного сайта развертывания"
  default     = "***"
  type        = string
}

# Список имен виртуальных частных сетей (VPC), используемых в модуле
# Используется в data-блоках для получения информации о VPC и ее параметрах
variable "vpc_name" {
  description = "Список имен VPC, которые используются в развертывании"
}

# Список имен подсетей, которые создаются в VPC
# Используется в data-блоках для получения информации о подсетях
variable "subnet_name" {
  description = "Список имен подсетей, к которым будут подключены виртуальные машины"
}

# Список имен внешних IP-адресов, используемых виртуальными машинами
# Используется в модуле для привязки внешних IP к соответствующим ВМ
variable "external_ip_names" {
  description = "Список имен внешних IP-адресов, используемых виртуальными машинами"
}

# Переменная состояния, используется для фильтрации данных о подсетях
# Может содержать значения, определяющие нужное состояние (например, "active", "default")
variable "state" {
  description = "Фильтр состояния, используемый при выборе подсетей"
}
