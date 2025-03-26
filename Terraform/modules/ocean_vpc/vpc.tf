# Ресурс для создания виртуальных частных сетей (VPC)
resource "ocean_compute_vpc" "dso-scope" {
  # Количество создаваемых VPC определяется числом элементов в списке var.vpc
  count = length(var.vpc)

  # Генерируем имя VPC, используя название пространства ресурсов и имя VPC из списка
  name = "${data.ocean_resourcemanager_space.space.name}-${var.vpc[count.index].name}"

  # Указываем пространство ресурсов, в котором создается VPC
  space = data.ocean_resourcemanager_space.space.name

  # Задаем зону сетевой безопасности для каждой VPC
  network_security_zone = var.vpc[count.index].security_zone

  # Добавляем описание для удобства, включающее имя VPC и пространство ресурсов
  description = "Сеть ${var.vpc[count.index].name} в пространстве ${data.ocean_resourcemanager_space.space.name}"

  # Определяем базовый префикс (CIDR-диапазон) для каждой VPC
  base_prefix = var.vpc[count.index].base_prefix
}
