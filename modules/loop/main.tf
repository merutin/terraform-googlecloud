variable "buckets" {
  type = map(object({
    region        = string
    storage_class = optional(string, "STANDARD")
    versioning    = optional(bool, true)
    age          = optional(number)
    lifecycle_rule = optional(object({
      age         = optional(number)
      with_state  = optional(string)
      created_before = optional(string)
      matches_storage_class = optional(list(string))
    }))
  }))
  description = "Map of bucket configurations"
}

resource "google_storage_bucket" "default" {
  for_each = var.buckets

  name                        = "${each.key}-${random_id.bucket_suffix[each.key].hex}"
  location                    = each.value.region
  storage_class               = each.value.storage_class
  uniform_bucket_level_access = true

  versioning {
    enabled = each.value.versioning
  }

  dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_rule != null ? [1] : []
    
    content {
      action {
        type = "Delete"
      }
      
      condition {
        age                        = try(each.value.age, null)
        with_state                 = try(each.value.lifecycle_rule.with_state, null)
        created_before             = try(each.value.lifecycle_rule.created_before, null)
        matches_storage_class      = try(each.value.lifecycle_rule.matches_storage_class, [])
      }
    }
  }
}

resource "random_id" "bucket_suffix" {
  for_each    = var.buckets
  byte_length = 4
}