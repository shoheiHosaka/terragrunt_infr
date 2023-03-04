resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_role" "github" {
  name = "github-oidc-role"
  assume_role_policy = data.aws_iam_policy_document.github_assume_policy.json
  path  = "/admin/"
}

data "aws_iam_policy_document" "github_assume_policy" {
  statement {
    sid    = "CustomAssumePolicyForGithub"
    effect = "Allow"
    principals {
      type           = "Federated"
      identifiers  = ["arn:aws:iam::${var.accountid}:oidc-provider/token.actions.githubusercontent.com"]
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
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "github" {
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
  role       = aws_iam_role.github.name
}
