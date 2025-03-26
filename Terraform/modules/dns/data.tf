# Получение списка доступных вычислительных сайтов в облачной инфраструктуре
data "ocean_compute_sites" "default_site" {}

# Получение информации о пространстве ресурсов
# Пространство ресурсов — это логическая область, в которой создаются и управляются ресурсы
data "ocean_resourcemanager_space" "space" {
  name = var.space_name
}

# Локальная переменная для хранения списка имен виртуальных машин (ВМ)
locals {
  vm_info = flatten([
    # Перебираем группы ВМ и извлекаем их имена в единый список
    for vm_group, vms in var.vms : [
      for vm_name, vm_data in vms : vm_name
    ]
  ])
}

# Получение информации о unmanaged vm
# Этот блок данных позволяет извлекать сведения о ВМ по их именам и сайту размещения
data "ocean_compute_unmanagedvm" "vm_info" {
  # Определяем количество запросов, основываясь на количестве ВМ в локальной переменной vm_info
  count = length(local.vm_info)

  # Имя каждой ВМ определяется из списка vm_info
  name = local.vm_info[count.index]
  # Определяем сайт, где размещена ВМ, используя ID сайта по умолчанию
  site_name = join(",", [for i in data.ocean_compute_sites.default_site.sites : i.name if i.id == var.default_site_id])
}

# Получение информации о зоне DNS-хостинга
# Этот блок данных используется для работы с существующей DNS-зоной
data "ocean_dns_hosting_zone" "default_zone" {
  name = var.zone_name_default
}

# Получение информации о внешних IP-адресах, связанных с ВМ
data "ocean_compute_external_ip" "external_ip" {
  # Используем цикл for_each для обработки всех внешних IP-адресов, связанных с ВМ
  for_each = { for idx, ext_int in var.ext_ip : "${ext_int.vm_group}-${ext_int.vm_name}-${idx}" => ext_int }

  # Имя внешнего IP-адреса
  name = each.value.name
  # Определяем сайт, где расположен данный IP-адрес, используя ID сайта по умолчанию
  site_name = join(",", [for i in data.ocean_compute_sites.default_site.sites : i.name if i.id == var.default_site_id])
}
