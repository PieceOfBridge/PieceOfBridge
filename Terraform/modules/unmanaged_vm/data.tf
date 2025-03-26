# Получение списка доступных вычислительных сайтов
# Используется для определения, на каких сайтах могут быть развернуты ресурсы
data "ocean_compute_sites" "default_site" {}

# Получение списка доступных политик хранения данных (Storage Policies)
# Определяет доступные уровни хранения для данного пространства ресурсов
data "ocean_compute_storage_policies" "enabled_storage_policies" {
  # Указываем пространство ресурсов, к которому относятся политики хранения
  space = data.ocean_resourcemanager_space.space.name

  # Фильтруем политики хранения по сайту, используя идентификатор основного сайта
  site_name = join(",", [for i in data.ocean_compute_sites.default_site.sites : i.name if i.id == var.default_site_id])

  # Обеспечиваем выполнение получения данных только после загрузки данных о пространстве и сайтах
  depends_on = [data.ocean_resourcemanager_space.space, data.ocean_compute_sites.default_site]
}

# Получение информации о пространстве ресурсов (Resource Manager Space)
# Пространство ресурсов используется для логического объединения облачных ресурсов
data "ocean_resourcemanager_space" "space" {
  name = var.space_name
}

# Получение списка неуправляемого оборудования (виртуальные машины без активного управления)
# Позволяет работать с существующими виртуальными машинами, развернутыми в данном пространстве ресурсов
data "ocean_compute_unmanaged_equipment" "unmanaged_vm" {
  # Указываем пространство ресурсов, из которого извлекаем список ВМ
  space = data.ocean_resourcemanager_space.space.name

  # Фильтруем ВМ по сайту, используя идентификатор основного сайта
  site_name = join(",", [for i in data.ocean_compute_sites.default_site.sites : i.name if i.id == var.default_site_id])

  # Гарантируем, что данные о ВМ получаются только после загрузки информации о пространстве и сайтах
  depends_on = [data.ocean_resourcemanager_space.space, data.ocean_compute_sites.default_site]
}

# Получение информации о виртуальной частной сети (VPC) с именем, заканчивающимся на "default"
# Используется для выбора основной (дефолтной) сети среди доступных VPC
data "ocean_compute_vpc" "vpc_default" {
  # Фильтруем список VPC, выбирая только те, у которых имя заканчивается на "default"
  name = join(", ", [for item in var.vpc_name : item if can(regex(".*default$", item))])

  # Определяем пространство ресурсов, к которому принадлежит VPC
  space = data.ocean_resourcemanager_space.space.name

  # Указываем зависимость от пространства ресурсов и вычислительных сайтов
  depends_on = [data.ocean_resourcemanager_space.space, data.ocean_compute_sites.default_site]
}

# Получение информации о подсети, принадлежащей основной (дефолтной) VPC
data "ocean_compute_subnet" "subnet_default_vpc" {
  # Формируем имя подсети, объединяя имя дефолтной VPC и имя подсети, соответствующее текущему состоянию
  name = "${join(", ", [for i in var.vpc_name : i if can(regex(".*default$", i))])}-${join(",", [for i in var.subnet_name : i if can(regex(".*${var.state}", i))])}"

  # Определяем сайт, на котором расположена подсеть
  site_name = join(",", [for i in data.ocean_compute_sites.default_site.sites : i.name if i.id == var.default_site_id])

  # Гарантируем, что данные о подсети загружаются только после загрузки информации о пространстве и сайтах
  depends_on = [data.ocean_resourcemanager_space.space, data.ocean_compute_sites.default_site]
}
