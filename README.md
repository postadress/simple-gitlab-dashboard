# About
This project checks states from pipelines in GitLab projects. There report that is generated represents rather a simple dashboard.

# How to use it

## Clone repository
Clone this repository. 

## Configure `config/projects.csv`
Add projects from your GitLab instance to `config/projects.csv`. First column is project id, which is the last part of your project's url. 2nd column is project id which can be found on start page of your project. 3rd column is branch of your project you would like the pipeline of checked.

## Install robot environment
Run `pip install -r install/requirements.txt` in order to install all dependencies required by this robot task.

## Generate API Token
You need to generate an API token in your GitLab instance in order to access the REST API: https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html

## Run task
`robot -v GITLAB_URL:<url_to_gitlab_projects> -v API_TOKEN:<your_generated_api_token> dashboard.robot`

## Interpreting the report
Tasks, tags, documentation: everything in the report has been generated dynamically. Documentation of a repository is collected from GitLab, tags represent the pipeline status. 

## How to make pending pipeline not break report
Every pipeline that does not have state (or tag) `success` is considered a failure. However, there are more states, such as `pending`, `skipped` and most common `running`. You can label those states as harmless by useing the `--non-critical` or `-n` switch:
```
robot -n pending -n skipped -n running dashboard.robot
```
