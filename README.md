# ECS with Service Connect 

This project aims at deploying Techbuzz (https://github.com/sivaprasadreddy/techbuzz) app to ECS. Techbuzz makes use of postgres and mailhog container. For demo purpose, we are using postgres container instead of using AWS RDS. This project also levarages ECS service connect feature that was introduced in 2022. AWS Service connect combines the features of Service Discovery and AWS app mesh without the additional complexity or any additional code changes. 

To know more about service connect, refer the following articles:

https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-connect.html

https://aws.amazon.com/blogs/containers/migrate-existing-amazon-ecs-services-from-service-discovery-to-amazon-ecs-service-connect/

This terraform project provisions the following resources

1. VPC
2. ALB
3. ECS cluster
4. Task definition for techbuzz,postgres, mailhog
5. Services for tech buzz, postgres and mailhog with service connect enabled

#### Pre-requisites

- Domain need to be  hosted at AWS Route53. 
- Needs to set the registered domain name in terraform.tfvars or directly in variables.tf

#### Running the app

Run the following commands in succession

```
terraform init

terrafor apply
```

Main app can be accessed at https://techbuzzbackend.yourdomain and mailhog can be accessed at https://techbuzzmamail.yourdomain . The latter has to be used for access mail for verfication, forgot password features.

Check whether service connect is enabled

![image-20231009171523618](/Users/pavithra/Library/Application Support/typora-user-images/image-20231009171523618.png)



#### Additional Notes

Order of service deployment should be maintained. For example, main app depends on postgres and mailhog . So postgres and mailhog services have to be deployed prior for service discovery to work.

