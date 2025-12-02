variable "repo_name" {
  type = string
}

resource "aws_ecr_repository" "repo" {
  name                 = "j-repo-${var.repo_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_user" "user" {
  name = "j-${var.repo_name}-ecr-push-user"
}

resource "aws_iam_user_policy" "ecr_push_policy" {
  name = "j-${var.repo_name}-ecr-push-policy"
  user = aws_iam_user.user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = aws_ecr_repository.repo.arn
      }
    ]
  })
}

resource "aws_iam_access_key" "ecr_user_access_key" {
  user = aws_iam_user.user.name
}

output "repository_url" {
  value = aws_ecr_repository.repo.repository_url
}

output "repository_name" {
  value = aws_ecr_repository.repo.name
}

output "repository_arn" {
  value = aws_ecr_repository.repo.arn
}

output "user_name" {
  value = aws_iam_user.user.name
}

output "access_key_id" {
  value = aws_iam_access_key.ecr_user_access_key.id
}

output "secret_access_key" {
  value     = aws_iam_access_key.ecr_user_access_key.secret
  sensitive = true
}
