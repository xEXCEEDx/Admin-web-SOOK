*** Settings ***
Library    SeleniumLibrary
Library    BuiltIn
Resource   ../../Resources/Variables.robot
Resource   ../../Resources/Keywords.robot

*** Variables ***
${BTN_SELECT_DASHBOARD}                //button[contains(normalize-space(.),'เลือกแดชบอร์ด')]
${OPTION_TRANSACTION_MONITORING}       //li[contains(normalize-space(.),'Transaction Monitoring')]
${DROPDOWN_TRANSACTION_MONITORING}     //button[normalize-space()='Transaction Monitoring']
${STATUS_DEFAULT_CHIP_XPATH}        //span[contains(@class,'MuiChip-label')][normalize-space()='รอร้านรับออเดอร์']
${BTN_REFRESH_TRANSACTION}        //*[normalize-space()='Refresh']
${BTN_CLEAR_ALL}        //button[normalize-space()='Clear All']
${BTN_EXPORT_EXCEL}    //button[normalize-space()='Export Excel']

${BTN_EXPORT_TM}      xpath=//button[.//text()[normalize-space(.)='Export Excel']]
${TM_PATTERN}         transaction_monitoring_*.xlsx
${WIN_DOWNLOADS}    %{USERPROFILE}${/}Downloads


${OPTION_STATUS_CANCEL}    //span[contains(text(),'ยกเลิก')]
${Column_Count}         //tbody/tr
${Column_status}       //td[contains(normalize-space(.),'ยกเลิก')]
${DROPDOWN_FILTER_STATUS}    //button[@title='Open']

${Search_INPUT_TM}    //input[@placeholder='search']
*** Keywords ***
Navigate To Transaction Monitoring Page
    Click Element    ${BTN_SELECT_DASHBOARD}
    Click Element    ${OPTION_TRANSACTION_MONITORING}
    Wait Until Element Is Visible    ${DROPDOWN_TRANSACTION_MONITORING}    ${DEFAULT_TIMEOUT}
    Log To Console    ✅ Navigated to Transaction Monitoring Page.

Default filter Transaction Monitoring
    Wait Until Element Is Visible    ${STATUS_DEFAULT_CHIP_XPATH}    ${DEFAULT_TIMEOUT}
    Page Should Contain Element      ${STATUS_DEFAULT_CHIP_XPATH}
    Log To Console    ✅ Default filter applied on Transaction Monitoring Page.

Click TransactionMonitoring Clear All
    Wait Until Element Is Visible     ${BTN_CLEAR_ALL}    10s
    Click Element                     ${BTN_CLEAR_ALL}
    Wait Quiet
    Log To Console    ✅ Clicked Clear All on Transaction Monitoring Page.
    
Refresh Transaction Monitoring Page
    Wait Until Element Is Visible     ${BTN_REFRESH_TRANSACTION}    10s
    Click Element                     ${BTN_REFRESH_TRANSACTION}
    Wait Quiet
    Log To Console    ✅ Refreshed Transaction Monitoring Page.
    
Export Transaction Monitoring To Excel
    Log To Console    ▶ Start exporting Transaction Monitoring to Excel...
    ${excel_path}=    Verify Any Excel Appeared Transaction Monitoring
    Log To Console    ✅ Export Transaction Monitoring Excel: ${excel_path}

Verify Any Excel Appeared Transaction Monitoring
    # 1) จดเวลาและไฟล์ที่มีอยู่ก่อนกด
    ${start}=     Get Time    epoch
    @{before}=    List Files In Directory    ${WIN_DOWNLOADS}    pattern=${TM_PATTERN}

    # 2) กดปุ่ม Export
    Wait Until Element Is Visible    ${BTN_EXPORT_TM}    20s
    Click Element                    ${BTN_EXPORT_TM}

    # 3) รอจนมีไฟล์ใหม่จริง (เช็คทุก 1s สูงสุด 60s)
    ${path}=    Wait Until Keyword Succeeds
    ...         60s    1s
    ...         _find_new_file_by_pattern_since
    ...         ${WIN_DOWNLOADS}    ${TM_PATTERN}    ${start}    @{before}

    # 4) กันไฟล์ว่าง/ยังโหลดไม่จบ
    ${size}=    Get File Size    ${path}
    Should Be True    ${size} > 0    msg=Downloaded file size is 0

    Log To Console    ✅ New TM Excel downloaded: ${path}
    RETURN    ${path}

_find_new_file_by_pattern_since
    [Arguments]    ${dir}    ${pattern}    ${start_epoch}    @{before}
    @{now}=    List Files In Directory    ${dir}    pattern=${pattern}
    @{diff}=   Evaluate    [f for f in $now if f not in $before]
    IF    len(${diff}) == 0
        @{diff}=    Set Variable    @{now}
    END
    ${newest}=    Set Variable    NONE
    ${latest}=    Set Variable    -1
    FOR    ${f}    IN    @{diff}
        ${p}=     Set Variable    ${dir}${/}${f}
        ${ts}=    Get Modified Time    ${p}    epoch
        IF    ${ts} > ${start_epoch} and ${ts} > ${latest}
            ${newest}=    Set Variable    ${p}
            ${latest}=    Set Variable    ${ts}
        END
    END
    Should Not Be Equal    ${newest}    NONE    msg=No new file found after export
    RETURN    ${newest}


filter Transaction Monitoring By Status

    Click Element    ${DROPDOWN_FILTER_STATUS}
    Wait Until Element Is Visible    ${OPTION_STATUS_CANCEL}    10s
    Click Element    ${OPTION_STATUS_CANCEL}
    Wait Quiet
    ${total_status}=    Get Element Count    ${Column_Count}
    ${all_status}=      Get Element Count    ${Column_status}
    Should Be Equal As Integers    ${total_status}    ${all_status}    msg=Not all transactions have status 'ยกเลิก'
    Log To Console    ✅ All ${all_status} row display Status 'ยกเลิก' successfully.

Search Transaction Monitoring
    