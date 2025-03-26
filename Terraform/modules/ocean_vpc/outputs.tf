# Выходная переменная, содержащая список имен всех созданных VPC
# Используется для идентификации созданных виртуальных частных сетей
output "vpc_name" {
  value = ocean_compute_vpc.dso-scope[*].name
}

# Выходная переменная, содержащая список имен всех созданных подсетей
# Позволяет получить доступ к именам подсетей в созданной VPC
output "subnet_name" {
  value = ocean_compute_subnet.default_subnets[*].name
}

# Выходная переменная, содержащая список CIDR-диапазонов всех созданных подсетей
# Используется для понимания распределения IP-адресов внутри подсетей
output "subbnet_cidr" {
  value = ocean_compute_subnet.default_subnets[*].cidr
}

# Выходная переменная, содержащая имя вычислительного сайта, где развернуты ресурсы
# Фильтруем сайты, оставляя только тот, чей ID совпадает с default_site_id
output "site_name" {
  value = join(",", [for i in data.ocean_compute_sites.default_site.sites : i.name if i.id == var.default_site_id])
}

# Выходная переменная, содержащая имя пространства ресурсов
# Пространство ресурсов используется для логического объединения инфраструктуры
output "default_space" {
  value = data.ocean_resourcemanager_space.space.name
}

# Выходная переменная, содержащая список всех созданных внешних IP-адресов
# Позволяет получить список внешних IP, привязанных к виртуальным машинам
output "external_ip_names" {
  value = data.ocean_compute_external_ip.external_ip[*].name
}

# Выходная переменная, содержащая данные о внешних IP-адресах из локальной переменной EXT_INTERFACE
# Содержит информацию о каждой ВМ, которой был назначен внешний IP-адрес
output "ext_ip" {
  value = local.EXT_INTERFACE
}
