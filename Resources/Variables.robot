*** Variables ***
${LOGIN_URL}            https://web-backoffice-uat.tcctech-delivery.com/login
${ADMIN_USERNAME}       ltjadmin
${ADMIN_PASSWORD}       000000
${BROWSER}              chrome
${DEFAULT_TIMEOUT}      5s
${SPINNER}      css:.MuiCircularProgress-root

${SUMMARY}     //p[contains(normalize-space(.),'records')]

${VIEWING_BTN}     //label[normalize-space(.)='Viewing']/following::button[@role='combobox']
${VIEWING_LIST}    //*[@role='listbox']

${PAGER}            //div[.//button[normalize-space(.)="Previous"] and .//button[normalize-space(.)="Next"]]
${BTN_PREV}         xpath=${PAGER}//button[normalize-space(.)="Previous"]
${BTN_NEXT}         xpath=${PAGER}//button[normalize-space(.)="Next"]
${BTN_P1}           xpath=${PAGER}//button[normalize-space(.)="1"]
# ปุ่มเลข “ตัวสุดท้ายที่มองเห็น” (คัดเฉพาะปุ่มที่เป็นตัวเลข)
${BTN_LAST_NUM}     xpath=( ${PAGER}//button[ number(normalize-space(.))=number(normalize-space(.)) ] )[last()]
