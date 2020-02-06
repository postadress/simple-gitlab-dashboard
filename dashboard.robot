*** Comments ***
This task suite is based on csv file containing connection data for gitlab projects.
From each row of the csv file a task is generated evaluating information from the gitlab projects pipeline data.

In this example, report is green when no pipeline checked is in failure state. Any pipeline that is in another state
than `success` is marked as failed. You can use the `--non-critical` (or `-n`) switch to label tags of states that should not break the report:

robot -n pending -n canceled -n running -n skipped dashboard.robot

*** Settings ***
Documentation    Checks states from gitlab pipelines
Library    DataDriver    file=config/projects.csv    reader_class=generic_csv_reader   
Library    RequestsLibrary
Library    String
Task Template    Get pipeline status
Suite Setup    Open Session
Suite Teardown    Delete All Sessions

*** Variables ***
${GITLAB_URL}    
${SESSION_NAME}    gitlab
${API_TOKEN}   

*** Tasks ***
${project} : ${branch}    ${project}    ${id}    ${branch}

*** Keywords ***
Get pipeline status
    [Arguments]    ${project}    ${id}    ${branch}    
    ${project}    Get project    ${id}
    ${pipeline}    Get pipeline    ${id}    ${branch}
    Set Test Documentation    ${project}[description]
    Set Tags    ${pipeline}[status]
    Run Keyword If    not 'success' == '${pipeline}[status]'    Fail    ${pipeline}[web_url]
    Set Test Message    ${pipeline}[web_url]
    
Validate Configuration
    Should Not Be Empty    ${GITLAB_URL}    No url for gitlab defined. Please provide url on command line: -v GITLAB_URL:<url_to_gitlab>
    Should Not Be Empty    ${API_TOKEN}    No api token for gitlab provided. Please add api token on command line: -v API_TOKEN:<api_token>

Open Session
    Validate Configuration
    ${header}    Create Dictionary    PRIVATE-TOKEN    ${API_TOKEN}
    Create Session    ${SESSION_NAME}    ${GITLAB_URL}    headers=${header}        
    
Get pipeline
    [Documentation]     Collects data from specific branch via GitLab API: https://docs.gitlab.com/ee/api/pipelines.html#list-project-pipelines
    [Arguments]    ${id}    ${branch}
    ${endpoint}    Set Variable    /projects/${id}/pipelines
    ${params}    Create Dictionary    ref    ${branch}
    ${response}    Get Request    ${SESSION_NAME}    ${endpoint}    params=${params}
    Should Be Equal As Integers   200    ${response.status_code}    Connection to REST Api '${GITLAB_URL}/${endpoint}' failed:\t${response.reason}:\n${response.content}    
    ${pipelines}    Json2dict    ${response.content}
    [Return]    ${pipelines}[0]
    
Get project
    [Documentation]    Collects project information from GitLab API: https://docs.gitlab.com/ee/api/projects.html
    [Arguments]    ${id}
    ${endpoint}    Set Variable    /projects/${id}
    ${response}    Get Request    ${SESSION_NAME}    ${endpoint}
    Should Be Equal As Integers   200    ${response.status_code}    Connection to REST Api '${GITLAB_URL}/${endpoint}' failed:\t${response.reason}:\n${response.content}
    ${project}    Json2dict    ${response.content}
    [Return]    ${project}
    
Json2dict
    [Arguments]    ${object}    ${encoding}=utf-8
    # JSON Module uses default encoding from OS which messes JSON formats up on windows
    ${content_utf8}    String.Decode Bytes To String    ${object}    ${encoding}        
    ${dict}    Evaluate    json.loads('${content_utf8}')    json
    [Return]    ${dict}
