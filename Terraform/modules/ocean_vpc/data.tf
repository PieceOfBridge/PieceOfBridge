# Получение информации о виртуальной частной сети (VPC) с именем, заканчивающимся на "default"
# Используется для выбора основной (дефолтной) сети среди доступных VPC
data "ocean_compute_vpc" "vpc_default" {
  # Фильтруем список VPC, выбирая только те, у которых имя заканчивается на "default"
  name = join(", ", [for item in var.vpc : item.name if can(regex(".*default$", item.name))])
  # Определяем пространство ресурсов, к которому принадлежит VPC
  space = data.ocean_resourcemanager_space.space.name
  # Указываем зависимость от ресурса VPC, чтобы обеспечить корректный порядок выполнения
  depends_on = [ocean_compute_vpc.dso-scope]
}

# Получение списка всех доступных вычислительных сайтов
# Этот источник данных используется для привязки ресурсов к определенным сайтам в облаке
data "ocean_compute_sites" "default_site" {}

# Получение информации о пространстве ресурсов (Resource Manager Space)
# Пространство ресурсов используется для логического объединения облачных ресурсов
data "ocean_resourcemanager_space" "space" {
  name = var.space_name
}

# Получение информации о внешних IP-адресах, связанных с виртуальными машинами
data "ocean_compute_external_ip" "external_ip" {
  # Используем for_each для динамического создания записей для всех внешних IP-адресов
  for_each = { for idx, ext_int in local.EXT_INTERFACE : "${ext_int.vm_group}-${ext_int.vm_name}-${idx}" => ext_int }

  # Имя внешнего IP-адреса, полученное из локальной переменной EXT_INTERFACE
  name = each.value.name
  # Определяем сайт, где расположен данный IP-адрес, используя ID сайта по умолчанию
  site_name = join(",", [for i in data.ocean_compute_sites.default_site.sites : i.name if i.id == var.default_site_id])
}
