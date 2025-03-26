
# Локальная переменная для хранения списка DNS-записей
locals {
  dns_records = flatten([
    # Перебираем группы виртуальных машин
    for vm_group, vms in var.vms : [
      # Перебираем виртуальные машины в группе
      for vm_name, vm_data in vms : concat(
        # Если включена внутренняя DNS-запись, создаем соответствующую запись
        vm_data.dns.state ? [
          for idx, int_record in vm_data.dns.internal_records :
          {
            # Если внутренняя запись указана явно, используем ее, иначе генерируем имя
            name = vm_data.dns.internal_records != "" ? int_record : "${vm_name}-internal"
            # Используем зону по умолчанию
            zone = var.zone_name_default
            # Тип записи (например, A-запись)
            type = var.type_A
            # Время жизни записи (TTL)
            ttl = var.ttl_default
            # IP-адрес виртуальной машины для внутренней DNS-записи
            data = join(",", [for i in data.ocean_compute_unmanagedvm.vm_info : i.network_interface.ip_address if i.name == "${vm_name}"])
            # Описание DNS-записи
            description = "Внутренние DNS-записи для VM ${vm_name}"
          }
        ] : [],

        # Если у виртуальной машины включен внешний IP, создаем соответствующую DNS-запись
        vm_data.external_ip.external_ip_state ? [
          for idx, ext_record in vm_data.dns.external_records :
          {
            # Если внешняя запись указана явно, используем ее, иначе генерируем имя
            name = vm_data.dns.external_records != "" ? ext_record : ["${vm_name}-external"]
            # Используем зону по умолчанию
            zone = var.zone_name_default
            # Тип записи (например, A-запись)
            type = var.type_A
            # Время жизни записи (TTL)
            ttl = var.ttl_default
            # IP-адрес виртуальной машины для внешней DNS-записи
            data = join(",", [for ext_ip in data.ocean_compute_external_ip.external_ip[*].address : ext_ip if ext_ip == "${vm_name}-${idx + 1}"])
            # Описание DNS-записи
            description = "Внешние DNS-записи для VM ${vm_name}"
          } if vm_data.external_ip.external_ip_state
        ] : []
      )
    ]
  ])
}

# Ресурс для создания DNS-записей в облаке
resource "ocean_dns_record" "dns_record_default" {
  # Используем локальную переменную с DNS-записями для создания записей в DNS-хостинге
  for_each = { for idx, record in local.dns_records : "${record.zone}-${record.name}" => record }

  # Имя DNS-записи
  name = each.value.name
  # Зона, в которой создается запись
  zone = each.value.zone
  # Тип записи (например, A-запись)
  type = each.value.type
  # Время жизни записи (TTL)
  ttl = each.value.ttl
  # Данные DNS-записи (например, IP-адрес)
  data = [each.value.data]
  # Описание DNS-записи
  description = each.value.description
}
