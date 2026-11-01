resource "aws_iam_group" "this" {
  name = var.group_name
  path = "/"
}

# Attach all supplied policies to the group
resource "aws_iam_group_policy_attachment" "this" {
  count      = length(var.policy_arns)
  group      = aws_iam_group.this.name
  policy_arn = var.policy_arns[count.index]
}

# Add users to group using dedicated membership resource
resource "aws_iam_user_group_membership" "this" {
  for_each = toset(var.members)
  user     = each.value
  groups   = [aws_iam_group.this.name]
}
