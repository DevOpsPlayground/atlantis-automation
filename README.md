# Atlantis Lab Time
In this Lab we are going to use Terraform to deploy a EC2 instance with Atlantis' Dockerfile already created for us.
We will be connecting into the EC2 instance and install Atlantis via the Docker Image way and get hands on with webhooking Atlantis to our GitLab repository,
follow by creating a pull request to see Atlantis in action.

Follow the step-by-step below to complete this Lab, hope you enjoy and learn something new from this!

## Set up Gitlab
In this section we will be going through Gitlab to create a repo, access token and webhook configuration as a pre-requesit for Atlantis. Token will be used for Atlantis to access the repo and webhook secrets will define what event Atlantis will be listening out for.

Log into your GitLab instance with provided login details

1. Create a new repo within Gitlab
![Gitlab login page](/image/1_gitlab.png)

2. Fill out the name of the repo
![Create a new repo](/image/2_gitlab.png)

3. First we need to create an access token for Atlantis to use
![Create new access token](/image/3_gitlab.png)

4. Give the name of Token atlantis so team members know what the token is used for. Give it Developer Role and select api to give it permissions. Once the Token is created, make note of it and save it for later. Set the environment variable with below command e.g. export ACCESS_TOKEN=glpat-abc123def456
```
export ACCESS_TOKEN=YOUR_TOKEN

```
To check if you have assigned the value correctly, run 'echo $ACCESS_TOKEN'. This should return the token you just generated

![Settings for access token](/image/4_gitlab.png)
![Take note of token secret](/image/4_1_gitlab.png)

5. Create a webhook with EC2 IP. Just like with access token, set the environment variable for webhook secret too.
The secret will be defined by you.
```
export WEBHOOK_SECRET=YOUR_WEBHOOK_SECRET
```
    - URL: http://ec2-public-ip:4000/events 
    - Name: alantis-webhook (It is optional and can be anything you want)
    - Secret Token: atlantis123 (This token will be used for the Docker run command later, so should make a note of it)
    - Trigger:
        - Push Events
        - Comments
        - Merge Request Events
    - Keep SSL enabled
![Gitlab Webhook settings](/image/5_gitlab.png)
![Gitlab Webhook config part 1](/image/5_1_gitlab.png)
![Gitlab Webhook config part 2](/image/5_2_gitlab.png)

6. Set repo URL and hostname environment variables. 
Make sure Repo URL DOES NOT contain http.
Make sure hostname DOES contain http.

```
Repo URL:
export REPO_URL=YOUR_REPO_URL 

e.g. export REPO_URL=18.134.152.108/root/atlantis-test

Hostname:
export HOSTNAME=YOUR_HOSTNAME

e.g. export HOSTNAME=http://18.134.152.108
```
![Gitlab repo home](/image/6_gitlab.png)

Reaching here means you have fully set up Alantis to accept connections and events from Gitlab. Next section we will be launching Atlantis with the environment variables we defined earlier. 


## Atlantis Install and Set Up
In this section, we will be installing Atlantis from within the CLI using Docker. There should be a Dockerfile created already which will install the latest version of Atlantis.
Commands below will build a image named atlantis with the Dockerfile supplied and run the atlantis service on port 4000:4141. The environment we been assigning is used here to configure atlantis on where to connect and give atlantis the access to our repo.

```
sudo docker build -t atlantis .

sudo docker run -itd -p 4000:4141 --name atlantis atlantis server --automerge --autoplan-modules --gitlab-user=root --gitlab-token=$ACCESS_TOKEN --repo-allowlist=$REPO_URL --gitlab-webhook-secret=$WEBHOOK_SECRET --gitlab-hostname=$HOSTNAME
```

![Atlantis docker image build](/image/1_atlantis.png)
![Running Atlantis with built image above](/image/2_atlantis.png)


Once Atlantis service is started, you can access it by going to your EC2 IP on port 4000
![Atlantis homepage](/image/3_atlantis.png)

Next we need to provide Atlantis the access to AWS by providing the AWS User Access key and Secret Access Key. A IAM user is provided with minimum required permissions for Atlantis to work here.

We first exec into the atlantis
```
sudo docker exec -it atlantis /bin/sh
```

Then with the Vim editor we update the credentials within .aws folder
```
vi /home/atlantis/.aws/credentials
```

Press I within the Vim editor to go into input mode and paste in the block below:
```
[default]
aws_access_key_id = "ACCESS_KEY"
aws_secret_access_key = "SECRET_ACCESS_KEY"
```

Once that is done, we press ESC to exit the input mode and press :wq to save the changes (w for write and q for quit)

![Adding AWS Creds for Atlantis](/image/4_atlantis.png)

## Testing Atlantis

Everything should be fully set up and ready to output your terraform plan onto pull request for everyone who has access to your repo to see. Lets try and upload a testing Terraform infrastructure and have Atlantis output our plan.

![Creating a new repo within Gitlab](/image/5_atlantis.png)

![Create merge request to testing atlantis](/image/6_atlantis.png)

To run Terraform plan, we need to submit atlantis plan in the comment. We know it is working by the Eyes emote reacted on our atlantis plan comment. You can change the emote which is used by atlantis within configuration file.
![Shows atlantis plan working within pull request](/image/7_atlantis.png)

From atlantis homepage, you can see all the previous plans/apply with an screenshot attached showing the native terraform output
![Atlantis homepage shows output](/image/8_atlantis.png)

Once the plan is done and without error, the output will be commented within the pull request/merge request
![Output of Atlantis plan](/image/9_atlantis.png)

## Working with multiple terraform workspaces
Atlantis doesn't just support linear workspaces but you can configure within the atlantis.yaml file to accept multiple workspaces

Within the atlantis.yaml file will look something like this:
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

The config above defines 2 projects, atlantis-dev and atlantis-prod. This simulates the Dev environment and Prod environment.
To tell Atlantis which workspace you want to use, you can use the -w flag during the atlantis plan or if you have defined a project within the atlantis.yaml, you can use the -p flag instead and it will pick up the configuration defined within the yaml file.
```
atlantis plan -w dev
```
![Atlantis plan with 2 different workspace](/image/10_atlantis.png)