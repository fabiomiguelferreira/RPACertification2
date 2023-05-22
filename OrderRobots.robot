*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.

Library    RPA.Browser.Selenium
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Archive
Library    XML

*** Tasks ***
Orders robots from RobotSpareBin Industries Inc
    Open the Robot Order Website   
    Get and Complete the Orders


*** Keywords ***
Open the Robot Order Website    
    Log To Console    KW START: Open the robot order website
    
    Open Browser    https://robotsparebinindustries.com/#/robot-order    chrome
    Maximize Browser Window
    Log To Console    KW END: Open the robot order website

Get and Complete the Orders 
    Log To Console    KW START: Get and Complete the Orders 
    
    ${orders_robots}=    Read table from CSV    orders.csv    header=True

    FOR    ${order}    IN    @{orders_robots}
        Complete the Order    ${order}
    END
    
    Archive Folder With Zip    ${OUTPUT_DIR}    orders.zip     include=*.pdf

    Log To Console    KW END: Get and Complete the Orders

Complete the Order
    [Arguments]    ${order}

    Wait Until Element Is Visible    //*[text()="OK"]
    Click Button    //*[text()="OK"]
        
    Log To Console    ${order}[Head]
    Select From List By Value    id:head    ${order}[Head]

    Log To Console    ${order}[Body]
    Click Element    //input[@name="body" and @value="${order}[Body]"]

    Log To Console    ${order}[Legs]
    Input Text    //input[@placeholder="Enter the part number for the legs"]    ${order}[Legs]
        
    Log To Console    ${order}[Address]
    Input Text    id:address    ${order}[Address]

    Click Button    Preview
    Wait Until Keyword Succeeds   10x    0.5s    Click Button    id:order
    Sleep    1s
        
    Wait Until Element Is Visible    id:receipt    10s
    ${pdf_path}=   Set Variable     ${OUTPUT_DIR}\\${order}[Order number].pdf   
    ${screenshot_path}=    Set Variable     ${OUTPUT_DIR}\\${order}[Order number].PNG
    Screenshot    id:receipt    ${screenshot_path}
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${pdf_path}
    Open Pdf    ${pdf_path}
    Add Watermark Image To Pdf    ${screenshot_path}    ${pdf_path}
    Close Pdf    ${pdf_path}

    Click Button    id:order-another
    Sleep    1s    
        