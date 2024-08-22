IF EXISTS(SELECT 1 FROM sys.views
          WHERE Name = 'NPHIES_BENEFICIARY')
BEGIN
    DROP VIEW dbo.NPHIES_BENEFICIARY
END
GO

-- MARITAL STATUS MAPPING MANDATORY
-- OCCUPATION - 'unknown'
-- RELIGION - '98' ('NOT AVAILABLE')
   CREATE VIEW NPHIES_BENEFICIARY(BENEFICIARYID ,PATIENTFILENO, FIRSTNAME, MIDDLENAME, LASTNAME,
		FULLNAME, DOB, GENDER, NATIONALITY, DOCUMENTID, DOCUMENTTYPE, CONTACTNUMBER, EHEALTHID,
		RESIDENCYTYPE, MARITALSTATUS, BLOODGROUP, PREFERREDLANGUAGE, EMAIL, ADDRESSLINE,
		ADDRESSSTREETNAME, ADDRESSCITY, ADDRESSDISTRICT, ADDRESSSTATE, ADDRESSPOSTALCODE, ADDRESSCOUNTRY, PROVCLAIMNO,
		OCCUPATION, RELIGION) AS
	SELECT  ROW_NUMBER() OVER (ORDER BY PROVCLAIMNO) AS BENEFICIARYID, PATFILENO AS PATIENTFILENO, FIRSTNAME, MIDDLENAME, LASTNAME, FULLNAME,
		MEMBERDOB AS DOB, GENDER, NATIONALITY AS NATIONALITY, NATIONALID AS DOCUMENTID, NULL, NULL, NULL, NULL AS MARITALSTATUS, NULL,
		NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, PROVCLAIMNO, 'unknown' AS OCCUPATION, '98' AS RELIGION
	FROM dbo.WSL_GENINFO;
GO

IF EXISTS(SELECT 1 FROM sys.views 
          WHERE Name = 'NPHIES_COVERAGE')
BEGIN
    DROP VIEW dbo.NPHIES_COVERAGE
END
GO
-- POLICY HOLDER - ACCCODE (MANDATORY)
   CREATE VIEW NPHIES_COVERAGE (COVERAGEID, MEMBERID, EXPIRYDATE, PAYERNPHIESID,
		TPANPHIESID, RELATIONWITHSUBSCRIBER, POLICYNUMBER, POLICYHOLDER, COVERAGETYPE, BENEFICIARYID, PROVCLAIMNO) AS
	SELECT NPHIES_BENEFICIARY.BENEFICIARYID AS COVERAGEID, MEMBERID AS MEMBERID, NULL, PAYERID AS PAYERNPHIESID, TPAID AS TPANPHIESID, NULL, POLICYNO AS POLICYNUMBER,
		ACCCODE AS POLICYHOLDER, 'EHCPOL' AS COVERAGETYPE, NPHIES_BENEFICIARY.BENEFICIARYID AS BENEFICIARYID, WSL_GENINFO.PROVCLAIMNO
	FROM WSL_GENINFO LEFT JOIN NPHIES_BENEFICIARY ON WSL_GENINFO.PROVCLAIMNO=NPHIES_BENEFICIARY.PROVCLAIMNO;
GO

IF EXISTS(SELECT 1 FROM sys.views
          WHERE Name = 'NPHIES_COVERAGE_CLASS')
BEGIN
    DROP VIEW dbo.NPHIES_COVERAGE_CLASS
END

GO

--TYPE - CHI Inquiry 'class'
--VALUE - from CHI Inquiry 'ClassName'
CREATE VIEW NPHIES_COVERAGE_CLASS (COVERAGEID, TYPE, VALUE, NAME) AS
	SELECT NULL AS COVERAGEID, NULL AS TYPE, NULL AS VALUE, NULL AS NAME
	FROM WSL_GENINFO WHERE PROVCLAIMNO='-9999999999999';
GO

IF EXISTS(SELECT 1 FROM sys.views 
          WHERE Name = 'NPHIES_CLAIMINFO')
BEGIN
    DROP VIEW dbo.NPHIES_CLAIMINFO
END
GO
   CREATE VIEW NPHIES_CLAIMINFO (PROVCLAIMNO , EPISODEID, ISNEWBORN, CLAIMTYPE,
		CLAIMSUBTYPE, PROVIDERNPHIESID, CLAIMCREATEDDATE, ACCOUNTINGPERIOD, BILLABLEPERIODSTART, BILLABLEPERIODEND,
		ELIGIBILITYRESPONSEID, ELIGIBILITYIDENTIFIERURL, ELIGIBILITYOFFLINEID, ELIGIBILITYOFFLINEDATE,
		PREAUTHOFFLINEDATE, PREAUTHRESPONSEID, PREAUTHIDENTIFIERURL, PAYEETYPE, PAYEEID, COVERAGEID, BENEFICIARYID, SUBSCRIBERID, TOTAL , PRESCRIPTION) AS
	SELECT WSL_GENINFO.PROVCLAIMNO, WSL_GENINFO.PROVCLAIMNO AS EPISODEID, NULL, DEPTCODE AS CLAIMTYPE,
		CLAIMTYPE AS CLAIMSUBTYPE, PROVIDERID AS PROVIDERNPHIESID, CLAIMDATE AS CLAIMCREATEDDATE, CLAIMDATE AS ACCOUNTINGPERIOD, NULL,
		NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'provider' AS PAYEETYPE, PROVIDERID AS PAYEEID , NPHIES_COVERAGE.COVERAGEID AS COVERAGEID, 
		NPHIES_BENEFICIARY.BENEFICIARYID AS BENEFICIARYID,NULL, TOTCLAIMNETAMT AS TOTAL , NULL 
	FROM WSL_GENINFO LEFT JOIN NPHIES_BENEFICIARY ON WSL_GENINFO.PROVCLAIMNO=NPHIES_BENEFICIARY.PROVCLAIMNO 
	LEFT JOIN NPHIES_COVERAGE ON NPHIES_BENEFICIARY.BENEFICIARYID=NPHIES_COVERAGE.BENEFICIARYID;
GO

IF EXISTS(SELECT 1 FROM sys.views 
          WHERE Name = 'NPHIES_CLAIMDIAGNOSIS')
BEGIN
    DROP VIEW dbo.NPHIES_CLAIMDIAGNOSIS
END
GO
-- CONDITIONONSET - NULL
   CREATE VIEW NPHIES_CLAIMDIAGNOSIS (PROVCLAIMNO, SEQUENCENO, DIAGNOSISCODE, DIAGNOSISDESC, 
		DIAGNOSISTYPE, ONADMISSION, CONDITIONONSET)
		AS SELECT PROVCLAIMNO, ROW_NUMBER() OVER (ORDER BY PROVCLAIMNO), DIAGNOSISCODE, DIAGNOSISDESC, NULL, NULL, NULL AS CONDITIONONSET
	FROM WSL_CLAIM_DIAGNOSIS;
GO

IF EXISTS(SELECT 1 FROM sys.views 
          WHERE Name = 'NPHIES_CLAIMPREAUTHDETAILS')
BEGIN
    DROP VIEW dbo.NPHIES_CLAIMPREAUTHDETAILS
END
GO
CREATE  VIEW NPHIES_CLAIMPREAUTHDETAILS (PROVCLAIMNO, PREAUTHREFNO) AS
	SELECT PROVCLAIMNO, APPREFNO AS PREAUTHREFNO
	FROM WSL_GENINFO WHERE APPREFNO IS NOT NULL AND APPREFNO != '';
GO

IF EXISTS(SELECT 1 FROM sys.views 
          WHERE Name = 'NPHIES_CLAIMCARETEAM')
BEGIN
    DROP VIEW dbo.NPHIES_CLAIMCARETEAM
END
GO
	CREATE VIEW NPHIES_CLAIMCARETEAM(PROVCLAIMNO, SEQUENCENO, PHYSICIANID, PHYSICIANNAME, 
		PRACTITIONERROLE, CARETEAMROLE, CARETEAMQUALIFICATION) AS
	SELECT PROVCLAIMNO, ROW_NUMBER() OVER (ORDER BY PROVCLAIMNO), PHYID AS PHYSICIANID, PHYNAME AS PHYSICIANNAME, 
		'doctor', 'primary', DEPTCODE AS CARETEAMQUALIFICATION
	FROM WSL_GENINFO;
GO

-- WSD.UNITSERVICETYPE AS SERVICETYPE, calculate factor, payershare, why not use TOTSERVICENETAMT
IF EXISTS(SELECT 1 FROM sys.views 
          WHERE Name = 'NPHIES_CLAIMITEM')
BEGIN
    DROP VIEW dbo.NPHIES_CLAIMITEM
END
GO
-- WSD.UNITSERVICETYPE AS SERVICETYPE, calculate factor, payershare, why not use TOTSERVICENETAMT
CREATE VIEW NPHIES_CLAIMITEM(PROVCLAIMNO, INVOICENO, SEQUENCENO, SERVICETYPE, SERVICECODE, SERVICEDESC,
        NONSTANDARDCODE, NONSTANDARDDESC, UDI, ISPACKAGE, QUANTITY, QUANTITYCODE, UNITPRICE, 
        DISCOUNT, FACTOR, PATIENTSHARE, PAYERSHARE, TAX, NET, STARTDATE, ENDDATE,
        BODYSITECODE, SUBSITECODE, DRUGSELECTIONREASON, PRESCRIBEDDRUGCODE, PHARMACISTSELECTIONREASON, PHARMACISTSUBSTITUTE, REASONPHARMACISTSUBSTITUTE, ISMATERNITY) AS
SELECT WI.PROVCLAIMNO, WI.INVOICENO, ROW_NUMBER() OVER (ORDER BY WI.PROVCLAIMNO), NULL AS SERVICETYPE, NULL AS SERVICECODE, NULL AS SERVICEDESC,
        WSD.SERVICECODE AS NONSTANDARDCODE, WSD.SERVICEDESC AS NONSTANDARDDESC, NULL AS UDI, 'false' AS ISPACKAGE,
        WSD.QTY AS QUANTITY, 'package' AS QUANTITYCODE, WSD.UNITSERVICEPRICE AS UNITPRICE, WSD.TOTSERVICEDISC AS DISCOUNT, CAST(ROUND(1 - (WSD.TOTSERVICEDISC/(WSD.UNITSERVICEPRICE*WSD.QTY)),3)as numeric(36,3)) AS FACTOR,  
        WSD.TOTSERVICEPATSHARE AS PATIENTSHARE, (ISNULL(WSD.TOTSERVICEGRSAMT,0)-ISNULL(WSD.TOTSERVICEDISC,0)-ISNULL(WSD.TOTSERVICEPATSHARE,0)+ISNULL(WSD.TOTSERVICENETVATAMOUNT,0)) AS PAYERSHARE, 
        WSD.TOTSERVICENETVATAMOUNT AS TAX, NULL AS NET, WSD.SERVICEDATE AS STARTDATE,
        WSD.SERVICEDATE AS ENDDATE, WSD.TOOTHNO AS BODYSITECODE, NULL, NULL, NULL, 
		NULL, 
        NULL, 
        NULL,
        NULL AS ISMATERNITY
FROM WSL_INVOICES WI 
LEFT JOIN WSL_SERVICE_DETAILS WSD ON WI.INVOICENO = WSD.INVOICENO 
LEFT JOIN NPHIES_CLAIMPREAUTHDETAILS ON NPHIES_CLAIMPREAUTHDETAILS.PROVCLAIMNO = WI.PROVCLAIMNO
WHERE WSD.UNITSERVICEPRICE != 0 AND WSD.QTY != 0;
GO

IF EXISTS(SELECT 1 FROM sys.views
          WHERE Name = 'NPHIES_PROVCLAIMNO_SERVICEDATE')
BEGIN
    DROP VIEW dbo.NPHIES_PROVCLAIMNO_SERVICEDATE
END
GO

CREATE VIEW NPHIES_PROVCLAIMNO_SERVICEDATE(PROVCLAIMNO,SERVICEDATE) AS
    SELECT WG.PROVCLAIMNO, MIN(WSD.SERVICEDATE) FROM WSL_GENINFO WG
    JOIN WSL_INVOICES WI ON WI.PROVCLAIMNO = WG.PROVCLAIMNO
    JOIN WSL_SERVICE_DETAILS WSD ON WI.INVOICENO = WSD.INVOICENO GROUP BY WG.PROVCLAIMNO, WSD.SERVICEDATE;
GO

-- Supporting info remaining
IF EXISTS(SELECT 1 FROM sys.views 
          WHERE Name = 'NPHIES_CLAIMSUPPORTINGINFO')
BEGIN
    DROP VIEW dbo.NPHIES_CLAIMSUPPORTINGINFO
END
GO
IF EXISTS (SELECT 1 
           FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_TYPE='BASE TABLE' 
           AND TABLE_NAME='wsl_claim_attachment') 
BEGIN
	EXECUTE('CREATE   VIEW NPHIES_CLAIMSUPPORTINGINFO(PROVCLAIMNO,  CATEGORY,SEQUENCENO, REASON,
		SUPPORTINGVALUE, SUPPORTINGATTACHMENT, ATTACHMENTFILENAME, ATTACHMENTTYPE, CODE,
		TIMINGPERIODFROM, TIMINGPERIODTO , UNIT) AS 
	SELECT PROVCLAIMNO AS PROVCLAIMNO , Support_Type, ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS SEQUENCENO,NULL,SUPPORTINGVALUE, FILECONTENT, FILENAME,
	NULL AS NotNeeded_4,CODE,TIMINGPERIODFROM, TIMINGPERIODTO ,  UNIT AS UNIT
	FROM
	(SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, ''temperature'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),TEMPERATURE) AS SUPPORTINGVALUE, NULL AS FILECONTENT
	, NULL FILENAME, NULL AS NotNeeded_4, ''Cel'' As CODE, NPS.SERVICEDATE  AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO ,  NULL AS UNIT
	FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO WHERE TEMPERATURE IS NOT NULL
	UNION ALL 
	SELECT PROVCLAIMNO AS PROVCLAIMNO, ''chief-complaint'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, MAINSYMPTOM AS SUPPORTINGVALUE, NULL AS FILECONTENT, NULL FILENAME
	, NULL AS NotNeeded_4, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO,  NULL AS UNIT
	FROM WSL_GENINFO WHERE MAINSYMPTOM IS NOT NULL AND MAINSYMPTOM != ''''
    UNION ALL
    SELECT PROVCLAIMNO AS PROVCLAIMNO, ''patient-history'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, MAINSYMPTOM AS SUPPORTINGVALUE, NULL AS FILECONTENT, NULL FILENAME,
    NULL AS NotNeeded_4, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO,  NULL AS UNIT
	FROM WSL_GENINFO WHERE MAINSYMPTOM IS NOT NULL AND MAINSYMPTOM != ''''
    UNION ALL
    SELECT PROVCLAIMNO AS PROVCLAIMNO, ''history-of-present-illness'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, MAINSYMPTOM AS SUPPORTINGVALUE, NULL AS FILECONTENT, NULL FILENAME,
    NULL AS NotNeeded_4, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO,  NULL AS UNIT
	FROM WSL_GENINFO WHERE MAINSYMPTOM IS NOT NULL AND MAINSYMPTOM != ''''
    UNION ALL
    SELECT WSG.PROVCLAIMNO AS PROVCLAIMNO, ''treatment-plan'' As Support_Type, NULL AS SEQUENCENO, NULL,
        (SELECT STRING_AGG(WSD.SERVICECODE + '' - '' + WSD.SERVICEDESC , '', '' )
        FROM WSL_SERVICE_DETAILS WSD JOIN WSL_INVOICES WI ON WSD.INVOICENO = WI.INVOICENO
        JOIN WSL_GENINFO WG ON WI.PROVCLAIMNO = WG.PROVCLAIMNO where WSD.SERVICECODE IS NOT NULL AND WSD.SERVICEDESC IS NOT NULL AND WG.PROVCLAIMNO = WSG.PROVCLAIMNO)
        AS SUPPORTINGVALUE, NULL, NULL, NULL, NULL, NULL, NULL,NULL FROM WSL_GENINFO WSG
    UNION ALL
    SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, ''vital-sign-weight'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),WEIGH) AS SUPPORTINGVALUE, NULL AS FILECONTENT
	, NULL FILENAME, NULL AS NotNeeded_4, ''kg'' As CODE, NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO  ,  NULL AS UNIT
	FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO WHERE WEIGH IS NOT NULL AND WEIGH != ''''
    UNION ALL
    	-- TIMINGPERIODFROM - min (serviceDate from service_details)
    SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, ''vital-sign-height'' As Support_Type,  NULL AS SEQUENCENO, ''999.9'' AS REASON, NULL, NULL, NULL, NULL, NULL,
    NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL,NULL
   	FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO
    UNION ALL
    -- TIMINGPERIODFROM - min (serviceDate from service_details)
    SELECT WG.PROVCLAIMNO AS PROVCLAIMNO,  ''oxygen-saturation'' As Support_Type ,NULL AS SEQUENCENO, ''999'' AS REASON, NULL, NULL, NULL, NULL, NULL,
   	NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL,NULL
    FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO
    UNION ALL
        -- should be removed after deployment of MDS changes.
    SELECT PROVCLAIMNO AS PROVCLAIMNO, ''hospitalized'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4, NULL AS CODE
	, NULL, ADMISSIONDATE AS TIMINGPERIODFROM, DISCHARGEDATE AS TIMINGPERIODTO ,  NULL AS UNIT
	FROM WSL_GENINFO WHERE ADMISSIONDATE IS NOT NULL AND DISCHARGEDATE IS NOT NULL
    UNION ALL
    --significantsign - physical examnation
    SELECT PROVCLAIMNO AS PROVCLAIMNO, ''physical-examination'' AS Support_Type, NULL AS SEQUENCENO, NULL,  SIGNIFICANTSIGN AS SUPPORTINGVALUE, NULL, NULL, NULL, NULL, NULL, NULL,NULL
    FROM WSL_GENINFO WHERE SIGNIFICANTSIGN IS NOT NULL
    UNION ALL
    SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, ''pulse'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),PULSE) AS SUPPORTINGVALUE, NULL AS FILECONTENT
	, NULL FILENAME, NULL AS NotNeeded_4, ''/min'' As CODE, NPS.SERVICEDATE  AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO ,  NULL AS UNIT
	FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO WHERE PULSE IS NOT NULL AND PULSE != ''''
	UNION ALL
	SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, ''respiratory-rate'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),RESPIRATORYRATE) AS SUPPORTINGVALUE
	, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4, ''/min'' As CODE, NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO ,  NULL AS UNIT
	FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO WHERE RESPIRATORYRATE IS NOT NULL AND RESPIRATORYRATE != ''''
	UNION ALL
	SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, ''vital-sign-systolic'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),BLOODPRESSURE) AS SUPPORTINGVALUE
	, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4L, ''mm[Hg]'' As CODE, NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO ,  NULL AS UNIT
	FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO WHERE BLOODPRESSURE IS NOT NULL AND BLOODPRESSURE != ''''
	UNION ALL
	SELECT PROVCLAIMNO AS PROVCLAIMNO, ''info'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),RADIOREPORT) AS SUPPORTINGVALUE
	, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4L, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO ,  NULL AS UNIT
	FROM WSL_GENINFO  WHERE RADIOREPORT IS NOT NULL
	UNION ALL
	SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, ''vital-sign-diastolic'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),BLOODPRESSURE) AS SUPPORTINGVALUE
	, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4, ''mm[Hg]'' As CODE, NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO ,  NULL AS UNIT
	FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO WHERE BLOODPRESSURE IS NOT NULL AND BLOODPRESSURE != ''''
    UNION ALL
	SELECT PROVCLAIMNO_temp AS PROVCLAIMNO, Support_Type_temp AS Support_Type, NULL AS SEQUENCENO, NULL AS NotNeeded_1,
	case
	when labcompcode_temp is not null and labcompcode_temp != '''' THEN (''LABCODE: '' + ISNULL(labcompcode_temp,'''') +'' ,LABDESC: '' + ISNULL(labcompdesc_temp,'''')  + '' ,LABRESULT: '' + ISNULL(labresult_temp,'''') + '' ,LABRESULTUNIT: '' + ISNULL(labunit_temp,'''') + '' ,LABRESULTCOMMENT: '' + ISNULL(labComment_temp,'''') + '' ,LABRESULTCDESC: '' + ISNULL(labresultdesc_temp,''''))
	when labcompdesc_temp is not null and labcompdesc_temp != '''' THEN (''LABCODE: '' + ISNULL(labcompcode_temp,'''') +'' ,LABDESC: '' + ISNULL(labcompdesc_temp,'''')  + '' ,LABRESULT: '' + ISNULL(labresult_temp,'''') + '' ,LABRESULTUNIT: '' + ISNULL(labunit_temp,'''') + '' ,LABRESULTCOMMENT: '' + ISNULL(labComment_temp,'''') + '' ,LABRESULTCDESC: '' + ISNULL(labresultdesc_temp,''''))
	when labresult_temp is not null and labresult_temp != '''' THEN (''LABCODE: '' + ISNULL(labcompcode_temp,'''') +'' ,LABDESC: '' + ISNULL(labcompdesc_temp,'''')  + '' ,LABRESULT: '' + ISNULL(labresult_temp,'''') + '' ,LABRESULTUNIT: '' + ISNULL(labunit_temp,'''') + '' ,LABRESULTCOMMENT: '' + ISNULL(labComment_temp,'''') + '' ,LABRESULTCDESC: '' + ISNULL(labresultdesc_temp,''''))
	when labunit_temp is not null and labunit_temp != '''' THEN (''LABCODE: '' + ISNULL(labcompcode_temp,'''') +'' ,LABDESC: '' + ISNULL(labcompdesc_temp,'''')  + '' ,LABRESULT: '' + ISNULL(labresult_temp,'''') + '' ,LABRESULTUNIT: '' + ISNULL(labunit_temp,'''') + '' ,LABRESULTCOMMENT: '' + ISNULL(labComment_temp,'''') + '' ,LABRESULTCDESC: '' + ISNULL(labresultdesc_temp,''''))
	when labComment_temp is not null and labComment_temp != '''' THEN (''LABCODE: '' + ISNULL(labcompcode_temp,'''') +'' ,LABDESC: '' + ISNULL(labcompdesc_temp,'''')  + '' ,LABRESULT: '' + ISNULL(labresult_temp,'''') + '' ,LABRESULTUNIT: '' + ISNULL(labunit_temp,'''') + '' ,LABRESULTCOMMENT: '' + ISNULL(labComment_temp,'''') + '' ,LABRESULTCDESC: '' + ISNULL(labresultdesc_temp,''''))
	when labresultdesc_temp is not null and labresultdesc_temp != '''' THEN (''LABCODE: '' + ISNULL(labcompcode_temp,'''') +'' ,LABDESC: '' + ISNULL(labcompdesc_temp,'''')  + '' ,LABRESULT: '' + ISNULL(labresult_temp,'''') + '' ,LABRESULTUNIT: '' + ISNULL(labunit_temp,'''') + '' ,LABRESULTCOMMENT: '' + ISNULL(labComment_temp,'''') + '' ,LABRESULTCDESC: '' + ISNULL(labresultdesc_temp,''''))
	END AS SUPPORTINGVALUE, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4, CODE_temp AS CODE, NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO ,  labunit_temp AS UNIT
	FROM(
	SELECT labResult.PROVCLAIMNO AS PROVCLAIMNO_temp, ''lab-test'' AS Support_Type_temp, 
		labComponent.LABCOMPCODE AS labcompcode_temp, labComponent.LABCOMPDESC AS labcompdesc_temp, labComponent.LABRESULT AS labresult_temp, 
		labComponent.LABRESULTUNIT AS labunit_temp, labComponent.LABRESULTCOMMENT AS labComment_temp,labResult.LABTESTCODE AS CODE_temp, labResult.LABDESC AS labresultdesc_temp  
	FROM WSL_LAB_RESULT labResult LEFT JOIN WSL_LAB_COMPONENT labComponent ON labResult.LABTESTCODE=labComponent.LABTESTCODE and labResult.SERIAL=labComponent.SERIAL and labResult.PROVCLAIMNO=labComponent.PROVCLAIMNO
	JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = labResult.PROVCLAIMNO) dataResult
	UNION ALL 
	SELECT PROVCLAIMNO AS PROVCLAIMNO, ''last-menstrual-period'', NULL AS SEQUENCENO,  NULL, NULL, NULL, NULL, NULL, NULL, LASTMENSTRUATIONPERIOD AS TIMINGPERIODFROM, NULL ,  NULL AS UNIT
	FROM WSL_GENINFO WHERE LASTMENSTRUATIONPERIOD IS NOT NULL 	
	UNION ALL
	SELECT PROVCLAIMNO AS PROVCLAIMNO, ''attachment'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1,NULL AS SUPPORTINGVALUE
	, FILECONTENT , FILENAME , NULL AS NotNeeded_4, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO ,  NULL AS UNIT
	FROM wsl_claim_attachment WHERE FILENAME IS NOT NULL
	) AS SUPPORTING_INFO')
END
ELSE
	EXECUTE('CREATE   VIEW NPHIES_CLAIMSUPPORTINGINFO(PROVCLAIMNO,  CATEGORY,SEQUENCENO, REASON,
		SUPPORTINGVALUE, SUPPORTINGATTACHMENT, ATTACHMENTFILENAME, ATTACHMENTTYPE, CODE,
		TIMINGPERIODFROM, TIMINGPERIODTO,UNIT) AS 
	SELECT PROVCLAIMNO AS PROVCLAIMNO , Support_Type, ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS SEQUENCENO,NULL,SUPPORTINGVALUE, FILECONTENT, FILENAME,
	NULL AS NotNeeded_4,CODE,TIMINGPERIODFROM, TIMINGPERIODTO ,  UNIT AS UNIT 
	FROM
	(SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, ''temperature'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),TEMPERATURE) AS SUPPORTINGVALUE, NULL AS FILECONTENT
	, NULL FILENAME, NULL AS NotNeeded_4, ''Cel'' As CODE, NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO ,  NULL AS UNIT
	FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO WHERE TEMPERATURE IS NOT NULL
	UNION ALL 
	SELECT PROVCLAIMNO AS PROVCLAIMNO, ''chief-complaint'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, MAINSYMPTOM AS SUPPORTINGVALUE, NULL AS FILECONTENT, NULL FILENAME
	, NULL AS NotNeeded_4, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO ,  NULL AS UNIT
	FROM WSL_GENINFO WHERE MAINSYMPTOM IS NOT NULL AND MAINSYMPTOM != ''''
    UNION ALL
    SELECT PROVCLAIMNO AS PROVCLAIMNO, ''patient-history'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, MAINSYMPTOM AS SUPPORTINGVALUE, NULL AS FILECONTENT, NULL FILENAME,
    NULL AS NotNeeded_4, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO,  NULL AS UNIT
	FROM WSL_GENINFO WHERE MAINSYMPTOM IS NOT NULL AND MAINSYMPTOM != ''''
    UNION ALL
    SELECT PROVCLAIMNO AS PROVCLAIMNO, ''history-of-present-illness'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, MAINSYMPTOM AS SUPPORTINGVALUE, NULL AS FILECONTENT, NULL FILENAME,
    NULL AS NotNeeded_4, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO,  NULL AS UNIT
	FROM WSL_GENINFO WHERE MAINSYMPTOM IS NOT NULL AND MAINSYMPTOM != ''''
    UNION ALL
    SELECT WSG.PROVCLAIMNO AS PROVCLAIMNO, ''treatment-plan'' As Support_Type, NULL AS SEQUENCENO, NULL,
        (SELECT STRING_AGG(WSD.SERVICECODE + '' - '' + WSD.SERVICEDESC , '', '' )
        FROM WSL_SERVICE_DETAILS WSD JOIN WSL_INVOICES WI ON WSD.INVOICENO = WI.INVOICENO
        JOIN WSL_GENINFO WG ON WI.PROVCLAIMNO = WG.PROVCLAIMNO where WSD.SERVICECODE IS NOT NULL AND WSD.SERVICEDESC IS NOT NULL AND WG.PROVCLAIMNO = WSG.PROVCLAIMNO)
        AS SUPPORTINGVALUE, NULL, NULL, NULL, NULL, NULL, NULL,NULL FROM WSL_GENINFO WSG
    UNION ALL
    SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, ''vital-sign-weight'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),WEIGH) AS SUPPORTINGVALUE, NULL AS FILECONTENT
	, NULL FILENAME, NULL AS NotNeeded_4, ''kg'' As CODE, NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO  ,  NULL AS UNIT
	FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO WHERE WEIGH IS NOT NULL AND WEIGH != ''''
    UNION ALL
    -- TIMINGPERIODFROM - min (serviceDate from service_details)
    SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, ''vital-sign-height'' As Support_Type, NULL AS SEQUENCENO, ''999.9'', NULL, NULL, NULL, NULL, NULL,
    NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL,NULL
    FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO
    UNION ALL
    -- TIMINGPERIODFROM - min (serviceDate from service_details)
    SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, ''oxygen-saturation'' As Support_Type, NULL AS SEQUENCENO, ''999'', NULL, NULL, NULL, NULL, NULL,
   	NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL,NULL
    FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO
    UNION ALL
    --significantsign - physical examnation
    SELECT PROVCLAIMNO AS PROVCLAIMNO, ''physical-examination'' AS Support_Type, NULL AS SEQUENCENO, NULL, SIGNIFICANTSIGN AS SUPPORTINGVALUE, NULL, NULL, NULL, NULL, NULL, NULL,NULL
    FROM WSL_GENINFO WHERE SIGNIFICANTSIGN IS NOT NULL
    UNION ALL
    -- should be removed after deployment of MDS changes.
    SELECT PROVCLAIMNO AS PROVCLAIMNO, ''hospitalized'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4, NULL AS CODE
	, NULL, ADMISSIONDATE AS TIMINGPERIODFROM, DISCHARGEDATE AS TIMINGPERIODTO ,  NULL AS UNIT
	FROM WSL_GENINFO WHERE ADMISSIONDATE IS NOT NULL AND DISCHARGEDATE IS NOT NULL
    UNION ALL
    SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, ''pulse'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),PULSE) AS SUPPORTINGVALUE, NULL AS FILECONTENT
	, NULL FILENAME, NULL AS NotNeeded_4, ''/min'' As CODE, NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO ,  NULL AS UNIT
	FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO WHERE PULSE IS NOT NULL AND PULSE != ''''
	UNION ALL
	SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, ''respiratory-rate'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),RESPIRATORYRATE) AS SUPPORTINGVALUE
	, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4, ''/min'' As CODE, NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO ,  NULL AS UNIT
	FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO WHERE RESPIRATORYRATE IS NOT NULL AND RESPIRATORYRATE != ''''
	UNION ALL
	SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, ''vital-sign-systolic'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),BLOODPRESSURE) AS SUPPORTINGVALUE
	, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4L, ''mm[Hg]'' As CODE, NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO ,  NULL AS UNIT
	FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO WHERE BLOODPRESSURE IS NOT NULL AND BLOODPRESSURE != ''''
	UNION ALL
	SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, ''vital-sign-diastolic'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),BLOODPRESSURE) AS SUPPORTINGVALUE
	, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4, ''mm[Hg]'' As CODE, NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO ,  NULL AS UNIT
	FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO WHERE BLOODPRESSURE IS NOT NULL AND BLOODPRESSURE != ''''
	UNION ALL 
	SELECT PROVCLAIMNO AS PROVCLAIMNO, ''last-menstrual-period'', NULL AS SEQUENCENO,  NULL, NULL, NULL, NULL, NULL, NULL, LASTMENSTRUATIONPERIOD AS TIMINGPERIODFROM, NULL ,  NULL AS UNIT
	FROM WSL_GENINFO WHERE LASTMENSTRUATIONPERIOD IS NOT NULL
	UNION ALL
	SELECT PROVCLAIMNO AS PROVCLAIMNO, ''info'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),RADIOREPORT) AS SUPPORTINGVALUE
	, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4L, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO ,  NULL AS UNIT
	FROM WSL_GENINFO WHERE RADIOREPORT IS NOT NULL
    UNION ALL
	SELECT PROVCLAIMNO_temp AS PROVCLAIMNO, Support_Type_temp AS Support_Type, NULL AS SEQUENCENO, NULL AS NotNeeded_1,
	case
	when labcompcode_temp is not null and labcompcode_temp != '''' THEN (''LABCODE: '' + ISNULL(labcompcode_temp,'''') +'' ,LABDESC: '' + ISNULL(labcompdesc_temp,'''')  + '' ,LABRESULT: '' + ISNULL(labresult_temp,'''') + '' ,LABRESULTUNIT: '' + ISNULL(labunit_temp,'''') + '' ,LABRESULTCOMMENT: '' + ISNULL(labComment_temp,'''') + '' ,LABRESULTCDESC: '' + ISNULL(labresultdesc_temp,''''))
	when labcompdesc_temp is not null and labcompdesc_temp != '''' THEN (''LABCODE: '' + ISNULL(labcompcode_temp,'''') +'' ,LABDESC: '' + ISNULL(labcompdesc_temp,'''')  + '' ,LABRESULT: '' + ISNULL(labresult_temp,'''') + '' ,LABRESULTUNIT: '' + ISNULL(labunit_temp,'''') + '' ,LABRESULTCOMMENT: '' + ISNULL(labComment_temp,'''') + '' ,LABRESULTCDESC: '' + ISNULL(labresultdesc_temp,''''))
	when labresult_temp is not null and labresult_temp != '''' THEN (''LABCODE: '' + ISNULL(labcompcode_temp,'''') +'' ,LABDESC: '' + ISNULL(labcompdesc_temp,'''')  + '' ,LABRESULT: '' + ISNULL(labresult_temp,'''') + '' ,LABRESULTUNIT: '' + ISNULL(labunit_temp,'''') + '' ,LABRESULTCOMMENT: '' + ISNULL(labComment_temp,'''') + '' ,LABRESULTCDESC: '' + ISNULL(labresultdesc_temp,''''))
	when labunit_temp is not null and labunit_temp != '''' THEN (''LABCODE: '' + ISNULL(labcompcode_temp,'''') +'' ,LABDESC: '' + ISNULL(labcompdesc_temp,'''')  + '' ,LABRESULT: '' + ISNULL(labresult_temp,'''') + '' ,LABRESULTUNIT: '' + ISNULL(labunit_temp,'''') + '' ,LABRESULTCOMMENT: '' + ISNULL(labComment_temp,'''') + '' ,LABRESULTCDESC: '' + ISNULL(labresultdesc_temp,''''))
	when labComment_temp is not null and labComment_temp != '''' THEN (''LABCODE: '' + ISNULL(labcompcode_temp,'''') +'' ,LABDESC: '' + ISNULL(labcompdesc_temp,'''')  + '' ,LABRESULT: '' + ISNULL(labresult_temp,'''') + '' ,LABRESULTUNIT: '' + ISNULL(labunit_temp,'''') + '' ,LABRESULTCOMMENT: '' + ISNULL(labComment_temp,'''') + '' ,LABRESULTCDESC: '' + ISNULL(labresultdesc_temp,''''))
	when labresultdesc_temp is not null and labresultdesc_temp != '''' THEN (''LABCODE: '' + ISNULL(labcompcode_temp,'''') +'' ,LABDESC: '' + ISNULL(labcompdesc_temp,'''')  + '' ,LABRESULT: '' + ISNULL(labresult_temp,'''') + '' ,LABRESULTUNIT: '' + ISNULL(labunit_temp,'''') + '' ,LABRESULTCOMMENT: '' + ISNULL(labComment_temp,'''') + '' ,LABRESULTCDESC: '' + ISNULL(labresultdesc_temp,''''))
	END AS SUPPORTINGVALUE, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4, CODE_temp AS CODE, NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO ,  labunit_temp AS UNIT
	FROM(
	SELECT labResult.PROVCLAIMNO AS PROVCLAIMNO_temp, ''lab-test'' AS Support_Type_temp, 
		labComponent.LABCOMPCODE AS labcompcode_temp, labComponent.LABCOMPDESC AS labcompdesc_temp, labComponent.LABRESULT AS labresult_temp, 
		labComponent.LABRESULTUNIT AS labunit_temp, labComponent.LABRESULTCOMMENT AS labComment_temp,labResult.LABTESTCODE AS CODE_temp, labResult.LABDESC AS labresultdesc_temp  
	FROM WSL_LAB_RESULT labResult LEFT JOIN WSL_LAB_COMPONENT labComponent ON labResult.LABTESTCODE=labComponent.LABTESTCODE and labResult.SERIAL=labComponent.SERIAL and labResult.PROVCLAIMNO=labComponent.PROVCLAIMNO
	JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = labResult.PROVCLAIMNO) dataResult
	) AS SUPPORTING_INFO')
	GO
GO  
GO  
-- Accident details
IF EXISTS(SELECT 1 FROM sys.views 
          WHERE Name = 'NPHIES_CLAIMACCIDENTDETAIL')
BEGIN
    DROP VIEW dbo.NPHIES_CLAIMACCIDENTDETAIL
END
GO
	CREATE VIEW NPHIES_CLAIMACCIDENTDETAIL(PROVCLAIMNO, ACCIDENTTYPE, ACCIDENTDATE,
		ADDRESSSTREETNAME, ADDRESSCITY, ADDRESSSTATE, ADDRESSCOUNTRY) AS
	SELECT NULL AS PROVCLAIMNO, NULL, NULL, NULL, NULL, NULL, NULL
	FROM WSL_GENINFO where PROVCLAIMNO='-9999999999999';
GO

IF EXISTS(SELECT 1 FROM sys.views 
          WHERE Name = 'NPHIES_CLAIMVISIONPRESCRIPTION')
BEGIN
    DROP VIEW dbo.NPHIES_CLAIMVISIONPRESCRIPTION
END
GO
	CREATE VIEW NPHIES_CLAIMVISIONPRESCRIPTION(PROVCLAIMNO, VISIONPRESCRIPTIONID, DATEWRITTEN,
		CARETEAMSEQUENCE, PRODUCT, EYE, SPHERE, CYLINDER, AXIS, PRISMAMOUNT,
		PRISMBASE, MULTIFOCALPOWER, LENSPOWER, LENSBACKCURVE, LENSDIAMETER, LENSDURATION,
		LENSCOLOR, LENSBRAND, LENSNOTE, LENSDURATIONUNIT) AS
	SELECT NULL AS PROVCLAIMNO, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
		NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
	FROM WSL_GENINFO where PROVCLAIMNO='-9999999999999';
GO

IF EXISTS(SELECT 1 FROM sys.views 
          WHERE Name = 'NPHIES_ITEMDIAGNOSIS')
BEGIN
    DROP VIEW dbo.NPHIES_ITEMDIAGNOSIS
END
GO
	CREATE   VIEW NPHIES_ITEMDIAGNOSIS(PROVCLAIMNO, DIAGNOSISSEQUENCENO, ITEMSEQUENCENO) AS
	SELECT NULL AS PROVCLAIMNO , NULL AS DIAGNOSISSEQUENCENO, NULL AS ITEMSEQUENCENO
    FROM WSL_GENINFO where PROVCLAIMNO='-9999999999999';
GO

IF EXISTS(SELECT 1 FROM sys.views 
          WHERE Name = 'NPHIES_ITEMCARETEAM')
BEGIN
    DROP VIEW dbo.NPHIES_ITEMCARETEAM
END
GO
	CREATE   VIEW NPHIES_ITEMCARETEAM(PROVCLAIMNO, CARETEAMSEQUENCENO, ITEMSEQUENCENO) AS
	SELECT NULL AS PROVCLAIMNO , NULL AS CARETEAMSEQUENCENO, NULL AS ITEMSEQUENCENO
    FROM WSL_GENINFO where PROVCLAIMNO='-9999999999999';
GO

IF EXISTS(SELECT 1 FROM sys.views 
          WHERE Name = 'NPHIES_ITEMSUPPORTINGINFO')
BEGIN
    DROP VIEW dbo.NPHIES_ITEMSUPPORTINGINFO
END
GO
	CREATE   VIEW NPHIES_ITEMSUPPORTINGINFO(PROVCLAIMNO, SUPPORTINGINFOSEQUENCENO, ITEMSEQUENCENO) AS
	SELECT NULL AS PROVCLAIMNO , NULL AS SUPPORTINGINFOSEQUENCENO, NULL AS ITEMSEQUENCENO
    FROM WSL_GENINFO where PROVCLAIMNO='-9999999999999';
GO

IF EXISTS(SELECT 1 FROM sys.views 
          WHERE Name = 'NPHIES_CLAIMITEMDETAILS')
BEGIN
    DROP VIEW dbo.NPHIES_CLAIMITEMDETAILS
END
GO
	CREATE VIEW NPHIES_CLAIMITEMDETAILS(ITEMSEQUENCENO, PROVCLAIMNO, SEQUENCENO,
		SERVICETYPE, SERVICECODE, SERVICEDESC, NONSTANDARDCODE, NONSTANDARDDESC, UDI, 
		QUANTITY, QUANTITYCODE, UNITPRICE, TAX, NET , PHARMACISTSELECTIONREASON , PHARMACISTSUBSTITUTE ,REASONPHARMACISTSUBSTITUTE,PRESCRIBEDDRUGCODE) AS
	SELECT NULL, NULL AS PROVCLAIMNO, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
		NULL, NULL, NULL , NULL , NULL , NULL , NULL
	FROM WSL_GENINFO where PROVCLAIMNO='-9999999999999';
GO

IF EXISTS(SELECT 1 FROM sys.views 
          WHERE Name = 'NPHIES_CLAIMENCOUNTERS')
BEGIN
    DROP VIEW dbo.NPHIES_CLAIMENCOUNTERS
END

GO
-- ENCOUNTERID - PROVCLAIMNO
-- ENCOUNTERSTARTDATE - MIN(SERVICEDATE)
-- ENCOUNTERSTATUS - 'unknown'
-- ENCOUNTERCLASS - 'AMB'.
-- SERVICEEVENTTYPE - if VISITTYPE = 'new' or 'referral' then 'ICSE' else if VISITTYPE = 'SCSE' else 'ICSE'.
CREATE VIEW NPHIES_CLAIMENCOUNTERS(PROVCLAIMNO, ENCOUNTERID, ENCOUNTERSTARTDATE,
		ENCOUNTERENDDATE, ENCOUNTERCLASS, ENCOUNTERSERVICETYPE, PRIORITY, SERVICEPROVIDER, ENCOUNTERSTATUS, CAUSEOFDEATH, SERVICEEVENTTYPE) AS
	SELECT WG.PROVCLAIMNO AS PROVCLAIMNO,
	WG.PROVCLAIMNO AS ENCOUNTERID,
    NPS.SERVICEDATE AS ENCOUNTERSTARTDATE,
    NULL AS ENCOUNTERENDDATE,
    'AMB' AS ENCOUNTERCLASS,
	NULL AS ENCOUNTERSERVICETYPE,
	NULL AS PRIORITY,
	NULL AS SERVICEPROVIDER,
	'unknown' as ENCOUNTERSTATUS,
	NULL AS CAUSEOFDEATH,
	CASE
        WHEN (LOWER(WG.VISITTYPE) = 'new') OR (LOWER(WG.VISITTYPE) = 'referral') THEN 'ICSE'
        WHEN (LOWER(WG.VISITTYPE) = 'follow-up') OR (LOWER(WG.VISITTYPE) = 'followup') THEN 'SCSE'
            ELSE 'ICSE'
    END AS SERVICEEVENTTYPE

	FROM WSL_GENINFO WG
	JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO;
GO

IF EXISTS(SELECT 1 FROM sys.views
          WHERE Name = 'NPHIES_ENCOUNTERHOSPITALIZATION')
BEGIN
    DROP VIEW dbo.NPHIES_ENCOUNTERHOSPITALIZATION
END
GO

CREATE VIEW NPHIES_ENCOUNTERHOSPITALIZATION (PROVCLAIMNO, ENCOUNTERHOSPITALIZATIONID, HOSPITALADMISSIONSPECIALITY,
     HOSPITALDISCHARGESPECIALITY, HOSPITALINTENDEDLENGTHOFSTAY, HOSPITALIZATIONORIGIN, HOSPITALADMISSIONSOURCE,
     HOSPITALREADMISSION, HOSPITALDISCHARGEDISPOSITION) AS

    SELECT NULL AS PROVCLAIMNO,
    NULL AS ENCOUNTERHOSPITALIZATIONID,
    NULL AS HOSPITALADMISSIONSPECIALITY,
    NULL AS HOSPITALDISCHARGESPECIALITY,
    NULL AS HOSPITALINTENDEDLENGTHOFSTAY,
    NULL AS HOSPITALIZATIONORIGIN,
    NULL AS HOSPITALADMISSIONSOURCE,
    NULL AS HOSPITALREADMISSION,
    NULL AS HOSPITALDISCHARGEDISPOSITION
	FROM WSL_GENINFO WHERE PROVCLAIMNO = '-9999999999999';

GO

IF EXISTS(SELECT 1 FROM sys.views
          WHERE Name = 'NPHIES_ENCOUNTEREMERGENCY')
BEGIN
    DROP VIEW dbo.NPHIES_ENCOUNTEREMERGENCY
END

GO

CREATE VIEW NPHIES_ENCOUNTEREMERGENCY ( PROVCLAIMNO, ENCOUNTEREMERGENCYID, EMERGENCYARRIVALCODE, EMERGENCYSERVICESTART,
    EMERGENCYDEPARTMENTDISPOSITION, TRIAGECATEGORY, TRIAGEDATE) AS

    SELECT NULL AS PROVCLAIMNO,
    NULL AS ENCOUNTEREMERGENCYID,
    NULL AS EMERGENCYARRIVALCODE,
    NULL AS EMERGENCYSERVICESTART,
    NULL AS EMERGENCYDEPARTMENTDISPOSITION,
    NULL AS TRIAGECATEGORY,
    NULL AS TRIAGEDATE
    FROM WSL_GENINFO WHERE PROVCLAIMNO = '-9999999999999';
GO
