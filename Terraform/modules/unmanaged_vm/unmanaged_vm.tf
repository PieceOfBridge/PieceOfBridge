# Локальная переменная для нормализации данных о виртуальных машинах (VMs)
locals {
  vm_flat = flatten([
    # Перебираем группы виртуальных машин
    for group_name, group_data in var.vm : [
      # Перебираем виртуальные машины внутри группы
      for vm_name, vm_data in group_data : {
        group_name                           = group_name                                        # Название группы ВМ
        vm_name                              = vm_name                                           # Имя виртуальной машины
        site_id                              = vm_data.site_id                                   # Идентификатор сайта размещения ВМ
        name                                 = vm_data.name                                      # Имя ВМ
        description                          = vm_data.description                               # Описание ВМ
        power_status                         = vm_data.power_status                              # Текущий статус питания (включена/выключена)
        template_name                        = vm_data.template.name                             # Имя шаблона ВМ
        template_description                 = vm_data.template.description                      # Описание шаблона ВМ
        external_ip_state                    = vm_data.external_ip.external_ip_state             # Включен ли внешний IP
        external_ip_count_of_external_ip     = vm_data.external_ip.count_of_external_ip          # Количество внешних IP
        external_ip_use_as_egress            = vm_data.external_ip.use_as_egress                 # Используется ли как egress IP
        equipment_type_name                  = vm_data.equipment_spec.equipment_type_name        # Тип оборудования
        equipment_cpu                        = vm_data.equipment_spec.cpu                        # Количество CPU
        equipment_ram                        = vm_data.equipment_spec.ram                        # Размер RAM
        equipment_cpu_reservation_percentage = vm_data.equipment_spec.cpu_reservation_percentage # Резерв процессора
        equipment_storage_policy_name        = vm_data.equipment_spec.storage_policy_name        # Политика хранения
        equipment_storage_size               = vm_data.equipment_spec.storage_size               # Размер хранилища
        equipment_storage_size_mb            = vm_data.equipment_spec.storage_size_mb            # Размер хранилища в MB
      }
    ]
  ])

  # Создание уникального идентификатора для каждой ВМ
  vm_map = { for idx, vm in local.vm_flat : "${vm.group_name}-${vm.vm_name}-${idx}" => vm }
}

# Создание ресурса для неуправляемых виртуальных машин
resource "ocean_compute_unmanagedvm" "compute_default" {
  for_each = local.vm_map

  # Имя виртуальной машины
  name = each.value.vm_name

  # Пространство ресурсов, в котором создается ВМ
  space = data.ocean_resourcemanager_space.space.name

  # Определяем сайт размещения виртуальной машины
  site_name = join(",", [for i in data.ocean_compute_sites.default_site.sites : i.name if i.id == "${each.value.site_id}"])

  # Описание виртуальной машины
  description = "Виртуальная машина ${each.value.vm_name} в пространстве ${data.ocean_resourcemanager_space.space.name} ${each.value.description}"

  # Выбор шаблона ВМ, если его имя и описание совпадают с переданными параметрами
  template = join(",", [
    for i in flatten(data.ocean_compute_unmanaged_equipment.unmanaged_vm.equipment[*].template_groups[*].templates[*]) :
    i.name if i.name == each.value.template_name && i.description == each.value.template_description
  ])

  # Определяем тип оборудования, к которому привязана ВМ
  equipment_type_name = join(",", [
    for i in data.ocean_compute_unmanaged_equipment.unmanaged_vm.equipment[*].name :
    i if i == "${each.value.equipment_type_name}"
  ])

  # Определяем параметры оборудования ВМ (CPU, RAM и резервирование CPU)
  equipment_spec = {
    cpu                        = each.value.equipment_cpu
    ram                        = each.value.equipment_ram
    cpu_reservation_percentage = each.value.equipment_cpu_reservation_percentage
  }

  # Определяем параметры дискового хранения
  disks = [
    {
      # Если размер хранилища указан как "default", берем размер используемого хранилища из шаблона ВМ
      size_mb = each.value.equipment_storage_size == "default" ? join(",", [
        for i in flatten(data.ocean_compute_unmanaged_equipment.unmanaged_vm.equipment[*].template_groups[*].templates[*]) :
        i.storage_used_mb if i.name == each.value.template_name && i.description == each.value.template_description
      ]) : each.value.equipment_storage_size_mb

      # Определяем используемую политику хранения
      storage_policy_name = join(",", [
        for i in data.ocean_compute_storage_policies.enabled_storage_policies.policies[*].name :
        i if i == each.value.equipment_storage_policy_name
      ])
    }
  ]

  # Определяем параметры сетевого интерфейса
  network_interface = {
    # Определяем подсеть для ВМ: ищем подсеть, соответствующую имени группы, иначе используем подсеть по умолчанию
    subnet_name = [
      for subnet_name in data.ocean_compute_subnet.subnet_default_vpc[*].name :
      can(regex(".*-${each.value.group_name}$", subnet_name)) ? subnet_name :
      [for subnet_name in data.ocean_compute_subnet.subnet_default_vpc[*].name : subnet_name if can(regex(".*-default$", subnet_name))]
    ]

    # Определяем доступ к внешнему интернету через egress IP
    access_configs = [
      {
        use_as_egress = each.value.external_ip_use_as_egress
        external_ip_name = each.value.external_ip_use_as_egress == true ? [
          for item in var.external_ip_names :
          can(regex(".*-${each.value.vm_name}.*", item)) ? item : ""
        ] : ""
      }
    ]
  }

  # Применяем политику хранения данных
  storage_policy_name = join(",", [
    for i in data.ocean_compute_storage_policies.enabled_storage_policies.policies[*].name :
    i if i == each.value.equipment_storage_policy_name
  ])

  # Определяем статус питания виртуальной машины
  power_status = each.value.power_status
}
