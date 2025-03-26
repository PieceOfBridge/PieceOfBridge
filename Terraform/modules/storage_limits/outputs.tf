# Выходная переменная, содержащая имя пространства ресурсов
# Пространство ресурсов используется для логического объединения облачных ресурсов
output "default_space" {
  value = data.ocean_resourcemanager_space.space.name
}

# Выходная переменная, содержащая список всех доступных политик хранения данных
# Политики хранения определяют уровень производительности и резервирования хранилища
output "storage_policys" {
  value = data.ocean_compute_storage_policies.enabled_storage_policies
}
