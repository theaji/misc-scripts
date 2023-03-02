
# Objective

This project creates 2 EC2 instances (1 Public, 1 Private). Interface endpoints are also created to faciliatate access between SSM and the private EC2 instance.

Prerequisites:

- Copy dev-ssm.yml to an S3 bucket and modify "TemplateBucketName" and "Prefix" parameters in dev-stack.yml as needed.

## Services covered

EC2 | Endpoints | SSM | VPC

## Template explanation

### Section 1

Create a VPC with 2 subnets. The VPC is separated from the SSM and EC2 stacks so it can be reused.

Trimmed:

```

  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VPCCidrBlock
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: !Sub vpc-${AWS::StackName}
          
  PublicSubnet:
    Type: AWS::EC2::Subnet
    DependsOn: IPv6CidrBlock
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [ 0, !GetAZs '' ]
      CidrBlock: !Ref PublicCidrIp
      MapPublicIpOnLaunch: true
      AssignIpv6AddressOnCreation: true
      Ipv6CidrBlock: 
        Fn::Sub:
          - "${VpcPart}${SubnetPart}"
          - SubnetPart: '01::/64'
            VpcPart: !Select [ 0, !Split [ '00::/56', !Select [ 0, !GetAtt VPC.Ipv6CidrBlocks ]]]
      Tags:
        - Key: Name
          Value: !Sub sn-web-${AWS::StackName}
          
  PrivateSubnet:
    Type: AWS::EC2::Subnet
    DependsOn: IPv6CidrBlock
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [ 1, !GetAZs '' ]
      CidrBlock: !Ref PrivateCidrIP
      AssignIpv6AddressOnCreation: true
      Ipv6CidrBlock: 
        Fn::Sub:
          - "${VpcPart}${SubnetPart}"
          - SubnetPart: '04::/64'
            VpcPart: !Select [ 0, !Split [ '00::/56', !Select [ 0, !GetAtt VPC.Ipv6CidrBlocks ]]]
      Tags:
        - Key: Name
          Value: !Sub sn-priv-${AWS::StackName}


```

### Section 1A

Creates instance security groups for EC2InstanceA, EC2InstanceB and for SSM respectively.

The SSMSecurityGroup allows access to the endpoints from the other 2 security groups.

```
  InstanceSecurityGroup:
    Type: 'AWS::EC2::SecurityGroup'
    Properties:
      GroupDescription: Enable HTTP access
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: '80'
          ToPort: '80'
          CidrIp: '0.0.0.0/0'
          
  InstanceSecurityGroupB:
    Type: 'AWS::EC2::SecurityGroup'
    Properties:
      GroupDescription: No ingress
      VpcId: !Ref VPC

          
  SSMSecurityGroup:
    Type: 'AWS::EC2::SecurityGroup'
    Properties:
      GroupDescription: Allow from InstanceSecurityGroupB
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: '443'
          ToPort: '443'
          SourceSecurityGroupId: !Ref InstanceSecurityGroup
        - IpProtocol: tcp
          FromPort: '443'
          ToPort: '443'
          SourceSecurityGroupId: !Ref InstanceSecurityGroupB

```

### Section 2

Retrieves the template for the SSM stack

```
  SSMStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: !Sub "https://${TemplateBucketName}.s3.${AWS::Region}.amazonaws.com/${Prefix}/${Prefix}-ssm.yml"
      Parameters:
        SSMSecurityGroup: !ImportValue dev-vpc1-ssmsg
        PrivateSubnet: !ImportValue dev-vpc1-prisub
        VPC: !ImportValue dev-vpc1
```

### Section 3

Creates the EC2 instances. Values from the VPC stack are referenced using ImportValue intrinsic function. 

A web server is also configured on EC2instanceA to display the instance type, instane AZ and instance ID

```    EC2InstanceA:
    Type: AWS::EC2::Instance
    Properties:
      IamInstanceProfile: !Ref InstanceProfile
      SubnetId: !ImportValue dev-vpc1-pubsub
      InstanceType: !Ref InstanceType
      ImageId: !Ref ImageId
      SecurityGroupIds: 
        - !ImportValue dev-vpc1-sg
      Tags:
        - Key: Name
          Value: !Sub ec2-${AWS::StackName}
      UserData:
        Fn::Base64: !Sub |
            #!/bin/bash -xe

            # STEP 1 - Updates
            yum -y update
            
            # STEP 2 - Begin Configuration
            yum -y install httpd
            systemctl enable httpd
            systemctl start httpd
            instanceId=$(curl http://169.254.169.254/latest/meta-data/instance-id)
            AZ=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
            instanceType=$(curl http://169.254.169.254/latest/meta-data/instance-type)
            echo "<html><head></head><body>" >> /var/www/html/index.html
            echo "<center><h1>Instance ID : $instanceId</h1></center><br>" >> /var/www/html/index.html
            echo "<center><h1>Instance AZ : $AZ</h1></center><br>" >> /var/www/html/index.html
            echo "<center><h1>Instance Type : $instanceType</h1></center><br>" >> /var/www/html/index.html
            echo "</body></html>" >> /var/www/html/index.html
            
  EC2InstanceB:
    Type: AWS::EC2::Instance
    Properties:
      IamInstanceProfile: !Ref InstanceProfile
      SubnetId: !ImportValue dev-vpc1-prisub
      InstanceType: !Ref InstanceType
      ImageId: !Ref ImageId
      SecurityGroupIds: 
        - !ImportValue dev-vpc1-igb
      Tags:
        - Key: Name
          Value: !Sub ec2B-${AWS::StackName}
```
### Section 4

Creates instance role and profile to be attached to EC2 instances. 2 AWS managed policies are used to allow EC2 access to SSM and CloudWatch

```
  InstanceRole:
    Type: 'AWS::IAM::Role'
    Properties:
      AssumeRolePolicyDocument:
        Version: 2012-10-17
        Statement:
          - Effect: Allow
            Principal:
              Service: 
              - ec2.amazonaws.com
            Action:
              - 'sts:AssumeRole'
      Path: /
      ManagedPolicyArns: 
        - arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
        - arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy
  InstanceProfile: 
    Type: 'AWS::IAM::InstanceProfile'
    Properties:
      Path: /
      Roles:
        - !Ref InstanceRole

```

### Section 5

Creates endpoints required to faciliate communications between SSM and EC2

```
  SSMEndpoint:
    Type: AWS::EC2::VPCEndpoint
    Properties:
      PrivateDnsEnabled: true
      SecurityGroupIds:
        - !Ref SSMSecurityGroup
      ServiceName: !Sub com.amazonaws.${AWS::Region}.ssm
      SubnetIds:
        - !Ref PrivateSubnet
      VpcEndpointType: Interface
      VpcId: !Ref VPC
      

  EC2MessagesEndpoint:
    Type: AWS::EC2::VPCEndpoint
    Properties:
      PrivateDnsEnabled: true
      SecurityGroupIds:
        - !Ref SSMSecurityGroup
      ServiceName: !Sub com.amazonaws.${AWS::Region}.ec2messages
      SubnetIds:
        - !Ref PrivateSubnet
      VpcEndpointType: Interface
      VpcId: !Ref VPC
      

  SSMMessagesEndpoint:
    Type: AWS::EC2::VPCEndpoint
    Properties:
      PrivateDnsEnabled: true
      SecurityGroupIds:
        - !Ref SSMSecurityGroup
      ServiceName: !Sub com.amazonaws.${AWS::Region}.ssmmessages
      SubnetIds:
        - !Ref PrivateSubnet
      VpcEndpointType: Interface
      VpcId: !Ref VPC
```



## Commands used

Validate the template: `aws cloudformation validate-template --template-body file://dev-stack.yml` & `aws cloudformation validate-template --template-body file://dev-vpc.yml`

Alternatively: Install cfn-lint and use: `cfn-lint dev-stack.yml` &  `cfn-lint dev-vpc.yml`

Deploy stackA: `aws cloudformation create-stack --stack-name vpc-stack --template-body file://dev-vpc.yml`
 
Deploy stackB: `aws cloudformation create-stack --stack-name dev-stack --template-body file://dev-stack.yml` --capabilities CAPABILITY_IAM

Check stack status and view outputs: `aws cloudformation describe-stacks --stack-name dev-stack`

Delete stack: `aws cloudformation delete-stack --stack-name dev-stack`

View SSM managed instances: `aws ssm describe-instance-information`

Connect to private instance using AWS CLI + SSM Plugin: `aws ssm start-session --target i-xxxxx`


