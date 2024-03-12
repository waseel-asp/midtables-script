--DROP SEQUENCE supporting_sequence;
-- DROP FUNCTION func_seq_test;


CREATE OR REPLACE FUNCTION func_seq_test (supporting_sequence in VARCHAR2) RETURN NUMBER IS l_nextval NUMBER;
BEGIN
   EXECUTE IMMEDIATE 'select ' || supporting_sequence || '.nextval from dual'
         INTO l_nextval;

   RETURN l_nextval;
END;
/

CREATE SEQUENCE supporting_sequence START WITH 1 INCREMENT BY   1
 NOCACHE
 NOCYCLE; 

CREATE OR REPLACE VIEW NPHIES_BENEFICIARY (BENEFICIARYID PRIMARY KEY DISABLE NOVALIDATE, PATIENTFILENO, FIRSTNAME, MIDDLENAME, LASTNAME,
		FULLNAME, DOB, GENDER, NATIONALITY, DOCUMENTID, DOCUMENTTYPE, CONTACTNUMBER, EHEALTHID,
		RESIDENCYTYPE, MARITALSTATUS, BLOODGROUP, PREFERREDLANGUAGE, EMAIL, ADDRESSLINE,
		ADDRESSSTREETNAME, ADDRESSCITY, ADDRESSDISTRICT, ADDRESSSTATE, ADDRESSPOSTALCODE, ADDRESSCOUNTRY, PROVCLAIMNO) AS
	SELECT rowid AS BENEFICIARYID, PATFILENO AS PATIENTFILENO, FIRSTNAME, MIDDLENAME, LASTNAME, FULLNAME,
		MEMBERDOB AS DOB, GENDER, NATIONALITY AS NATIONALITY, NATIONALID AS DOCUMENTID, NULL, NULL, NULL, NULL, NULL,
		NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, PROVCLAIMNO
	FROM WSL_GENINFO;

CREATE OR REPLACE VIEW NPHIES_COVERAGE (COVERAGEID, MEMBERID, EXPIRYDATE, PAYERNPHIESID,
		TPANPHIESID, RELATIONWITHSUBSCRIBER, POLICYNUMBER, POLICYHOLDER, COVERAGETYPE, BENEFICIARYID, PROVCLAIMNO) AS
	SELECT NPHIES_BENEFICIARY.rowid AS COVERAGEID, MEMBERID AS MEMBERID, NULL, PAYERID AS PAYERNPHIESID, TPAID AS TPANPHIESID, NULL, POLICYNO AS POLICYNUMBER,
		NULL AS POLICYHOLDER, 'EHCPOL' AS COVERAGETYPE, NPHIES_BENEFICIARY.BENEFICIARYID AS BENEFICIARYID, WSL_GENINFO.PROVCLAIMNO
	FROM WSL_GENINFO LEFT JOIN NPHIES_BENEFICIARY ON WSL_GENINFO.PROVCLAIMNO=NPHIES_BENEFICIARY.PROVCLAIMNO;

CREATE OR REPLACE VIEW NPHIES_CLAIMINFO (PROVCLAIMNO PRIMARY KEY DISABLE NOVALIDATE, EPISODEID, ISNEWBORN, CLAIMTYPE,
		CLAIMSUBTYPE, PROVIDERNPHIESID, CLAIMCREATEDDATE, ACCOUNTINGPERIOD, BILLABLEPERIODSTART, BILLABLEPERIODEND,
		ELIGIBILITYRESPONSEID, ELIGIBILITYIDENTIFIERURL, ELIGIBILITYOFFLINEID, ELIGIBILITYOFFLINEDATE,
		PREAUTHOFFLINEDATE, PREAUTHRESPONSEID, PREAUTHIDENTIFIERURL, PAYEETYPE, PAYEEID, COVERAGEID, BENEFICIARYID, SUBSCRIBERID, TOTAL,ISREFERRAL,REFERRINGPROVIDERNAME ,PRESCRIPTION) AS
	SELECT WSL_GENINFO.PROVCLAIMNO, WSL_GENINFO.PROVCLAIMNO AS EPISODEID, NULL, DEPTCODE AS CLAIMTYPE,
		CLAIMTYPE AS CLAIMSUBTYPE, PROVIDERID AS PROVIDERNPHIESID, CLAIMDATE AS CLAIMCREATEDDATE, CLAIMDATE AS ACCOUNTINGPERIOD, NULL,
		NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'provider' AS PAYEETYPE, PROVIDERID AS PAYEEID , NPHIES_COVERAGE.COVERAGEID AS COVERAGEID, 
		NPHIES_BENEFICIARY.BENEFICIARYID AS BENEFICIARYID,NULL, TOTCLAIMNETAMT AS TOTAL ,NULL AS ISREFERRAL,NULL AS REFERRINGPROVIDERNAME,NULL
	FROM WSL_GENINFO LEFT JOIN NPHIES_BENEFICIARY ON WSL_GENINFO.PROVCLAIMNO=NPHIES_BENEFICIARY.PROVCLAIMNO 
	LEFT JOIN NPHIES_COVERAGE ON NPHIES_BENEFICIARY.BENEFICIARYID=NPHIES_COVERAGE.BENEFICIARYID;
	
CREATE OR REPLACE VIEW NPHIES_CLAIMDIAGNOSIS (PROVCLAIMNO, SEQUENCENO, DIAGNOSISCODE, DIAGNOSISDESC, 
		DIAGNOSISTYPE, ONADMISSION,
		CONSTRAINT "PK_NPHIES_CLAIMDIAGNOSIS" PRIMARY KEY ("PROVCLAIMNO", "DIAGNOSISCODE") DISABLE) AS
	SELECT PROVCLAIMNO, rownum, DIAGNOSISCODE, DIAGNOSISDESC, NULL, NULL
	FROM WSL_CLAIM_DIAGNOSIS;

CREATE OR REPLACE VIEW NPHIES_CLAIMPREAUTHDETAILS (PROVCLAIMNO, PREAUTHREFNO, 
		CONSTRAINT "PK_CLAIMPREAUTHDETAILS" PRIMARY KEY ("PROVCLAIMNO", "PREAUTHREFNO") DISABLE) AS
	SELECT PROVCLAIMNO, APPREFNO AS PREAUTHREFNO
	FROM WSL_GENINFO WHERE APPREFNO IS NOT NULL;

CREATE OR REPLACE VIEW NPHIES_CLAIMCARETEAM(PROVCLAIMNO, SEQUENCENO, PHYSICIANID, PHYSICIANNAME, 
		PRACTITIONERROLE, CARETEAMROLE, CARETEAMQUALIFICATION, CONSTRAINT "PK_CLAIMCARETEAM" PRIMARY KEY ("PROVCLAIMNO", "SEQUENCENO") DISABLE) AS
	SELECT PROVCLAIMNO, rownum, PHYID AS PHYSICIANID, PHYNAME AS PHYSICIANNAME, 
		'doctor', 'primary', DEPTCODE AS CARETEAMQUALIFICATION
	FROM WSL_GENINFO;

-- WSD.UNITSERVICETYPE AS SERVICETYPE, calculate factor, payershare, why not use TOTSERVICENETAMT
CREATE OR REPLACE VIEW NPHIES_CLAIMITEM (PROVCLAIMNO, INVOICENO, SEQUENCENO, SERVICETYPE, SERVICECODE, SERVICEDESC,
		NONSTANDARDCODE, NONSTANDARDDESC, UDI, ISPACKAGE, QUANTITY, QUANTITYCODE, UNITPRICE, 
		DISCOUNT, FACTOR, PATIENTSHARE, PAYERSHARE, TAX, NET, STARTDATE, ENDDATE,
		BODYSITECODE, SUBSITECODE, DRUGSELECTIONREASON, PRESCRIBEDDRUGCODE, PHARMACISTSELECTIONREASON, PHARMACISTSUBSTITUTE, REASONPHARMACISTSUBSTITUTE, CONSTRAINT "PK_CLAIMITEM" PRIMARY KEY ("PROVCLAIMNO", "SEQUENCENO") DISABLE) AS
	SELECT WI.PROVCLAIMNO, WI.INVOICENO, rownum, NULL AS SERVICETYPE, NULL AS SERVICECODE, NULL AS SERVICEDESC,
		WSD.SERVICECODE AS NONSTANDARDCODE, WSD.SERVICEDESC AS NONSTANDARDDESC, NULL AS UDI, 'false' AS ISPACKAGE,
		WSD.QTY AS QUANTITY, 'package' AS QUANTITYCODE, WSD.UNITSERVICEPRICE AS UNITPRICE, WSD.TOTSERVICEDISC AS DISCOUNT,  CAST(ROUND(1 - (WSD.TOTSERVICEDISC/(WSD.UNITSERVICEPRICE*WSD.QTY)),3)as numeric(36,3)) AS FACTOR, 
		WSD.TOTSERVICEPATSHARE AS PATIENTSHARE, (NVL(WSD.TOTSERVICEGRSAMT,0)-NVL(WSD.TOTSERVICEDISC,0)-NVL(WSD.TOTSERVICEPATSHARE,0)+NVL(WSD.TOTSERVICENETVATAMOUNT,0)) AS PAYERSHARE, 
		WSD.TOTSERVICENETVATAMOUNT AS TAX, NULL AS NET, WSD.SERVICEDATE AS STARTDATE,
		WSD.SERVICEDATE AS ENDDATE, WSD.TOOTHNO AS BODYSITECODE, NULL, NULL, NULL ,
        CASE 
            WHEN NPHIES_CLAIMPREAUTHDETAILS.PREAUTHREFNO IS NOT NULL THEN 'physician-approval' 
            ELSE 'physician-no-approval'
        END AS PHARMACISTSELECTIONREASON, 
        NULL, 
        NULL
	FROM WSL_INVOICES WI 
    LEFT JOIN WSL_SERVICE_DETAILS WSD ON WI.INVOICENO = WSD.INVOICENO
    LEFT JOIN NPHIES_CLAIMPREAUTHDETAILS ON NPHIES_CLAIMPREAUTHDETAILS.PROVCLAIMNO = WI.PROVCLAIMNO;

	
-- Supporting info remaining 
DECLARE tbl_count number;
sql_stmt long;
BEGIN
SELECT COUNT(*) INTO tbl_count
FROM USER_TABLES
WHERE TABLE_NAME = 'WSL_CLAIM_ATTACHMENT';
IF(tbl_count >= 1) THEN sql_stmt:='
    CREATE OR REPLACE VIEW NPHIES_CLAIMSUPPORTINGINFO(PROVCLAIMNO, SEQUENCENO, CATEGORY, REASON,
		SUPPORTINGVALUE, SUPPORTINGATTACHMENT, ATTACHMENTFILENAME, ATTACHMENTTYPE, CODE,
		TIMINGPERIODFROM, TIMINGPERIODTO, CONSTRAINT "PK_CLAIMSUPPORTINGINFO" PRIMARY KEY ("PROVCLAIMNO", "SEQUENCENO") DISABLE) AS
	SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''temperature'', NULL, TO_CHAR(TEMPERATURE) AS SUPPORTINGVALUE, NULL, NULL, NULL, ''Cel'', NULL, NULL
	FROM WSL_GENINFO WHERE TEMPERATURE IS NOT NULL
	UNION ALL 
	SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''chief-complaint'', NULL, MAINSYMPTOM AS SUPPORTINGVALUE, NULL, NULL, NULL, NULL, NULL, NULL
	FROM WSL_GENINFO WHERE MAINSYMPTOM IS NOT NULL
    UNION ALL
    SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''vital-sign-weight'', NULL, TO_CHAR(WEIGH) AS SUPPORTINGVALUE, NULL, NULL, NULL, ''kg'', NULL, NULL
	FROM WSL_GENINFO WHERE WEIGH IS NOT NULL
    UNION ALL
    SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''hospitalized'', NULL, NULL, NULL, NULL, NULL, NULL, ADMISSIONDATE AS TIMINGPERIODFROM, 
		DISCHARGEDATE AS TIMINGPERIODTO
	FROM WSL_GENINFO WHERE ADMISSIONDATE IS NOT NULL AND DISCHARGEDATE IS NOT NULL
    UNION ALL
    SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''pulse'', NULL, TO_CHAR(PULSE) AS SUPPORTINGVALUE, NULL, NULL, NULL, NULL, NULL, NULL
	FROM WSL_GENINFO WHERE PULSE IS NOT NULL
	UNION ALL
	SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''respiratory-rate'', NULL, TO_CHAR(RESPIRATORYRATE) AS SUPPORTINGVALUE, NULL, NULL, NULL, NULL, NULL, NULL
	FROM WSL_GENINFO WHERE RESPIRATORYRATE IS NOT NULL
	UNION ALL
    SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''info'', NULL, TO_CHAR(RADIOREPORT) AS SUPPORTINGVALUE, NULL, NULL, NULL, NULL, NULL, NULL
	FROM WSL_GENINFO WHERE RADIOREPORT IS NOT NULL
	UNION ALL
	SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''vital-sign-systolic'', NULL, TO_CHAR(BLOODPRESSURE) AS SUPPORTINGVALUE, NULL, NULL, NULL, NULL, NULL, NULL
	FROM WSL_GENINFO WHERE BLOODPRESSURE IS NOT NULL
	UNION ALL
	SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''vital-sign-diastolic'', NULL, TO_CHAR(BLOODPRESSURE) AS SUPPORTINGVALUE, NULL, NULL, NULL, NULL, NULL, NULL
	FROM WSL_GENINFO WHERE BLOODPRESSURE IS NOT NULL
	UNION ALL
	select PROVCLAIMNO_temp AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''lab-test'', NULL,
	case
	when LABCOMPCODE_temp is not null THEN (''LABCODE: '' || LABCOMPCODE_temp||'' ,LABDESC: ''|| LABCOMPDESC_temp  || '' ,LABRESULT: '' || LABRESULT_temp || '' ,LABRESULTUNIT: '' || LABRESULTUNIT_temp || '' ,LABRESULTCOMMENT: '' || LABRESULTCOMMENT_temp || '' ,LABRESULTCDESC: '' || LABRESULTDESC_temp)
	when LABCOMPDESC_temp is not null THEN (''LABCODE: '' || LABCOMPCODE_temp||'' ,LABDESC: ''|| LABCOMPDESC_temp  || '' ,LABRESULT: '' || LABRESULT_temp || '' ,LABRESULTUNIT: '' || LABRESULTUNIT_temp || '' ,LABRESULTCOMMENT: '' || LABRESULTCOMMENT_temp || '' ,LABRESULTCDESC: '' || LABRESULTDESC_temp)
	when LABRESULT_temp is not null THEN (''LABCODE: '' || LABCOMPCODE_temp||'' ,LABDESC: ''|| LABCOMPDESC_temp  || '' ,LABRESULT: '' || LABRESULT_temp || '' ,LABRESULTUNIT: '' || LABRESULTUNIT_temp || '' ,LABRESULTCOMMENT: '' || LABRESULTCOMMENT_temp || '' ,LABRESULTCDESC: '' || LABRESULTDESC_temp)
	when LABRESULTUNIT_temp is not null THEN (''LABCODE: '' || LABCOMPCODE_temp||'' ,LABDESC: ''|| LABCOMPDESC_temp  || '' ,LABRESULT: '' || LABRESULT_temp || '' ,LABRESULTUNIT: '' || LABRESULTUNIT_temp || '' ,LABRESULTCOMMENT: '' || LABRESULTCOMMENT_temp || '' ,LABRESULTCDESC: '' || LABRESULTDESC_temp)
	when LABRESULTCOMMENT_temp is not null THEN (''LABCODE: '' || LABCOMPCODE_temp||'' ,LABDESC: ''|| LABCOMPDESC_temp  || '' ,LABRESULT: '' || LABRESULT_temp || '' ,LABRESULTUNIT: '' || LABRESULTUNIT_temp || '' ,LABRESULTCOMMENT: '' || LABRESULTCOMMENT_temp || '' ,LABRESULTCDESC: '' || LABRESULTDESC_temp)
	when LABRESULTDESC_temp is not null THEN (''LABCODE: '' || LABCOMPCODE_temp||'' ,LABDESC: ''|| LABCOMPDESC_temp  || '' ,LABRESULT: '' || LABRESULT_temp || '' ,LABRESULTUNIT: '' || LABRESULTUNIT_temp || '' ,LABRESULTCOMMENT: '' || LABRESULTCOMMENT_temp || '' ,LABRESULTCDESC: '' || LABRESULTDESC_temp)
	END AS SUPPORTINGVALUE, NULL, NULL, NULL, CODE_temp AS CODE, NULL, NULL
	from (
		SELECT labResult.PROVCLAIMNO AS PROVCLAIMNO_temp,labComponent.LABCOMPCODE AS LABCOMPCODE_temp, labComponent.LABCOMPDESC AS LABCOMPDESC_temp, 
		labComponent.LABRESULT AS LABRESULT_temp, labComponent.LABRESULTUNIT AS LABRESULTUNIT_temp, labComponent.LABRESULTCOMMENT AS LABRESULTCOMMENT_temp, labResult.LABDESC AS LABRESULTDESC_temp,
		labResult.LABTESTCODE AS CODE_temp
		FROM WSL_LAB_RESULT labResult LEFT JOIN WSL_LAB_COMPONENT labComponent ON labResult.LABTESTCODE=labComponent.LABTESTCODE and labResult.SERIAL=labComponent.SERIAL and labResult.PROVCLAIMNO=labComponent.PROVCLAIMNO)
	UNION ALL
	SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''last-menstrual-period'', NULL, NULL, NULL, NULL, NULL, NULL, LASTMENSTRUATIONPERIOD AS TIMINGPERIODFROM, NULL
	FROM WSL_GENINFO WHERE LASTMENSTRUATIONPERIOD IS NOT NULL  
    UNION ALL
    SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''attachment'', NULL, NULL, FILECONTENT, FILENAME, NULL, NULL, NULL, NULL
	FROM WSL_CLAIM_ATTACHMENT WHERE FILENAME IS NOT NULL';
EXECUTE IMMEDIATE sql_stmt;
ELSE 
EXECUTE IMMEDIATE '
CREATE OR REPLACE VIEW NPHIES_CLAIMSUPPORTINGINFO(PROVCLAIMNO, SEQUENCENO, CATEGORY, REASON,
		SUPPORTINGVALUE, SUPPORTINGATTACHMENT, ATTACHMENTFILENAME, ATTACHMENTTYPE, CODE,
		TIMINGPERIODFROM, TIMINGPERIODTO, CONSTRAINT "PK_CLAIMSUPPORTINGINFO" PRIMARY KEY ("PROVCLAIMNO", "SEQUENCENO") DISABLE) AS
	SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''temperature'', NULL, TO_CHAR(TEMPERATURE) AS SUPPORTINGVALUE, NULL, NULL, NULL, ''Cel'', NULL, NULL
	FROM WSL_GENINFO WHERE TEMPERATURE IS NOT NULL
	UNION ALL 
	SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''chief-complaint'', NULL, MAINSYMPTOM AS SUPPORTINGVALUE, NULL, NULL, NULL, NULL, NULL, NULL
	FROM WSL_GENINFO WHERE MAINSYMPTOM IS NOT NULL
    UNION ALL
    SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''vital-sign-weight'', NULL, TO_CHAR(WEIGH) AS SUPPORTINGVALUE, NULL, NULL, NULL, ''kg'', NULL, NULL
	FROM WSL_GENINFO WHERE WEIGH IS NOT NULL
    UNION ALL
    SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''hospitalized'', NULL, NULL, NULL, NULL, NULL, NULL, ADMISSIONDATE AS TIMINGPERIODFROM, 
		DISCHARGEDATE AS TIMINGPERIODTO
	FROM WSL_GENINFO WHERE ADMISSIONDATE IS NOT NULL AND DISCHARGEDATE IS NOT NULL
    UNION ALL
    SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''pulse'', NULL, TO_CHAR(PULSE) AS SUPPORTINGVALUE, NULL, NULL, NULL, NULL, NULL, NULL
	FROM WSL_GENINFO WHERE PULSE IS NOT NULL
	UNION ALL
    SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''info'', NULL, TO_CHAR(RADIOREPORT) AS SUPPORTINGVALUE, NULL, NULL, NULL, NULL, NULL, NULL
	FROM WSL_GENINFO WHERE RADIOREPORT IS NOT NULL
	UNION ALL
	SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''respiratory-rate'', NULL, TO_CHAR(RESPIRATORYRATE) AS SUPPORTINGVALUE, NULL, NULL, NULL, NULL, NULL, NULL
	FROM WSL_GENINFO WHERE RESPIRATORYRATE IS NOT NULL
	UNION ALL
	SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''vital-sign-systolic'', NULL, TO_CHAR(BLOODPRESSURE) AS SUPPORTINGVALUE, NULL, NULL, NULL, NULL, NULL, NULL
	FROM WSL_GENINFO WHERE BLOODPRESSURE IS NOT NULL
	UNION ALL
	SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''vital-sign-diastolic'', NULL, TO_CHAR(BLOODPRESSURE) AS SUPPORTINGVALUE, NULL, NULL, NULL, NULL, NULL, NULL
	FROM WSL_GENINFO WHERE BLOODPRESSURE IS NOT NULL
	UNION ALL
    SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''last-menstrual-period'', NULL, NULL, NULL, NULL, NULL, NULL, LASTMENSTRUATIONPERIOD AS TIMINGPERIODFROM, NULL
	FROM WSL_GENINFO WHERE LASTMENSTRUATIONPERIOD IS NOT NULL  
	UNION ALL
		select PROVCLAIMNO_temp AS PROVCLAIMNO, func_seq_test(''supporting_sequence'') AS SEQUENCENO, ''lab-test'', NULL,
	case
	when LABCOMPCODE_temp is not null THEN (''LABCODE: '' || LABCOMPCODE_temp||'' ,LABDESC: ''|| LABCOMPDESC_temp  || '' ,LABRESULT: '' || LABRESULT_temp || '' ,LABRESULTUNIT: '' || LABRESULTUNIT_temp || '' ,LABRESULTCOMMENT: '' || LABRESULTCOMMENT_temp || '' ,LABRESULTCDESC: '' || LABRESULTDESC_temp)
	when LABCOMPDESC_temp is not null THEN (''LABCODE: '' || LABCOMPCODE_temp||'' ,LABDESC: ''|| LABCOMPDESC_temp  || '' ,LABRESULT: '' || LABRESULT_temp || '' ,LABRESULTUNIT: '' || LABRESULTUNIT_temp || '' ,LABRESULTCOMMENT: '' || LABRESULTCOMMENT_temp || '' ,LABRESULTCDESC: '' || LABRESULTDESC_temp)
	when LABRESULT_temp is not null THEN (''LABCODE: '' || LABCOMPCODE_temp||'' ,LABDESC: ''|| LABCOMPDESC_temp  || '' ,LABRESULT: '' || LABRESULT_temp || '' ,LABRESULTUNIT: '' || LABRESULTUNIT_temp || '' ,LABRESULTCOMMENT: '' || LABRESULTCOMMENT_temp || '' ,LABRESULTCDESC: '' || LABRESULTDESC_temp)
	when LABRESULTUNIT_temp is not null THEN (''LABCODE: '' || LABCOMPCODE_temp||'' ,LABDESC: ''|| LABCOMPDESC_temp  || '' ,LABRESULT: '' || LABRESULT_temp || '' ,LABRESULTUNIT: '' || LABRESULTUNIT_temp || '' ,LABRESULTCOMMENT: '' || LABRESULTCOMMENT_temp || '' ,LABRESULTCDESC: '' || LABRESULTDESC_temp)
	when LABRESULTCOMMENT_temp is not null THEN (''LABCODE: '' || LABCOMPCODE_temp||'' ,LABDESC: ''|| LABCOMPDESC_temp  || '' ,LABRESULT: '' || LABRESULT_temp || '' ,LABRESULTUNIT: '' || LABRESULTUNIT_temp || '' ,LABRESULTCOMMENT: '' || LABRESULTCOMMENT_temp || '' ,LABRESULTCDESC: '' || LABRESULTDESC_temp)
	when LABRESULTDESC_temp is not null THEN (''LABCODE: '' || LABCOMPCODE_temp||'' ,LABDESC: ''|| LABCOMPDESC_temp  || '' ,LABRESULT: '' || LABRESULT_temp || '' ,LABRESULTUNIT: '' || LABRESULTUNIT_temp || '' ,LABRESULTCOMMENT: '' || LABRESULTCOMMENT_temp || '' ,LABRESULTCDESC: '' || LABRESULTDESC_temp)
	END AS SUPPORTINGVALUE, NULL, NULL, NULL, CODE_temp AS CODE, NULL, NULL
	from (
		SELECT labResult.PROVCLAIMNO AS PROVCLAIMNO_temp,labComponent.LABCOMPCODE AS LABCOMPCODE_temp, labComponent.LABCOMPDESC AS LABCOMPDESC_temp, 
		labComponent.LABRESULT AS LABRESULT_temp, labComponent.LABRESULTUNIT AS LABRESULTUNIT_temp, labComponent.LABRESULTCOMMENT AS LABRESULTCOMMENT_temp, labResult.LABDESC AS LABRESULTDESC_temp,
		labResult.LABTESTCODE AS CODE_temp
		FROM WSL_LAB_RESULT labResult LEFT JOIN WSL_LAB_COMPONENT labComponent ON labResult.LABTESTCODE=labComponent.LABTESTCODE and labResult.SERIAL=labComponent.SERIAL and labResult.PROVCLAIMNO=labComponent.PROVCLAIMNO)';
END IF;
END;
/


-- Accident details
CREATE OR REPLACE VIEW NPHIES_CLAIMACCIDENTDETAIL(PROVCLAIMNO, ACCIDENTTYPE, ACCIDENTDATE,
		ADDRESSSTREETNAME, ADDRESSCITY, ADDRESSSTATE, ADDRESSCOUNTRY) AS
	SELECT NULL AS PROVCLAIMNO, NULL, NULL, NULL, NULL, NULL, NULL
	FROM WSL_GENINFO where PROVCLAIMNO='-9999999999999';

CREATE OR REPLACE VIEW NPHIES_CLAIMVISIONPRESCRIPTION(PROVCLAIMNO, VISIONPRESCRIPTIONID, DATEWRITTEN,
		CARETEAMSEQUENCE, PRODUCT, EYE, SPHERE, CYLINDER, AXIS, PRISMAMOUNT,
		PRISMBASE, MULTIFOCALPOWER, LENSPOWER, LENSBACKCURVE, LENSDIAMETER, LENSDURATION,
		LENSCOLOR, LENSBRAND, LENSNOTE, LENSDURATIONUNIT) AS
	SELECT NULL AS PROVCLAIMNO, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
		NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
	FROM WSL_GENINFO where PROVCLAIMNO='-9999999999999';

CREATE OR REPLACE VIEW NPHIES_ITEMDIAGNOSIS(PROVCLAIMNO, DIAGNOSISSEQUENCENO, ITEMSEQUENCENO) AS
	SELECT NULL AS PROVCLAIMNO , NULL AS DIAGNOSISSEQUENCENO, NULL AS ITEMSEQUENCENO
    FROM WSL_GENINFO where PROVCLAIMNO='-9999999999999';

CREATE OR REPLACE VIEW NPHIES_ITEMCARETEAM(PROVCLAIMNO, CARETEAMSEQUENCENO, ITEMSEQUENCENO) AS
	SELECT NULL AS PROVCLAIMNO , NULL AS CARETEAMSEQUENCENO, NULL AS ITEMSEQUENCENO
    FROM WSL_GENINFO where PROVCLAIMNO='-9999999999999';

CREATE OR REPLACE VIEW NPHIES_ITEMSUPPORTINGINFO(PROVCLAIMNO, SUPPORTINGINFOSEQUENCENO, ITEMSEQUENCENO) AS
	SELECT NULL AS PROVCLAIMNO , NULL AS SUPPORTINGINFOSEQUENCENO, NULL AS ITEMSEQUENCENO
    FROM WSL_GENINFO where PROVCLAIMNO='-9999999999999';
	
CREATE OR REPLACE VIEW NPHIES_CLAIMITEMDETAILS(ITEMSEQUENCENO, PROVCLAIMNO, SEQUENCENO,
		SERVICETYPE, SERVICECODE, SERVICEDESC, NONSTANDARDCODE, NONSTANDARDDESC, UDI, 
		QUANTITY, QUANTITYCODE, UNITPRICE, TAX, NET , PHARMACISTSELECTIONREASON , PHARMACISTSUBSTITUTE ,REASONPHARMACISTSUBSTITUTE,PRESCRIBEDDRUGCODE) AS
	SELECT NULL, NULL AS PROVCLAIMNO, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
		NULL, NULL, NULL , NULL, NULL, NULL, NULL
	FROM WSL_GENINFO where PROVCLAIMNO='-9999999999999';
	
CREATE OR REPLACE VIEW NPHIES_CLAIMENCOUNTERS(PROVCLAIMNO, ENCOUNTERID, ENCOUNTERSTARTDATE,
		ENCOUNTERENDDATE, ENCOUNTERCLASS, ENCOUNTERSERVICETYPE, PRIORITY, HOSPITALIZATIONORIGIN,
		HOSPITALADMISSIONSOURCE, HOSPITALREADMISSION, HOSPITALDISCHARGEDISPOSITION, SERVICEPROVIDER, ENCOUNTERSTATUS) AS
	SELECT NULL AS PROVCLAIMNO, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
	FROM WSL_GENINFO where PROVCLAIMNO='-9999999999999';
