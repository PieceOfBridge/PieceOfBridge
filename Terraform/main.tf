provider "ocean" {
  tenant_id      = "****"
  tenant_slug    = "****"
  space_name     = "****"
  oidc_base      = "****"
  ocean_endpoint = "****"
  poll_interval  = "3s"
}

terraform {
  required_providers {
    ocean = {
      source  = "ocean/ocean"
      version = "0.3.2"
    }
  }
}

#------------- Создание VPC (Виртуальной Частной Сети) -------------#

# Модуль для создания виртуальной частной сети (VPC).
# Он предоставляет изолированную сетевую среду для виртуальных машин.
# Все ВМ, созданные в этом проекте, привязываются к этой VPC.
module "vpc" {
  source = "./modules/ocean_vpc"
  vms    = module.unmanaged_vm.vm

  # Параметры:
  # - vms: список виртуальных машин, которые должны быть связаны с VPC.
}

#------------- Ограничения хранения (Storage Limits) -------------#

# Модуль управления ограничениями хранилища для виртуальных машин.
# Позволяет устанавливать лимиты на использование дискового пространства для ВМ.
module "storage_limits" {
  source = "./modules/storage_limits"
}

#------------- Создание неуправляемых ВМ (Unmanaged Virtual Machines) -------------#

# Модуль для развертывания Unmanaged Virtual Machines.
module "unmanaged_vm" {
  source            = "./modules/unmanaged_vm"
  vpc_name          = module.vpc.vpc_name          # Имя VPC, в которой создаются ВМ.
  subnet_name       = module.vpc.subnet_name       # Имя подсети, в которой размещаются ВМ.
  external_ip_names = module.vpc.external_ip_names # Список внешних IP-адресов для ВМ.
  state             = "tool"                       # Состояние ВМ, указывает на их назначение.

  # Параметры:
  # - vpc_name: имя виртуальной сети (VPC), связанной с ВМ.
  # - subnet_name: имя подсети, в которой развернуты ВМ.
  # - external_ip_names: список внешних IP-адресов, привязанных к ВМ.
  # - state: статус ВМ (например, "tool").
}

#------------- Управление DNS-записями (DNS Management) -------------#

# Модуль для управления DNS-записями виртуальных машин.
# Создает внутренние и внешние DNS-записи, чтобы ВМ могли взаимодействовать друг с другом.
module "dns" {
  source   = "./modules/dns"
  vpc_name = module.vpc.vpc_name    # Имя VPC, к которой привязаны ВМ.
  vms      = module.unmanaged_vm.vm # Список ВМ, для которых создаются DNS-записи.
  ext_ip   = module.vpc.ext_ip      # Внешние IP-адреса, привязанные к ВМ.

  # Параметры:
  # - vpc_name: имя виртуальной сети (VPC), связанной с ВМ.
  # - vms: список ВМ, для которых необходимо создать DNS-записи.
  # - ext_ip: внешний IP-адрес, связанный с ВМ.
}
