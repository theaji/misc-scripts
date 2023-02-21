# Objective

This project uses codepipeline for continuous delivery of an EC2 webapp -  using CodeCommit as a source provider

## Architecture
![codepipeline](https://user-images.githubusercontent.com/117802776/220268053-bcd1be53-2ed3-47e4-9f88-756c52959199.png)

## Services covered

EC2 | CodeCommit | CodeDeploy | CodePipeline | S3 | VPC

## Template explanation

### Section 1

Creates a VPC, Internet Gateway, Route table  and Subnet necessary for the EC2 instance

```
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.20.0.0/16
      EnableDnsSupport: true
      EnableDnsHostnames: true
      Tags:
        - Key: Name
          Value: !Sub ${EnvironmentName}-vpc-{AWS::StackName}

  InternetGateway:
    Type: 'AWS::EC2::InternetGateway'
    Properties:
      Tags:
      - Key: Name
        Value: !Sub ${EnvironmentName}-igw-{AWS::StackName}
        
  InternetGatewayAttachment:
    Type: 'AWS::EC2::VPCGatewayAttachment'
    Properties:
      VpcId: !Ref VPC
      InternetGatewayId: !Ref InternetGateway
      
  RouteTableWeb: 
    Type: 'AWS::EC2::RouteTable'
    Properties:
      VpcId: !Ref VPC
      Tags:
      - Key: Name
        Value: !Sub ${EnvironmentName}-rt-web-${AWS::StackName}

  RouteTableWebDefaultIPv4: 
    Type: 'AWS::EC2::Route'
    DependsOn: InternetGatewayAttachment
    Properties:
      RouteTableId:
        Ref: RouteTableWeb
      DestinationCidrBlock: '0.0.0.0/0'
      GatewayId:
        Ref: InternetGateway
        
  RouteTableAssociationWebA:
    Type: 'AWS::EC2::SubnetRouteTableAssociation'
    Properties:
      SubnetId: !Ref SubnetWEBA
      RouteTableId:
        Ref: RouteTableWeb
        
  SubnetWEBA:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [ 0, !GetAZs '' ]
      CidrBlock: 10.20.80.0/20
      MapPublicIpOnLaunch: true
      AssignIpv6AddressOnCreation: false
      Tags:
        - Key: Name
          Value: !Sub sn-webA-${AWS::StackName}


```

### Section 2

Creates an EC2 instance using cfn-init, cfn-hup and userdata to install the codedeploy agent and ensure it is running

This section also creates the EC2 Security Group for http access

```
  EC2InstanceA:
    Type: AWS::EC2::Instance
    Metadata: #Using cfn-init 
      'AWS::CloudFormation::Init':
        config:
          packages:
            yum:
              htop: []
          files:
            /etc/cfn/cfn-hup.conf:
              content: !Sub |
                [main]
                stack=${AWS::StackId}
                region=${AWS::Region}
                interval=1
              mode: 000400
              owner: root
              group: root
            /etc/cfn/hooks.d/cfn-auto-reloader.conf:
              content: !Sub |
                [cfn-auto-reloader-hook]
                triggers=post.update
                path=Resources.EC2InstanceA.Metadata.AWS::CloudFormation::Init
                action=/opt/aws/bin/cfn-init --stack ${AWS::StackName} --resource EC2InstanceA --region ${AWS::Region}
                runas=root
          services:
            sysvinit:
              cfn-hup:
                enabled: true
                ensureRunning: true
                files:
                  - /etc/cfn/cfn-hup.conf
                  - /etc/cfn/hooks.d/cfn-auto-reloader.conf
              codedeploy-agent:
                enabled: true
                ensureRunning: true
    CreationPolicy: 
      ResourceSignal:
        Timeout: PT20M
    Properties:
      IamInstanceProfile: !Ref EC2InstanceProfile
      SubnetId: !Ref SubnetWEBA
      InstanceType: !FindInMap
        - EnvironmentMap
        - !Ref EnvironmentName
        - InstanceType
      ImageId: !Ref "LatestAmiId"
      SecurityGroupIds: 
        - !Ref InstanceSecurityGroup
      Tags:
        - Key: Name
          Value: !Join [ '-', [ !Ref EnvironmentName, codedeploy ] ]
        - Key: Environment
          Value: !Sub ${EnvironmentName}
        - Key: !Ref TagKeyA
          Value: !Ref TagValueA
      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash -xe
          #Install aws-cfn-bootstrap and ruby for codedeploy script
          yum install -y aws-cfn-bootstrap ruby
          #Install Codedeploy agent
          cd /tmp
          wget https://aws-codedeploy-${AWS::Region}.s3.amazonaws.com/latest/install
          chmod +x ./install
          ./install auto
          #Use cfn-init script to install files and packages
          /opt/aws/bin/cfn-init -v --stack ${AWS::StackId} --resource EC2InstanceA --region ${AWS::Region}
          #Send signal to Cloudformation
          /opt/aws/bin/cfn-signal --exit-code $? --stack ${AWS::StackId} --resource EC2InstanceA --region ${AWS::Region}
          

  InstanceSecurityGroup:
    Type: 'AWS::EC2::SecurityGroup'
    Properties:
      GroupDescription: Enable SSH access via port 22 and 80
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: '80'
          ToPort: '80'
          CidrIp: '0.0.0.0/0'
```

### Section 3

Creates CodeCommit repository to use as a source provider. Also creates S3 bucket to store pipeline artifacts

```  Repo:
    Type: AWS::CodeCommit::Repository
    Properties:
      RepositoryName: !Sub ${EnvironmentName}-repo-${AWS::StackName}
      RepositoryDescription: Dev repo
      Tags:
      -  Key: Name
         Value: !Sub ${EnvironmentName}-codecommit-${AWS::StackName}
          
#S3 Bucket
  ArtifactBucket:
    Type: AWS::S3::Bucket
    DeletionPolicy: Retain
    Properties:
      VersioningConfiguration:
        Status: Enabled
      Tags:
        - Key: UseWithCodeDeploy
          Value: true
```
### Section 4

Creates service roles to be assumed by CodePipeline, CodeDeploy and EC2

```
  CodePipelineServiceRole:
    Type: 'AWS::IAM::Role'
    Properties:
      AssumeRolePolicyDocument:
        Version: 2012-10-17
        Statement:
          - Effect: Allow
            Principal:
              Service: 
              - codepipeline.amazonaws.com
            Action:
              - 'sts:AssumeRole'
      Policies:
        - PolicyName: !Sub 'root-${AWS::Region}-${AWS::StackName}'
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Resource:
                  - !Sub 'arn:aws:s3:::${ArtifactBucket}/*'
                  - !Sub 'arn:aws:s3:::${ArtifactBucket}'
                Effect: Allow
                Action:
                  - s3:PutObject
                  - s3:GetObject
                  - s3:GetObjectVersion
                  - s3:GetBucketAcl
                  - s3:GetBucketLocation
              - Resource: "*"
                Effect: Allow
                Action:
                  - iam:PassRole
              - Resource: !GetAtt Repo.Arn
                Effect: Allow
                Action:
                  - codecommit:CancelUploadArchive
                  - codecommit:GetBranch
                  - codecommit:GetCommit
                  - codecommit:GetRepository
                  - codecommit:GetUploadArchiveStatus
                  - codecommit:UploadArchive
              - Resource: "*"
                Effect: Allow
                Action:
                  - codedeploy:CreateDeployment
                  - codedeploy:CreateDeploymentGroup
                  - codedeploy:GetApplication
                  - codedeploy:GetApplicationRevision
                  - codedeploy:GetDeployment
                  - codedeploy:GetDeploymentConfig
                  - codedeploy:RegisterApplicationRevision
    
  CodeDeployServiceRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Statement:
          - Sid: '1'
            Effect: Allow
            Principal:
              Service:
                - codedeploy.us-east-1.amazonaws.com
            Action: sts:AssumeRole
      Path: /
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole
                

  EC2Role:
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
        - arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy
  EC2InstanceProfile: 
    Type: 'AWS::IAM::InstanceProfile'
    Properties:
      Path: /
      Roles:
        - !Ref EC2Role


```

### Section 5

Creates the CodeDeploy Application and Deployment Group

```
  Application:
    Type: AWS::CodeDeploy::Application
    Properties:
      ApplicationName: !Sub ${EnvironmentName}-application
      ComputePlatform: Server #This is the option for EC2/On-prem
  DeploymentConfig:
    Type: AWS::CodeDeploy::DeploymentConfig
    Properties:
      MinimumHealthyHosts:
        Type: FLEET_PERCENT
        Value: '50'
  DeploymentGroup:
    Type: AWS::CodeDeploy::DeploymentGroup
    Properties:
      ApplicationName: !Ref Application
      AutoRollbackConfiguration:
        Enabled: 'true'
        Events:
          - DEPLOYMENT_FAILURE
      DeploymentConfigName: !Ref DeploymentConfig
      DeploymentGroupName: !Sub ${EnvironmentName}-${AWS::StackName}
      Ec2TagFilters:
        - Key: !Ref TagKeyA
          Value: !Ref TagValueA
          Type: KEY_AND_VALUE
      ServiceRoleArn: !GetAtt CodeDeployServiceRole.Arn
```

### Section 6

Creates the 2 stage pipeline (source, deploy) and specifies the bucket to store artifacts

```
 Pipeline:
    Type: AWS::CodePipeline::Pipeline
    Properties:
      RoleArn: !GetAtt CodePipelineServiceRole.Arn
      ArtifactStore:
        Type: S3
        Location: !Ref ArtifactBucket
      Stages:
      - Name: Source
        Actions:
        - Name: SourceAction
          ActionTypeId:
            Category: Source
            Owner: AWS
            Version: '1'
            Provider: CodeCommit
          Configuration:
            RepositoryName: !GetAtt Repo.Name
            BranchName: main
          RunOrder: 1
          InputArtifacts: []
          OutputArtifacts:
          - Name: SourceArtifact
      - Name: Deploy
        Actions:
        - Name: DeployAction
          ActionTypeId:
            Category: Deploy
            Owner: AWS
            Version: '1'
            Provider: CodeDeploy
          Configuration:
            ApplicationName: !Ref Application
            DeploymentGroupName: !Ref DeploymentGroup
          InputArtifacts:
            - Name: SourceArtifact
          RunOrder: 1


```
## Commands used

To validate the template: `aws cloudformation validate-template --template-body file://codepipeline.yml`

To deploy stack: `aws cloudformation create-stack --stack-name codepipeline-stack --template-body file://codepipeline.yml` --capabilities CAPABILITY_IAM

To check stack status and view outputs: `aws cloudformation describe-stacks --stack-name codepipeline-stack`

To delete stack: `aws cloudformation delete-stack --stack-name codepipeline-stack`

## Credits

[AWS docs referenced for project idea](https://docs.aws.amazon.com/codepipeline/latest/userguide/tutorials-simple-codecommit.html)
