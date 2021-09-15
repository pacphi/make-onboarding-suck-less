# Creating an EC2 instance from AMI

## Prerequisites

* AWS administrator account credentials
* [aws CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)


## Stop paging

```
export AWS_PAGER=
```


## Create a New Key Pair for EC2 Instances

```
ssh-keygen -t rsa -C "my-key" -f $HOME/.ssh/my-key
aws ec2 import-key-pair --key-name "my-key" --public-key-material fileb://$HOME/.ssh/my-key.pub
```
> You will have to press `Ctrl+c` to exit after issuing the second command above

## Launch New EC2 Instance

```
aws ec2 run-instances --image-id {AMI_ID} --instance-type=m4.large --key-name my-key
```
> Replace `{AMI_ID}` above with the AMI ID of the image you're hosting in your AWS account and region.

### Fetch instance

```
aws ec2 describe-instances
```
> Pay attention to the `InstanceId` and `PublicDnsName` in the JSON output returned.


## Connect to the instance

```
ssh -i $HOME/.ssh/my-key ubuntu@{INSTANCE_PUBLIC_DNS_NAME}
```
> You were paying attention weren't you? The `{INSTANCE_PUBLIC_DNS_NAME}` is available from the output of the prior command you issued.


## On using the Tanzu CLI

One time setup

You will need to install the plugins the Tanzu CLI requires after connecting by exploding the tarball and executing `tanzu plugin install --local cli all`


### Troubleshooting connectivity

* [Can you telnet to SSH?](https://stackoverflow.com/questions/11548787/can-you-telnet-to-ssh)
* [Add a rule for inbound SSH traffic to a Linux instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/authorizing-access-to-an-instance.html)



## Stop and Start an EC2 Instance

Any on-demand EC2 instance in a running state can be stopped with

```
aws ec2 stop-instances --instance-ids {INSTANCE_ID}
```

And started again with

```
aws ec2 start-instances --instance-ids {INSTANCE_ID}
```

> Replace `{INSTANCE_ID}` above with the instance ID of the image you intend to stop or start


## Terminate an EC2 instance

If we want to remove the instance completely, then we can terminate the instance with

```
aws ec2 terminate-instances --instance-ids {INSTANCE_ID}
```
> Replace `{INSTANCE_ID}` above with the instance ID of the image you intend to terminate


## Credits

* [Add a rule for inbound SSH traffic to a Linux instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/authorizing-access-to-an-instance.html)
* [AWS says invalid format for my SSH key... What happened?](https://sjsadowski.com/invalid-format-ssh-key/)