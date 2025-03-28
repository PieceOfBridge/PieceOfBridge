# Выходная переменная, содержащая список всех созданных DNS-записей
# Значение берется из локальной переменной local.dns_records, которая содержит
# как внутренние, так и внешние DNS-записи для виртуальных машин
output "dns_records" {
  value = local.dns_records
}

# Выходная переменная, содержащая информацию о зоне хостинга DNS
# Используется для получения параметров существующей DNS-зоны, таких как ее имя и идентификатор
output "hosting_zone" {
  value = data.ocean_dns_hosting_zone.default_zone
}
