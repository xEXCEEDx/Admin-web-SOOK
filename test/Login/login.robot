*** Settings ***
Resource         ../../resources/Variables.robot
Resource         ../../pageobjects/AdminLoginPage.robot
Test Setup        Open Browser To Login Page

*** Keywords ***
Open Browser To Login Page
    Open Browser    ${LOGIN_URL}    ${BROWSER}
    Maximize Browser Window

*** Test Cases ***
Scenario: Sanity - Admin Login Works
    Perform Admin Login
    Location Should Contain    /dashboard
    Log To Console    ✅ Admin login works correctly.
