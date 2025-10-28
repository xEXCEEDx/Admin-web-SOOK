*** Settings ***
Library    SeleniumLibrary
Resource   ../../Resources/Keywords.robot
Resource   ../../pageobjects/DashboardPage.robot

# Setup และ Teardown
Test Setup       Open Browser And Login Admin

Test Teardown    Close Browser Session


*** Test Cases ***
Scenario: Dashboard - Daily Report
    [Tags]    Smoke    Dashboard
    # 1. Navigate to Daily Report
    Navigate To Daily Report Page


    # 2. Click Refresh and wait for data reload
    Click Daily Report Refresh 
    
    
    #export to excel
    Export Daily Report To Excel

    # 3. Click Clear all and observe results
    Click Daily Report Clear All 

    # 4. Filter 
    Filter Daily Report 

     ### clear all filters before search ###
    Clear All Filters

    # 5. Search 
    Search Daily Report 

    # 6.Viewing Daily Report
    Viewing Options    5    10    25    30    50

    # 7. pagination
    Pagination Admin
    
    





    Log To Console    ✅ Test Completed: Daily Report Refresh successful.
