*** Settings ***
Library    SeleniumLibrary
Resource   ./Variables.robot
Resource   ../pageobjects/AdminLoginPage.robot

*** Keywords ***
Open Browser And Login Admin
    Open Browser To Login Page
    Perform Admin Login
    Log To Console    ✅ Login successful and ready for tests.

# ✅ เปลี่ยนชื่อเป็น Close Browser Session
Close Browser Session
    Close Admin Browser
    Log To Console    ✅ Browser closed.

# Wait Quiet: รอให้ Spinner หายไป 
Wait Quiet
    Run Keyword And Ignore Error    Wait Until Element Is Visible       ${SPINNER}    10s
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible   ${SPINNER}   20s


#Viewing Options
Set Viewing
    [Arguments]    ${n}
    ${opt}=    Set Variable    xpath=//*[@role='listbox']//li[normalize-space(.)='${n}']
    Wait Until Element Is Visible    ${VIEWING_BTN}    10s
    Scroll Element Into View    ${VIEWING_BTN}
    Click Element   ${VIEWING_BTN}
    Wait Until Element Is Visible    ${opt}    5s
    Click Element    ${opt}
    Wait Quiet

Assert Viewing Summary
    [Arguments]    ${n}
    ${text}=    Get Text    ${SUMMARY}
    Should Contain    ${text}    1 to ${n} of
    Log To Console    ✅ Viewing ${n}: "${text}"

Viewing Options
    [Arguments]    @{sizes}    # เช่น 5 10 25 30 50
    FOR    ${n}    IN    @{sizes}
        Set Viewing    ${n}
        Assert Viewing Summary    ${n}
    END


#Pagination Admin

Get Paging Numbers
    Wait Until Page Contains Element    ${SUMMARY}    10s
    ${t}=    Get Text    ${SUMMARY}
    Log To Console    ℹ "${t}"

    # ดึงเลขทั้งหมดจากข้อความ (ทนกับช่องว่าง/ฟอร์แมต)
    @{nums}=    Get Regexp Matches    ${t}    (\\d+)

    ${cnt}=    Get Length    ${nums}

    IF    ${cnt} >= 3
        ${from}=    Convert To Integer    ${nums[0]}
        ${to}=      Convert To Integer    ${nums[1]}
        ${total}=   Convert To Integer    ${nums[2]}
        RETURN    ${from}    ${to}    ${total}
    END

    # รูปแบบไม่มีข้อมูล "0 records" → จะได้เลขเดียว
    IF    ${cnt} == 1
        ${total}=   Convert To Integer    ${nums[0]}
        RETURN    0    0    ${total}
    END

    Fail    Cannot parse summary: ${t}

Click Safe
    [Arguments]    ${locator}
    Scroll Element Into View    ${locator}
    ${ok}=    Run Keyword And Return Status    Click Element    ${locator}
    IF    not ${ok}
        ${el}=    Get WebElement    ${locator}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${el}
    END
    Wait Quiet

Go Next
    Wait Until Element Is Enabled    ${BTN_NEXT}    10s
    Click Safe    ${BTN_NEXT}

Go Prev
    Wait Until Element Is Enabled    ${BTN_PREV}    10s
    Click Safe    ${BTN_PREV}

Go Last Visible Page
    Wait Until Page Contains Element    ${BTN_LAST_NUM}    10s
    Scroll Element Into View            ${BTN_LAST_NUM}
    ${ok}=    Run Keyword And Return Status    Click Element    ${BTN_LAST_NUM}
    IF    not ${ok}
        ${elem}=    Get WebElement    ${BTN_LAST_NUM}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${elem}
    END
    Wait Quiet
    
Pagination Admin
    Sleep  2s
    # 1) หน้าแรก (1 to N), Prev disabled
    ${has_p1}=    Run Keyword And Return Status    Page Should Contain Element    ${BTN_P1}
    IF    ${has_p1}
        Click Safe    ${BTN_P1}
    END
    ${f1}    ${t1}    ${tot}=    Get Paging Numbers
    Should Be Equal As Integers    ${f1}    1
    Element Should Be Disabled     ${BTN_PREV}
    Log to Console    button is disble Pevious on first page  as expected.
    ${page_size}=    Evaluate    ${t1}-${f1}+1

    # 2) Next แล้วช่วงเลื่อนต่อเนื่อง (from ใหม่ = t1 + 1)
    Go Next
    ${f2}    ${t2}    ${tot2}=    Get Paging Numbers
    ${expected_from2}=    Evaluate    ${t1} + 1
    Should Be Equal As Integers    ${f2}    ${expected_from2}


    # 3) กลับ Prev แล้วช่วงกลับมาเท่าเดิม (1..page_size)
    Go Prev
    ${f3}    ${t3}    ${tot3}=    Get Paging Numbers
    Should Be Equal As Integers    ${f3}    1
    Should Be Equal As Integers    ${t3}    ${page_size}

    # 4) ไปหน้าสุดท้ายที่มองเห็น: to == total และ Next disabled
    ${has_last}=    Run Keyword And Return Status    Page Should Contain Element    ${BTN_LAST_NUM}
    Run Keyword If    ${has_last}    Go Last Visible Page

    ${fl}    ${tl}    ${totl}=    Get Paging Numbers
    Should Be Equal As Integers    ${tl}    ${totl}
    Element Should Be Disabled     ${BTN_NEXT}
    Log to Console    button is disabled on last page as expected.
    Capture Page Screenshot    Pagination_completed.png