# Deploy ci-cd pipeline in AWS EKS

## run terraform to create eks cluster 
```bash
terraform init
terraform apply
```
## connect to eks cluster
```bash
aws eks update-kubeconfig --region us-east-1 --name eks-cluster
```
![image](https://user-images.githubusercontent.com/58703269/218817003-6f4f6f2a-e36b-4ecb-9690-e07754d27ab6.png)

## Setup our Cloud Storage
```bash
# deploy EFS storage driver
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

# get VPC ID
aws eks describe-cluster --name eks-cluster --query "cluster.resourcesVpcConfig.vpcId" --output text
# Get CIDR range
aws ec2 describe-vpcs --vpc-ids vpc-0783edc3bdec28b6e --query "Vpcs[].CidrBlock" --output text
# security for our instances to access file storage
aws ec2 create-security-group --description efs-test-sg --group-name efs-sg --vpc-id VPC_ID
aws ec2 authorize-security-group-ingress --group-id sg-xxx  --protocol tcp --port 2049 --cidr VPC_CIDR

# create storage
aws efs create-file-system --creation-token eks-efs

# create mount point 
aws efs create-mount-target --file-system-id FileSystemId --subnet-id SubnetID --security-group GroupID

# grab our volume handle to update our PV YAML
aws efs describe-file-systems --query "FileSystems[*].FileSystemId" --output text
```
![image](https://user-images.githubusercontent.com/58703269/218817247-1ec4ceaf-d6d6-4a16-9879-3a22236815b4.png)

## Setup a namespace
```bash
kubectl create ns jenkins
```
![image](https://user-images.githubusercontent.com/58703269/218817911-26e79a7a-cf7d-4949-b7df-dc36869682e1.png)

## Setup our storage for Jenkins
```bash
kubectl get storageclass
```
![image](https://user-images.githubusercontent.com/58703269/218818313-556ddd7e-65ee-42d6-8629-b2d2c4d8b2aa.png)

```bash
# create volume
kubectl apply -f .jenkins.pv.yaml 
kubectl get pv
```
![image](https://user-images.githubusercontent.com/58703269/218818619-fe47c8a4-746c-4904-a8f7-775098e485ce.png)

```bash
# create volume claim
kubectl apply -n jenkins -f jenkins.pvc.yaml
kubectl -n jenkins get pvc
```
![image](https://user-images.githubusercontent.com/58703269/218818804-b71f2b34-ba4e-4451-bbcb-dddbaf67556c.png)

## Deploy Jenkins
```bash
# rbac
kubectl apply -n jenkins -f jenkins.rbac.yaml 

kubectl apply -n jenkins -f jenkins.deployment.yaml

kubectl -n jenkins get pods

```
![image](https://user-images.githubusercontent.com/58703269/218819074-138d07ef-e247-4215-a4e9-af514acd508e.png)

## Expose a service for agents
```bash
kubectl apply -n jenkins -f jenkins.service.yaml 
```
![image](https://user-images.githubusercontent.com/58703269/218819396-3a448942-c6bf-47e7-96a5-a914a81d510a.png)

## Jenkins in browser
![image](https://user-images.githubusercontent.com/58703269/218819573-6643bb68-7182-4fad-9977-4346e77e2672.png)

## Jenkins Initial Setup
```bash
kubectl -n jenkins exec -it pod/jenkins-f7959cc74-vdkzj cat /var/jenkins_home/secrets/initialAdminPassword
```
![image](https://user-images.githubusercontent.com/58703269/218819868-dc34f2df-918a-4ad5-ad6c-539af736e970.png)

![image](https://user-images.githubusercontent.com/58703269/218878698-8ad2509d-f4e9-4a17-bdd2-5e372b176ab2.png)

## Create pipeline job

![image](https://user-images.githubusercontent.com/58703269/218881230-cfc7eddc-5615-481d-8898-f508ea50056f.png)

![image](https://user-images.githubusercontent.com/58703269/218895653-be1c8089-c0f0-48b8-92a5-1bbf019dac07.png)

![image](https://user-images.githubusercontent.com/58703269/218895555-8b5af5c2-d5b7-4a8f-a1a1-9a7f2d1a748a.png)

## Create service account to allow any Kubernetes user to have admin access
```bash
kubectl create clusterrolebinding serviceaccounts-cluster-admin \
  --clusterrole=cluster-admin \
  --group=system:serviceaccounts
clusterrolebinding.rbac.authorization.k8s.io/serviceaccounts-cluster-admin created

```

## Build pipeline

![image](https://user-images.githubusercontent.com/58703269/218896053-974c7342-187b-485e-b80a-21719e2941d3.png)

![image](https://user-images.githubusercontent.com/58703269/218896158-1059b39c-db79-46b6-b4bf-6a1e955e1d0e.png)

![image](https://user-images.githubusercontent.com/58703269/218896241-22ec8e20-bf9d-4a41-aecd-cbdca0502cc4.png)

![image](https://user-images.githubusercontent.com/58703269/218896298-ba61400a-c181-4d6b-9172-470c58fd7a8b.png)

![image](https://user-images.githubusercontent.com/58703269/218896342-ab2908f1-540a-4f3c-8415-531fb9499034.png)

![image](https://user-images.githubusercontent.com/58703269/218896479-1dc73e97-7ad7-4a9f-89ae-42b86eafe66c.png)

![image](https://user-images.githubusercontent.com/58703269/218896545-679a3893-4067-4b1a-933c-98a1eabbaf81.png)

## Expose Jenkins and web app from mobile

![WhatsApp Image 2023-02-15 at 3 03 18 AM](https://user-images.githubusercontent.com/58703269/218898682-487f5ed5-5067-4f52-8676-06db6c652a1d.jpeg)

![WhatsApp Image 2023-02-15 at 3 04 11 AM](https://user-images.githubusercontent.com/58703269/218898799-c07f8819-d30e-4a85-ad35-61a1908e3b94.jpeg)
