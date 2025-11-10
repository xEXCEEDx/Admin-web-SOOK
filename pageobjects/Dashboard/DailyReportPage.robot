*** Settings ***
Library    SeleniumLibrary
Library    BuiltIn
Library    OperatingSystem
Library    String
Library    Collections
Resource   ../../Resources/Variables.robot


*** Variables ***
${BTN_SELECT_DASHBOARD}     //button[contains(text(),'เลือกแดชบอร์ด')]
${OPTION_DAILY_REPORT}      //li[contains(text(),'Daily Report')] 
${DROPDOWN_DAILY_REPORT}      //button[normalize-space()='Daily Report']
${BTN_REFRESH}        //*[normalize-space()='Refresh']
${DAILY_REPORT_FIRST_CELL}   //td[normalize-space()='1']
${BTN_CLEAR_ALL}     //button[normalize-space()='Clear All']
${Search_INPUT_DAILY}    //input[@placeholder='search']   

${BTN_EXPORT_EXCEL}    //button[normalize-space()='Export Excel']

# ───────── Search / Table Locators ───────── 
${Search_KFC}           //td[contains(normalize-space(.),'KFC')]
${Column_Count}         //tbody/tr
${Column_KFC}           //tbody/tr[td[5][contains(normalize-space(.),'KFC')]]
${Column_PAYMENT}       //td[contains(normalize-space(.),'Krungthai NEXT')]
${Column_Shopname}      //td[contains(normalize-space(.),'1:2 Coffee - Samyan Mitrtown')]

# ───────── Dropdown Filters ─────────
${BTN_PAYMENT_FILTER}   //p[normalize-space(.)='วิธีการชำระเงิน']/following::button[@aria-label='Open']
${OPTION_PAYMENT_NEXT}  //li[normalize-space(.)='Krungthai NEXT']

${BTN_SHOP_FILTER}      //p[normalize-space(.)='Shop Name']/following::button[@aria-label='Open']
${OPTION_SHOP_12COFFEE}     //li[normalize-space(.)='1:2 Coffee - Samyan Mitrtown']

${WIN_DOWNLOADS}    %{USERPROFILE}${/}Downloads
${DAILY_PATTERN}    daily_report*.xlsx



*** Keywords ***
Navigate to Daily Report Page
    Click Element    ${BTN_SELECT_DASHBOARD}
    Click Element    ${OPTION_DAILY_REPORT} 
    Wait Until Page Contains Element    ${DROPDOWN_DAILY_REPORT}    ${DEFAULT_TIMEOUT}   
    Log To Console    ✅ Navigated to Daily Report Page.


Click Daily Report Refresh 
    # 1) รอให้ปุ่ม Refresh มองเห็นและกดได้
    Wait Until Element Is Visible     ${BTN_REFRESH}    10s
    Wait Until Element Is Enabled     ${BTN_REFRESH}    10s
    Click Element                     ${BTN_REFRESH}
    Wait Quiet
    # 3) รอให้ข้อมูลตารางกลับมาแสดง
    Wait Until Page Contains Element  ${DAILY_REPORT_FIRST_CELL}    10s
    Log To Console    ✅ Refresh เสร็จสิ้น โหลดข้อมูลเรียบร้อย

Click Daily Report Clear All
    # 1) รอให้ปุ่ม Clear All มองเห็นและกดได้
    Wait Until Element Is Visible     ${BTN_CLEAR_ALL}    10s
    Click Element                     ${BTN_CLEAR_ALL}
    Wait Quiet
    # 3) รอให้ข้อมูลตารางกลับมาแสดง (ถ้ามี)
    Wait Until Page Contains Element  ${DAILY_REPORT_FIRST_CELL}    10s
    Log To Console    ✅ Clear All เสร็จสิ้น โหลดข้อมูลเรียบร้อย

Search Daily Report
    # search daily report 
    Click Element    ${Search_INPUT_DAILY}
    Input Text    ${Search_INPUT_DAILY}    KFC
    # รอให้ระบบค้นหาและโหลดข้อมูลใหม่
    Wait Quiet
    # รอให้ตารางข้อมูลปรากฏ (หรือผลลัพธ์โหลดเสร็จ)
    ${total}=      Get Element Count    ${Column_Count}
    ${all_kfc}=    Get Element Count    ${Column_KFC}
    Should Be Equal As Integers    ${all_kfc}    ${total}
    Log To Console    ✅ All ${total} rows Display "KFC" All.

Filter Daily Report
 #filter daily report by payment method
    Log To Console    ▶ Start filtering Daily Report...
    Click Element    ${BTN_PAYMENT_FILTER}
    Wait Until Page Contains Element    ${OPTION_PAYMENT_NEXT}
    Click Element    ${OPTION_PAYMENT_NEXT}
    Wait Quiet
    ${total_payment}=    Get Element Count    ${Column_Count}
    ${all_payment}=      Get Element Count    ${Column_PAYMENT}
    Should Be Equal As Integers    ${all_payment}    ${total_payment}
    Log To Console    ✅ All ${total_payment} rows display "Krungthai NEXT" correctly.

  #filter daily report by shop name
    Log To Console    ▶ Start filtering Daily Report by Shop Name...
    Click Element    ${BTN_SHOP_FILTER}   
    sleep   3s
    Wait Until Page Contains Element    ${OPTION_SHOP_12COFFEE}
    Click Element    ${OPTION_SHOP_12COFFEE}
    Wait Quiet
    ${total_Shopname}=    Get Element Count    ${Column_Count}
    ${all_shopname}=      Get Element Count    ${Column_Shopname}
    Should Be Equal As Integers    ${all_shopname}    ${total_Shopname}
    Log To Console    ✅ All ${total_shopname} rows display "Shopname and payment" correctly.



Clear All Filters
    Click Element    ${BTN_CLEAR_ALL}
    Wait Quiet


#Export to excel

Export Daily Report To Excel
    Log To Console    ▶ Start exporting Daily Report to Excel...
    # Assuming there is a button to export to excel
    ${excel_path}=    Verify Any Excel Appeared daily_report
    Log To Console    ✅ Export Daily Report to Excel name ${excel_path} successfully

Verify Any Excel Appeared daily_report
  # 1) จำเวลาและรายชื่อไฟล์ daily_report* ก่อนกด
    ${start}=     Get Time    epoch
    @{before}=    List Files In Directory    ${WIN_DOWNLOADS}    pattern=${DAILY_PATTERN}

    # 2) กดปุ่ม Export (เปลี่ยน locator ให้ตรงของคุณ)
    Wait Until Element Is Visible    ${BTN_EXPORT_EXCEL}    20s
    Click Element                    ${BTN_EXPORT_EXCEL}

    # 3) รอให้มีไฟล์ใหม่จริง (สูงสุด 60s ตรวจทุก 1s)
    ${path}=    Wait Until Keyword Succeeds
    ...         60s    1s
    ...         _find_new_file_by_pattern_since
    ...         ${WIN_DOWNLOADS}    ${DAILY_PATTERN}    ${start}    @{before}

    # 4) กันไฟล์ว่าง/ยังโหลดไม่จบ
    ${size}=    Get File Size    ${path}
    Should Be True    ${size} > 0    msg=Downloaded file size is 0

    Log To Console    ✅ New Excel downloaded: ${path}
    RETURN    ${path}

_find_new_file_by_pattern_since
    [Arguments]    ${dir}    ${pattern}    ${start_epoch}    @{before}
    @{now}=    List Files In Directory    ${dir}    pattern=${pattern}

    # เอาความต่างระหว่าง now กับ before (ถ้าไม่มีความต่าง ให้ใช้ now ทั้งก้อน เพราะบางระบบเขียนทับชื่อเดิม)
    @{diff}=    Evaluate    [f for f in $now if f not in $before]
    IF    len(${diff}) == 0
        @{diff}=    Set Variable    @{now}
    END

    ${newest}=    Set Variable    NONE
    ${latest}=    Set Variable    -1

    FOR    ${f}    IN    @{diff}
        ${p}=     Set Variable    ${dir}${/}${f}
        ${ts}=    Get Modified Time    ${p}    epoch
        # ต้องใหม่กว่าเวลาที่เริ่มกด และใหม่กว่าตัวที่ดีที่สุดปัจจุบัน
        IF    ${ts} > ${start_epoch} and ${ts} > ${latest}
            ${newest}=    Set Variable    ${p}
            ${latest}=    Set Variable    ${ts}
        END
    END

    Should Not Be Equal    ${newest}    NONE    msg=No new daily_report file found after export
    RETURN    ${newest}

Filter Transaction Monitoring
    Click Element    ${DROPDOWN_FILTER_STATUS}
    Wait Until Element Is Visible    ${OPTION_STATUS_SUCCESS}    10s
    Click Element    ${OPTION_STATUS_SUCCESS}
    Wait Quiet
    ${total_status}=    Get Element Count    ${Column_Count}
    ${all_status} =      Get Element Count    ${Column_status_success}
    Should Be Equal As Integers    ${total_status}    ${all_status}    msg=Not all transactions have status 'จัดส่งสำเร็จ'   
    Log To Console    ✅ All ${total_status} row display Status 'จัดส่งสำเร็จ' successfully.