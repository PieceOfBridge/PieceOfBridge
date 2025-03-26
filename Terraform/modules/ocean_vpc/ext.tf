# Локальная переменная для хранения списка внешних IP-адресов виртуальных машин
locals {
  EXT_INTERFACE = flatten([
    # Перебираем все группы виртуальных машин
    for vm_group, vms in var.vms : [
      # Перебираем все виртуальные машины в группе
      for vms_name, vms_data in vms : [
        # Генерируем записи для каждого внешнего IP, который привязан к ВМ
        for index in range(vms_data.external_ip.count_of_external_ip) : {
          # Генерируем уникальное имя для каждого внешнего IP, используя имя ВМ и индекс
          name     = "${vms_name}-${index + 1}"
          vm_name  = vms_name
          vm_group = vm_group
        }
        # Добавляем в список только те ВМ, у которых включено внешнее IP и задано количество IP-адресов
        if vms_data.external_ip.external_ip_state && vms_data.external_ip.count_of_external_ip > 0
      ]
    ]
  ])
}

# Ресурс для создания внешних IP-адресов
resource "ocean_compute_external_ip" "default_ext_ip" {
  # Используем локальную переменную EXT_INTERFACE для динамического создания IP-адресов
  for_each = { for idx, ext_int in local.EXT_INTERFACE : "${ext_int.vm_group}-${ext_int.vm_name}-${idx}" => ext_int }

  # Имя внешнего IP-адреса
  name = each.value.name
  # Определяем сайт, где создается IP-адрес, используя ID сайта по умолчанию
  site_name = join(",", [for i in data.ocean_compute_sites.default_site.sites : i.name if i.id == var.default_site_id])
  # Привязываем IP-адрес к виртуальной частной сети (VPC)
  vpc_name = data.ocean_compute_vpc.vpc_default.name
  # Описание IP-адреса, указывающее, какой ВМ он принадлежит
  description = "Публичный IP адрес ${each.value.name} принадлежащий сети ${data.ocean_compute_vpc.vpc_default.name}. Назначен для VM ${each.value.vm_name} принадлежащей к группе ${each.value.vm_group}"
  # Устанавливаем зависимость от создания VPC, чтобы избежать ошибок при развертывании
  depends_on = [ocean_compute_vpc.dso-scope]
}
