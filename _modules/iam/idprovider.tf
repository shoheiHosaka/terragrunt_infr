resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_role" "github" {
  name               = "github-oidc-role"
  assume_role_policy = data.aws_iam_policy_document.github_assume_policy.json
  path               = "/admin/"
}

data "aws_iam_policy_document" "github_assume_policy" {
  statement {
    sid    = "CustomAssumePolicyForGithubActions"
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.accountid}:oidc-provider/token.actions.githubusercontent.com"]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.github_repos
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud" 
      values   = ["sts.amazonaws.com" ]
    }
  }
}

data "aws_iam_policy_document" "sts_AssumeRoleWithWebIdentity" {
  statement {
    sid       = "allowSts"
    effect    = "Allow"
    actions   = ["sts:AssumeRoleWithWebIdentity"]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "sts_AssumeRoleWithWebIdentity" {
  name   =  "github-oidc-role-policy"
  path   = "/admin/"
  policy = data.aws_iam_policy_document.sts_AssumeRoleWithWebIdentity.json
}
resource "aws_iam_role_policy_attachment" "github" {
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
  role       = aws_iam_role.github.name
}

resource "aws_iam_role_policy_attachment" "sts_AssumeRoleWithWebIdentity" {
  policy_arn = aws_iam_policy.sts_AssumeRoleWithWebIdentity.arn
  role       = aws_iam_role.github.name
}
