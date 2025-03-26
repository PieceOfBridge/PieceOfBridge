# Ресурс для создания подсетей в указанной VPC
resource "ocean_compute_subnet" "default_subnets" {
  # Создаем количество подсетей, равное количеству элементов в списке var.subnet
  count = length(var.subnet)

  # Генерируем имя подсети на основе имени VPC и имени подсети из переменной
  name = "${data.ocean_compute_vpc.vpc_default.name}-${var.subnet[count.index].name}"

  # Определяем сайт, где будет создана подсеть, используя идентификатор основного сайта
  site_name = join(",", [for i in data.ocean_compute_sites.default_site.sites : i.name if i.id == var.default_site_id])

  # Указываем, к какой VPC привязана подсеть
  vpc_name = data.ocean_compute_vpc.vpc_default.name

  # Определяем CIDR-диапазон подсети, используя базовый префикс VPC
  # 14 – это количество дополнительных битов, выделенных для подсетей
  cidr = cidrsubnet(data.ocean_compute_vpc.vpc_default.base_prefix, 14, count.index)

  # Описание для удобного управления, содержащее имя подсети, VPC и пространство ресурсов
  description = "Подсеть ${var.subnet[count.index].name} сети ${data.ocean_compute_vpc.vpc_default.name} в ${data.ocean_resourcemanager_space.space.name}"

  # Указываем зависимость от создания VPC, чтобы подсеть создавалась только после завершения создания сети
  depends_on = [ocean_compute_vpc.dso-scope]
}
