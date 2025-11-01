*** Settings ***
Library    SeleniumLibrary
Resource   ../../Resources/Keywords.robot
Resource   ../../pageobjects/Dashboard/TransactionMonitoringPage.robot
Library    BuiltIn
Library    OperatingSystem
Library    String
Library    Collections
Test Setup       Open Browser And Login Admin
Test Teardown    Close Browser Session

*** Test Cases ***
Scenario: Dashboard - Transaction Monitoring
    [Tags]    Smoke    Dashboard    TransactionMonitoring

    Navigate To Transaction Monitoring Page

    Default filter Transaction Monitoring
    
    Click Transaction Monitoring Clear All

    # Refresh Transaction Monitoring Page

    # Export Transaction Monitoring To Excel

    Filter Transaction Monitoring By Status
    
    # Search Transaction Monitoring

    

    # Filter Transaction Monitoring By Channel

    # Clear Transaction Monitoring Filters

    # Viewing Options    5    10    25    30    50

    # Pagination Admin

    # Log To Console    ✅ Test Completed: Transaction Monitoring workflow successful.