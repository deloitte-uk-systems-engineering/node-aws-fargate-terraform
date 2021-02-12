

resource "aws_codepipeline" "node_express_ecs_codepipeline" {
  name     = "node_express_ecs_codepipeline"
  role_arn = aws_iam_role.node_express_ecs_codepipeline_role.arn
  depends_on = [aws_ecs_service.staging]


  artifact_store {
    location = aws_s3_bucket.node_express_ecs_s3_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.github_username
        Repo       = var.github_project_name
        Branch     = "master"
        OAuthToken = var.github_token
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "node_express_ecs_codebuild_project"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ClusterName = "tf-ecs-cluster"
        ServiceName = "staging"
      }
    }
  }

}

