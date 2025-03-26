### TODO Изменить на чтение списка. Должна быть возможность создания сразу нескольких зон

resource "ocean_dns_hosting_zone" "hosting_zone" {
  name = var.zone_name_default
}
