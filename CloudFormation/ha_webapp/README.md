# Objective

Utilize ALB + ASG to run a specific number of instances of a website

## Services covered

EC2 | Auto Scaling | Elastic Load Balancing | VPC

## Template Explanation

### Section 1: Parameters

Get latest ami id published by AWS via SSM parameter store. This section also specifies an existing keypair to SSH into the EC2 instances

```
Parameters:
  LatestAmiId:
    Description: AMI for Instance (default is latest AmaLinux2)
    Type: 'AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>'
    Default: '/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2'
    
  KeyName:
    Type: AWS::EC2::KeyPair::KeyName
    Description: Name of an existing SSH Keypair to access the instance
    Default: key.pem 
```

### Section 2: VPC

Create VPC and 3 subnets (trimmed)

```
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.50.0.0/16
      EnableDnsSupport: true
      EnableDnsHostnames: true
      Tags:
        - Key: Name
          Value: !Sub ${AWS::StackName}-ha-vpc
          
          
  SubnetWEBA:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [ 0, !GetAZs '' ]
      CidrBlock: 10.50.80.0/24
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub ${AWS::StackName}-sn-webA
          
  SubnetWEBB:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [ 1, !GetAZs '' ]
      CidrBlock: 10.50.96.0/24
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub ${AWS::StackName}-sn-webB
          
  SubnetWEBC:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [ 2, !GetAZs '' ]
      CidrBlock: 10.50.20.0/24
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub ${AWS::StackName}-sn-webC
```

### Section 3: Security Groups

Create Security groups for the web instances and the load balancer

```
  SGWEB:
    Type: 'AWS::EC2::SecurityGroup'
    Properties:
      VpcId: !Ref VPC
      GroupDescription: Control access to WEB Instance(s)
      SecurityGroupIngress: 
        - Description: 'Allow HTTP IPv4 IN'
          IpProtocol: tcp
          FromPort: '80'
          ToPort: '80'
          CidrIp: '0.0.0.0/0'
        - Description: 'Allow WWW IN FROM ALB'
          IpProtocol: tcp
          FromPort: '80'
          ToPort: '80'
          SourceSecurityGroupId: !Ref SGLoadBalancer
          
  SGLoadBalancer:
    Type: 'AWS::EC2::SecurityGroup'
    Properties:
      VpcId: !Ref VPC
      GroupDescription: Control access to Load Balancer
      SecurityGroupIngress: 
        - Description: 'Allow HTTP IPv4 IN'
          IpProtocol: tcp
          FromPort: '80'
          ToPort: '80'
          CidrIp: '0.0.0.0/0'
```

### Section 4: Launch Template

Create launch template and specify UserData to run when provisioning new instances. The UserData specified installs apache and displays the instance type, instance availability zone and instance id

```
  WEBLaunchTemplate:
    Type: AWS::EC2::LaunchTemplate
    Properties: 
      LaunchTemplateData: 
        InstanceType: "t2.micro"
        ImageId: !Ref LatestAmiId
        KeyName: !Ref KeyName
        SecurityGroupIds: 
          - !Ref SGWEB
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
```

### Section 5: Auto-Scaling Group

Create Auto Scaling Group with an ELB Healthcheck. Also create a scaling policy based on CPU utilization

```
  ASG: 
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties: 
      VPCZoneIdentifier:
        - !Ref SubnetWEBA
        - !Ref SubnetWEBB
        - !Ref SubnetWEBC
      LaunchTemplate:
        LaunchTemplateId: !Ref WEBLaunchTemplate
        Version: "1"
      MaxSize: !Ref AsgMax
      MinSize: !Ref AsgMin
      DesiredCapacity: !Ref AsgDesired
      Tags:
        - Key: "Name"
          Value: !Join [ '', [ 'ha-web' ] ]
          PropagateAtLaunch: true
      HealthCheckType: ELB
      Cooldown: 120
      HealthCheckGracePeriod: 300
      TargetGroupARNs:
        - !Ref ALBTG

  ScalingPolicy:
    Type: AWS::AutoScaling::ScalingPolicy
    Properties:
      AutoScalingGroupName: !Ref ASG
      PolicyType: TargetTrackingScaling
      TargetTrackingConfiguration:
        PredefinedMetricSpecification:
          PredefinedMetricType: ASGAverageCPUUtilization
        TargetValue: 80
```

### Section 6: ALB

Create ALB to forward traffic to instances. Also creates healthcheck to verify index.html is accessible.

Session stickiness is set to false to verify ALB is functioning properly and sending requests to all instances

```
  ALB:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties: 
      IpAddressType: "ipv4"
      Scheme: "internet-facing"
      SecurityGroups: 
        - !Ref SGLoadBalancer
      Subnets: 
        - !Ref SubnetWEBA
        - !Ref SubnetWEBB
        - !Ref SubnetWEBC
      Tags: 
        - Key: Name
          Value: !Join [ '', [ 'ALB-', !Ref 'AWS::StackName' ] ]
      Type: "application"

  ALBListener:
    Type: AWS::ElasticLoadBalancingV2::Listener
    Properties:
      DefaultActions:
        - Type: forward
          TargetGroupArn: !Ref ALBTG
      LoadBalancerArn: !Ref ALB
      Port: 80
      Protocol: HTTP

  ALBTG:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    Properties:
      HealthCheckIntervalSeconds: 30
      HealthCheckPath: /index.html
      HealthCheckTimeoutSeconds: 5
      Port: 80
      Protocol: HTTP
      UnhealthyThresholdCount: 5
      VpcId: !Ref VPC
      TargetGroupAttributes:
        - Key: stickiness.enabled 
          Value: false

```


## Commands used

Validate the template: `aws cloudformation validate-template --template-body file://ha_webapp_v2.yml`

Alternatively: Install [cfn-lint](https://github.com/aws-cloudformation/cfn-lint) and use: `cfn-lint ha_webapp_v2.yml`

Deploy stack: `aws cloudformation create-stack --stack-name webapp-stack --template-body file://ha_webapp_v2.yml`

Check stack status and view outputs: `aws cloudformation describe-stacks --stack-name webapp-stack`

Delete stack: `aws cloudformation delete-stack --stack-name webapp-stack`
