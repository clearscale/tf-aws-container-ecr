package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
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
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Get the name of the ECR repository from Terraform output
	ecrRepoURI := terraform.Output(t, terraformOptions, "repository_url")

	// Split the string by the slash
	ecrRepoNameParts := strings.Split(ecrRepoURI, "/")

	// Check if there is a part after the slash
	assert.Len(t, ecrRepoNameParts, 2, "No forward slash found in the ECR repository URI.")

	ecrRepoName := ecrRepoNameParts[1]

	// Create an AWS session
	awsSession, err := session.NewSessionWithOptions(session.Options{
		Profile:           "default",
		Config:            aws.Config{Region: aws.String(region)},
		SharedConfigState: session.SharedConfigEnable,
	})
	if err != nil {
		t.Fatalf("Failed to create AWS session: %v", err)
	}

	// Create an ECR client
	ecrClient := ecr.New(awsSession)

	// Call the ECR DescribeRepositories API
	_, err = ecrClient.DescribeRepositories(&ecr.DescribeRepositoriesInput{
		RepositoryNames: []*string{&ecrRepoName},
	})

	// Assert that there was no error (i.e., the repository exists)
	assert.NoError(t, err, "ECR repository does not exist")
}
