# 1. Atlantis Lab Time
In this lab, we'll use Terraform to deploy an EC2 instance preconfigured with Atlantis' Dockerfile. We'll then connect to the EC2 instance, install Atlantis using the Docker image method, and set up webhook integration with our GitLab repository.The access token will allow Atlantis to access the repository, while the webhook configuration will define the events that Atlantis will monitor. Finally, we'll create a pull request to observe Atlantis in action.

Follow the step-by-step below to complete this Lab, hope you enjoy and learn something new from this!

# 2. Git Lab Time

We have pre configured and provisioned EC2 instnce and Gitlab setup already to save time in playground session.
So no need to perform Gitlab setup and based on playground links you can directly connect Gitlab and follow the Token integration and Webhook integration.



2.1 Once you start click the below link giving your correct user name details it will display all your access links .

Lab environment: https://lab.devopsplayground.org/


2.1.1 Log into your GitLab instance with provided login details.
You will find user and password details in VSCODE link under the file called gitlab_cred.txt.

![Gitlab Credentials](/image/gitlab_cred.png)

Login Page of Gitlab

![Login page of gitlab](/image/13_gitlab.png)

2.1.2 Create a new repo within Gitlab

![Gitlab login page](/image/1_gitlab.png)

2.1.3 Fill out the name of the repo as per your requirement

![Create a new repo](/image/2_gitlab.png)

2.1.4 First we need to create an access token for Atlantis to use

![Create new access token](/image/3_gitlab.png)

2.1.5 Name the token "atlantis" to clearly indicate its purpose to team members understand. Assign it the Developer role and select the "api" to grant the required permissions.

![Settings for access token](/image/4_gitlab.png)


2.1.6 Once created, ensure to make a note of the token and save it for future reference to setup variables.

![Take note of token secret](/image/4_1_gitlab.png)



2.2.1 Next we have to create and configure Webhook

2.2.2 Before you create a webhook with EC2 IP you have to enable Network outbound requests .

![Network Outbound Requests](/image/Network_outbound_requests.png)
![Network outbound requests](/image/Network_outbound.png)

2.2.3 Click save changes and go to project  settings Webhook option.

and then follow the stpes how you have configured  access token like same way.



```
    - URL: http://ec2-atlantis-server-public-ip:4000/events 
    - Name: alantis-webhook (It is optional and can be anything you want)
    - Secret Token: atlantis123 (This token will be used for the Docker run command later, so should make a note of it)
    - Trigger:
        - Push Events
        - Comments
        - Merge Request Events
    - Keep SSL enabled
```

![Gitlab Webhook settings](/image/5_gitlab.png)

2.2.3.a  For URL you can look at in atlantis-instance.txt

![Gitlab Webhook config part 1](/image/5_1_gitlab.png)

![Gitlab Webhook config part 2](/image/5_2_gitlab.png)

You can see webhook logs here.

![Webhook playload event logs](/image/Webhook_logs.png)

2.2.4 Set repo URL and hostname environment variables and make sure that REPO URL DOES NOT contain http.

At the same time  make sure hostname should contain http.



Note: All setting up the environmenet variable steps should be performed in Atlantis Server.

2.2.5 Set the environment variable using the below provided commands:

```
export ACCESS_TOKEN=YOUR_TOKEN

```

e.g. export ACCESS_TOKEN=glpat-abc123def456

2.2.6 To check if you have assigned the value correctly, run 'echo $ACCESS_TOKEN'. This should return the token you just generated.

2.2.7 Now set the environment variable for webhook secret as well.
The secret will be defined by your own and make a note to export .

```
export WEBHOOK_SECRET=YOUR_WEBHOOK_SECRET

Repo URL:
export REPO_URL=YOUR_REPO_URL 

e.g. export REPO_URL=<panda-name>.devopsplayground.org/root/atlantis-demo

Hostname:
export HOSTNAME=YOUR_HOSTNAME

e.g. export HOSTNAME=http://<panda-name>.devopsplayground.org
```

![Gitlab repo home](/image/6_gitlab.png)

Reaching this point indicates that you have successfully configured Atlantis to accept connections and events from Gitlab. Next section we will be launching Atlantis with the environment variables we defined earlier. 


## 3.Atlantis Install and Set Up

In this section, we will be installing Atlantis from within the CLI using Docker. There should be a Dockerfile created already which will install the latest version of Atlantis.
Commands below will build a image named atlantis with the Dockerfile supplied and run the atlantis service on port 4000:4141. The environment we been assigning is used here to configure atlantis on where to connect and give atlantis the access to our repo.

3.1 To execute docker file to swith to working directory -/home/playground/workdir/

Then build a atlantis docker image using the below command.

```
cd ~/workdir
sudo docker build -t atlantis .
```
![Atlantis docker image build](/image/1_atlantis.png)

```
sudo docker run -itd -p 4000:4141 --name atlantis atlantis server --automerge --autoplan-modules --gitlab-user=root --gitlab-token=$ACCESS_TOKEN --repo-allowlist=$REPO_URL --gitlab-webhook-secret=$WEBHOOK_SECRET --gitlab-hostname=$HOSTNAME
```

![Running Atlantis with built image above](/image/2_atlantis.png)


3.1.2 Once Atlantis service is started, you can access it by going to your EC2 IP on port 4000

![Atlantis homepage](/image/3_atlantis.png)

Next we need to provide Atlantis  access to AWS by providing the AWS User Access key and Secret Access Key.  IAM user is provided with minimum required permissions for Atlantis to work here.

3.1.3 To get AWS accesskey and secret key values grep it with the below command in Atlantis server

```
env |grep AWS
```

3.1.4 The below exec command allows you to run commands within an already deployed container which is atlantis container.

```
sudo docker exec -it atlantis /bin/sh
```

3.1.5 Then with the Vim editor we update the credentials within .aws folder

```
vi /home/atlantis/.aws/credentials
```

3.1.6 Press I within the Vim editor to go into input mode and paste in the block below:

```
[default]
aws_access_key_id = "ACCESS_KEY"
aws_secret_access_key = "SECRET_ACCESS_KEY"
```

3.1.7 Once that is done, we press ESC to exit the input mode and press :wq to save the changes (w for write and q for quit)

![Adding AWS Creds for Atlantis](/image/4_atlantis.png)

## 4.Testing Atlantis

Everything should be fully set up and ready to output your terraform plan onto pull request for everyone who has access to your repo to see. 


4.1 First create a testing branch and try to upload a testing Terraform infrastructure and have Atlantis output  plan.
You can get sample terraform infra files availble under test-atlantis folder.

4.1.a Also for terraform provider token you can get it in VSCODE link under the file called terraform-token.txt

![terraform provider token](/image/terraform_provider_token.png)

![Creating a new repo within Gitlab](/image/atlantis_testing_branch.png)

![Upload test files into testing_branch](/image/upload_files_testing_branch.png)

4.1.b Once files uploaded then you can create merge request 

![Create merge request to testing atlantis](/image/6_atlantis.png)

4.1.2 To run Terraform plan, we need to submit atlantis plan in the comment. We know it is working by the Eyes emote reacted on our atlantis plan comment. You can change the emote which is used by atlantis within configuration file.

![Shows atlantis plan working within pull request](/image/7_atlantis.png)

From atlantis homepage, you can see all the previous plans/apply with an screenshot attached showing the native terraform output

![Atlantis homepage shows output](/image/atlantis_Workspace_web_plan_apply.png)

Once the plan is done and without error, the output will be commented within the pull request/merge request

![Output of Atlantis plan](/image/atlantis_output2.png)

## 5. Working with multiple terraform workspaces

Atlantis doesn't just support linear workspaces but you can configure within the atlantis.yaml file to accept multiple workspaces

Within the atlantis.yaml file will look something like this. 
You can get this atlantis.yaml file from  our atlantis-automation Github repository.

```
version: 3
automerge: true
abort_on_execution_order_fail: true
autodiscover:
  mode: auto
projects:
- name: atlantis-dev
  branch: /main/
  dir: ./terraform
  workspace: dev
  terraform_version: v1.6.1
  autoplan:
    enabled: false
- name: atlantis-prod
  branch: /main/
  dir: ./terraform
  workspace: prod
  terraform_version: v1.6.1
  autoplan:
    enabled: false
```

5.1 The above config defines 2 projects, atlantis-dev and atlantis-prod. This simulates the Dev environment and Prod environment.
To tell Atlantis which workspace you want to use, you can use the -w flag during the atlantis plan or if you have defined a project within the atlantis.yaml, you can use the -p flag instead and it will pick up the configuration defined within the yaml file.

```
atlantis plan -w dev
```
![Atlantis plan with 2 different workspace](/image/10_atlantis.png)

![Atlantis workspace output on Gitlab PR](/image/Atlantis_dev_prod_workspace.png)

![Atlantis lock on different workspaces](/image/atlantis_workspace_lock_dev_prod.png)

![Atlantis webpage output](/image/atlantis_webpage.png)


5.1.2 Make sure that workspaces are properly cleaned up after the completion of pull requests, helping to maintain a clean and manageable infrastructure environment.

5.1.3 Using the -destroy Flag you can destroy your atlantis resources 

Example
To perform a destructive plan that will destroy resources you can use the -destroy flag like this:

```
atlantis plan -- -destroy
atlantis plan -d dir -- -destroy
```

NOTE

The -destroy flag generates a destroy plan, If this plan is applied it can result in data loss or service disruptions. Ensure that you have thoroughly reviewed your Terraform configuration and intend to remove the specified resources before using this flag.

Atlantis destroy plan output from Gitlab page

![atlantis plan destroy](/image/atlantis_destroy_1.png)

![atlantis plan destory output](/image/atlantis_destroy_2.png)

Destroy output from Atlantis web page view below.

![Webpage destory output](/image/atlantis_destory_output_on_atlantis_web.png)

Thank you
 
![Thank you](/image/Thankyou.png)
