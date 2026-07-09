resource "kubernetes_namespace" "env" {
  for_each = toset(var.namespaces)

  metadata {
    name = each.value
    labels = {
      "app.kubernetes.io/part-of" = var.project_name
      environment                 = replace(each.value, "${var.project_name}-", "")
    }
  }
}
