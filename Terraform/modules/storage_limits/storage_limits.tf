# Ресурс для установки лимитов хранения для политики "Silver"
resource "ocean_compute_storage_limits" "silver" {
  # Определяем количество создаваемых ограничений хранения, равное количеству доступных политик хранения
  count = length(data.ocean_compute_storage_policies.enabled_storage_policies.policies)

  # Определяем сайт, на котором применяется ограничение, используя ID основного сайта
  site_name = join(",", [for i in data.ocean_compute_sites.default_site.sites : i.name if i.id == "***"])

  # Определяем лимиты хранения для политики "Silver"
  storage_limits = [
    {
      # Фильтруем доступные политики хранения и выбираем "Silver"
      storage_policy_name = join(",", [for i in data.ocean_compute_storage_policies.enabled_storage_policies.policies[*].name : i if i == "Silver"])
      # Устанавливаем лимит хранения в мегабайтах (MB) из переменной
      limit_mb = var.storage_capacity_silver
    }
  ]
}

# Ресурс для установки лимитов хранения для политики "Silver+"
resource "ocean_compute_storage_limits" "silver_plus" {
  # Определяем сайт, на котором применяется ограничение, используя ID основного сайта
  site_name = join(",", [for i in data.ocean_compute_sites.default_site.sites : i.name if i.id == "***"])

  # Определяем лимиты хранения для политики "Silver+"
  storage_limits = [
    {
      # Фильтруем доступные политики хранения и выбираем "Silver+"
      storage_policy_name = join(",", [for i in data.ocean_compute_storage_policies.enabled_storage_policies.policies[*].name : i if i == "***"])
      # Устанавливаем лимит хранения в мегабайтах (MB) из переменной
      limit_mb = var.storage_capacity_silver_plus
    }
  ]
}
