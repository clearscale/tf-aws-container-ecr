package test

import (
	"fmt"
	"log"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ecr"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

/**
 * Test creation of ECR repo
 */
func TestRepositoryCreation(t *testing.T) {
	var region = "us-west-1"
	uniqueId := random.UniqueId()
	name := strings.ToLower(fmt.Sprintf("cs-pmod%s-testing", uniqueId))

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"region": region,
			"name":   name,
		},
		// Variables to override from the environment
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Get the name of the ECR repository from Terraform output
	ecrRepoURI := terraform.Output(t, terraformOptions, "repository_url")

	// Split the string by the slash
	ecrRepoNameParts := strings.Split(ecrRepoURI, "/")

	// Check if there is a part after the slash
	assert.Len(t, ecrRepoNameParts, 2, "No forward slash found in the ECR repository URI.")

	fmt.Println("ECR Repository URI:", ecrRepoURI)
	ecrRepoName := ""
	if len(ecrRepoNameParts) > 1 {
		ecrRepoName = ecrRepoNameParts[1]
		fmt.Println("Extracted ECR Repository Name:", ecrRepoName)
	} else {
		t.Fatalf("Invalid ECR repository URI format: %s", ecrRepoURI)
	}

	// Create a credentials chain
	creds := credentials.NewChainCredentials([]credentials.Provider{
		// First, try to get credentials from the shared config file (which includes both ~/.aws/credentials and ~/.aws/config)
		&credentials.SharedCredentialsProvider{
			Profile: "default",
		},
		// If that fails, fall back to environment variables
		&credentials.EnvProvider{},
	})

	// Create a new session with explicit credentials
	awsSession, err := session.NewSession(&aws.Config{
		Region:      aws.String(region),
		Credentials: creds,
	})
	if err != nil {
		log.Fatalf("Failed to create session: %s", err)
	}

	// Create an ECR client
	ecrClient := ecr.New(awsSession)

	resp, err := ecrClient.DescribeRepositories(&ecr.DescribeRepositoriesInput{
		RepositoryNames: []*string{aws.String(ecrRepoName)},
	})

	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case ecr.ErrCodeRepositoryNotFoundException:
				t.Fatalf("ECR repository not found: %s", ecrRepoName)
			default:
				t.Fatalf("Failed to describe ECR repository: %s, error: %v", ecrRepoName, err)
			}
		} else {
			t.Fatalf("Unknown error in DescribeRepositories: %v", err)
		}
	}

	fmt.Printf("Successfully found ECR repository: %s\n", *resp.Repositories[0].RepositoryName)
}
