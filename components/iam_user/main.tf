resource "aws_iam_user" "this" {
  for_each      = toset(var.usernames)
  name          = each.value
  path          = "/"
  force_destroy = true # Deletes user even if keys/certificates exist
  tags          = var.tags
}
