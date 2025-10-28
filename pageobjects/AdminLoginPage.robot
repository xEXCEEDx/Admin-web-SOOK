*** Settings ***
Library    SeleniumLibrary
Resource   ../Resources/Variables.robot

*** Variables ***
${FIELD_USERNAME}       id:username
${FIELD_PASSWORD}       id:password
${BTN_LOGIN}            xpath=//button[normalize-space(.)="เข้าสู่ระบบ"]
${DASHBOARD_TEXT}       ไม่พบแดชบอร์ดหรือยังไม่ได้เลือก

*** Keywords ***
Open Browser To Login Page
    Open Browser    ${LOGIN_URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Timeout    ${DEFAULT_TIMEOUT}

# ✅ ปรับตรงนี้ให้มีค่า default (ไม่ต้องส่ง argument ทุกครั้ง)
Perform Admin Login
    [Arguments]    ${username}=${ADMIN_USERNAME}    ${password}=${ADMIN_PASSWORD}
    Input Text      ${FIELD_USERNAME}    ${username}
    Input Password  ${FIELD_PASSWORD}    ${password}
    Click Button    ${BTN_LOGIN}
    Wait Until Page Contains    ${DASHBOARD_TEXT}    ${DEFAULT_TIMEOUT}


Close Admin Browser
    Close Browser
