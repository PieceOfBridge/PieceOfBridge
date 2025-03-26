# Получение списка доступных вычислительных сайтов
# Используется для определения, на каких сайтах могут быть развернуты ресурсы
data "ocean_compute_sites" "default_site" {}

# Получение списка доступных политик хранения данных (Storage Policies)
# Определяет доступные уровни хранения для данного пространства ресурсов
data "ocean_compute_storage_policies" "enabled_storage_policies" {
  # Указываем пространство ресурсов, к которому относятся политики хранения
  space = data.ocean_resourcemanager_space.space.name

  # Фильтруем политики хранения по сайту, используя идентификатор основного сайта
  site_name = join(",", [for i in data.ocean_compute_sites.default_site.sites : i.name if i.id == "***"])

  # Обеспечиваем выполнение получения данных только после загрузки данных о пространстве и сайтах
  depends_on = [data.ocean_resourcemanager_space.space, data.ocean_compute_sites.default_site]
}

# Получение информации о пространстве ресурсов (Resource Manager Space)
# Пространство ресурсов используется для логического объединения облачных ресурсов
data "ocean_resourcemanager_space" "space" {
  name = var.space_name
}
