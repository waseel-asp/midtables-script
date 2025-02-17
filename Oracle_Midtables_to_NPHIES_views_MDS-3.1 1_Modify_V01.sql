-- DROP SEQUENCE supporting_sequence;
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

-- MARITAL STATUS - MAPPING (MANDATORY)
-- OCCUPATION - 'unknown' (MANDATORY)
-- RELIGION - '98' ('NOT AVAILABLE')

CREATE OR REPLACE VIEW NPHIES_BENEFICIARY(BENEFICIARYID PRIMARY KEY DISABLE NOVALIDATE, PATIENTFILENO, FIRSTNAME, MIDDLENAME, LASTNAME,
		FULLNAME, DOB, GENDER, NATIONALITY, DOCUMENTID, DOCUMENTTYPE, CONTACTNUMBER, EHEALTHID,
		RESIDENCYTYPE, MARITALSTATUS, BLOODGROUP, PREFERREDLANGUAGE, EMAIL, ADDRESSLINE,
		ADDRESSSTREETNAME, ADDRESSCITY, ADDRESSDISTRICT, ADDRESSSTATE, ADDRESSPOSTALCODE, ADDRESSCOUNTRY, PROVCLAIMNO, OCCUPATION, RELIGION) AS
	SELECT rowid AS BENEFICIARYID, PATFILENO AS PATIENTFILENO, FIRSTNAME, MIDDLENAME, LASTNAME, FULLNAME,
		MEMBERDOB AS DOB, GENDER, NATIONALITY AS NATIONALITY, NATIONALID AS DOCUMENTID, NULL, NULL, NULL, NULL, NULL,
		NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, PROVCLAIMNO, 'unknown' AS OCCUPATION, '98' AS RELIGION
	FROM WSL_GENINFO;

-- POLICY HOLDER - ACCCODE (MANDATORY)
CREATE OR REPLACE VIEW NPHIES_COVERAGE (COVERAGEID, MEMBERID, EXPIRYDATE, PAYERNPHIESID,
		TPANPHIESID, RELATIONWITHSUBSCRIBER, POLICYNUMBER, POLICYHOLDER, COVERAGETYPE, BENEFICIARYID, PROVCLAIMNO) AS
	SELECT NPHIES_BENEFICIARY.rowid AS COVERAGEID, MEMBERID AS MEMBERID, NULL, PAYERID AS PAYERNPHIESID, TPAID AS TPANPHIESID, NULL, POLICYNO AS POLICYNUMBER,
		ACCCODE AS POLICYHOLDER, 'EHCPOL' AS COVERAGETYPE, NPHIES_BENEFICIARY.BENEFICIARYID AS BENEFICIARYID, WSL_GENINFO.PROVCLAIMNO
	FROM WSL_GENINFO LEFT JOIN NPHIES_BENEFICIARY ON WSL_GENINFO.PROVCLAIMNO=NPHIES_BENEFICIARY.PROVCLAIMNO;

-- TYPE - CHI Inquiry 'class'
-- VALUE - from CHI Inquiry 'ClassName'
CREATE OR REPLACE VIEW NPHIES_COVERAGE_CLASS (COVERAGECLASSID, COVERAGEID, TYPE, VALUE, NAME) AS
	SELECT NULL  as COVERAGECLASSID ,NULL AS COVERAGEID, NULL AS TYPE, NULL AS VALUE ,NULL AS NAME
	FROM WSL_GENINFO WHERE PROVCLAIMNO='-9999999999999';


CREATE OR REPLACE VIEW NPHIES_CLAIMINFO (PROVCLAIMNO PRIMARY KEY DISABLE NOVALIDATE, EPISODEID, ISNEWBORN, CLAIMTYPE,
		CLAIMSUBTYPE, PROVIDERNPHIESID, CLAIMCREATEDDATE, ACCOUNTINGPERIOD, BILLABLEPERIODSTART, BILLABLEPERIODEND,
		ELIGIBILITYRESPONSEID, ELIGIBILITYIDENTIFIERURL, ELIGIBILITYOFFLINEID, ELIGIBILITYOFFLINEDATE,
		PREAUTHOFFLINEDATE, PREAUTHRESPONSEID, PREAUTHIDENTIFIERURL, PAYEETYPE, PAYEEID, COVERAGEID, BENEFICIARYID, SUBSCRIBERID, TOTAL,ISREFERRAL,REFERRINGPROVIDERNAME ,PRESCRIPTION) AS
	SELECT WSL_GENINFO.PROVCLAIMNO, WSL_GENINFO.PROVCLAIMNO AS EPISODEID, NULL, DEPTCODE AS CLAIMTYPE,
		CLAIMTYPE AS CLAIMSUBTYPE, PROVIDERID AS PROVIDERNPHIESID, TO_DATE(TO_CHAR(CLAIMDATE, 'yyyy-mm-dd'),'yyyy-mm-dd') AS CLAIMCREATEDDATE, CLAIMDATE AS ACCOUNTINGPERIOD, NULL,
		NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'provider' AS PAYEETYPE, PROVIDERID AS PAYEEID , NPHIES_COVERAGE.COVERAGEID AS COVERAGEID, 
		NPHIES_BENEFICIARY.BENEFICIARYID AS BENEFICIARYID,NULL, TOTCLAIMNETAMT AS TOTAL ,NULL AS ISREFERRAL,NULL AS REFERRINGPROVIDERNAME,NULL AS PRESCRIPTION
	FROM WSL_GENINFO LEFT JOIN NPHIES_BENEFICIARY ON WSL_GENINFO.PROVCLAIMNO=NPHIES_BENEFICIARY.PROVCLAIMNO 
	LEFT JOIN NPHIES_COVERAGE ON NPHIES_BENEFICIARY.BENEFICIARYID=NPHIES_COVERAGE.BENEFICIARYID;

-- CONDITIONONSET - NULL
CREATE OR REPLACE VIEW NPHIES_CLAIMDIAGNOSIS (PROVCLAIMNO, SEQUENCENO, DIAGNOSISCODE, DIAGNOSISDESC, 
		DIAGNOSISTYPE, ONADMISSION, CONDITIONONSET,
		CONSTRAINT "PK_NPHIES_CLAIMDIAGNOSIS" PRIMARY KEY ("PROVCLAIMNO", "DIAGNOSISCODE") DISABLE) AS
	SELECT PROVCLAIMNO, rownum, DIAGNOSISCODE, DIAGNOSISDESC, NULL, NULL, NULL AS CONDITIONONSET
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

-- ISMATERNITY  - SPECIFIC DIAGNOSIS CODE AND DEPARTMENT IS OBGYN
CREATE OR REPLACE VIEW NPHIES_CLAIMITEM (PROVCLAIMNO, INVOICENO, SEQUENCENO, SERVICETYPE, SERVICECODE, SERVICEDESC,
		NONSTANDARDCODE, NONSTANDARDDESC, UDI, ISPACKAGE, QUANTITY, QUANTITYCODE, UNITPRICE, 
		DISCOUNT, FACTOR, PATIENTSHARE, PAYERSHARE, TAX, NET, STARTDATE, ENDDATE,
		BODYSITECODE, SUBSITECODE, DRUGSELECTIONREASON, PRESCRIBEDDRUGCODE, PHARMACISTSELECTIONREASON, PHARMACISTSUBSTITUTE, REASONPHARMACISTSUBSTITUTE,
		ISMATERNITY, CONSTRAINT "PK_CLAIMITEM" PRIMARY KEY ("PROVCLAIMNO", "SEQUENCENO") DISABLE) AS
	SELECT WI.PROVCLAIMNO, WI.INVOICENO, rownum, NULL AS SERVICETYPE, NULL AS SERVICECODE, NULL AS SERVICEDESC,
		WSD.SERVICECODE AS NONSTANDARDCODE, WSD.SERVICEDESC AS NONSTANDARDDESC, NULL AS UDI, 'false' AS ISPACKAGE,
		WSD.QTY AS QUANTITY, 'package' AS QUANTITYCODE, WSD.UNITSERVICEPRICE AS UNITPRICE, WSD.TOTSERVICEDISC AS DISCOUNT,  CAST(ROUND(1 - (WSD.TOTSERVICEDISC/(WSD.UNITSERVICEPRICE*WSD.QTY)),3)as numeric(36,3)) AS FACTOR, 
		WSD.TOTSERVICEPATSHARE AS PATIENTSHARE, (NVL(WSD.TOTSERVICEGRSAMT,0)-NVL(WSD.TOTSERVICEDISC,0)-NVL(WSD.TOTSERVICEPATSHARE,0)+NVL(WSD.TOTSERVICENETVATAMOUNT,0)) AS PAYERSHARE, 
		WSD.TOTSERVICENETVATAMOUNT AS TAX, NULL AS NET, WSD.SERVICEDATE AS STARTDATE,
		WSD.SERVICEDATE AS ENDDATE, WSD.TOOTHNO AS BODYSITECODE, NULL, NULL, NULL,
        NULL,
        NULL, 
        NULL,
        NULL
	FROM WSL_INVOICES WI 
    LEFT JOIN WSL_SERVICE_DETAILS WSD ON WI.INVOICENO = WSD.INVOICENO
    LEFT JOIN NPHIES_CLAIMPREAUTHDETAILS ON NPHIES_CLAIMPREAUTHDETAILS.PROVCLAIMNO = WI.PROVCLAIMNO;

CREATE OR REPLACE VIEW NPHIES_PROVCLAIMNO_SERVICEDATE(PROVCLAIMNO,SERVICEDATE) AS
    SELECT WG.PROVCLAIMNO, MIN(WSD.SERVICEDATE) FROM WSL_GENINFO WG
    JOIN WSL_INVOICES WI ON WI.PROVCLAIMNO = WG.PROVCLAIMNO
    JOIN WSL_SERVICE_DETAILS WSD ON WI.INVOICENO = WSD.INVOICENO GROUP BY WG.PROVCLAIMNO, WSD.SERVICEDATE;



CREATE OR REPLACE VIEW NPHIES_CLAIMSUPPORTINGINFO(PROVCLAIMNO, SEQUENCENO, CATEGORY, REASON,
		SUPPORTINGVALUE, SUPPORTINGATTACHMENT, ATTACHMENTFILENAME, ATTACHMENTTYPE, CODE,
		TIMINGPERIODFROM, TIMINGPERIODTO,UNIT, CONSTRAINT "PK_CLAIMSUPPORTINGINFO" PRIMARY KEY ("PROVCLAIMNO", "SEQUENCENO") DISABLE) AS
	SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, func_seq_test('supporting_sequence') AS SEQUENCENO, 'temperature', NULL, TO_CHAR(TEMPERATURE) AS SUPPORTINGVALUE, NULL, NULL, NULL, 'Cel' AS CODE,
	 NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL,NULL
        	FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO WHERE WG.TEMPERATURE IS NOT NULL

	UNION ALL 
	SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test('supporting_sequence') AS SEQUENCENO, 'chief-complaint', NULL, MAINSYMPTOM AS SUPPORTINGVALUE, NULL, NULL, NULL, NULL, NULL, NULL,NULL
	FROM WSL_GENINFO WHERE MAINSYMPTOM IS NOT NULL

	UNION ALL

    SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test('supporting_sequence') AS SEQUENCENO, 'patient-history', NULL, MAINSYMPTOM AS SUPPORTINGVALUE, NULL, NULL, NULL, NULL, NULL, NULL,NULL
    FROM WSL_GENINFO WHERE MAINSYMPTOM IS NOT NULL

    UNION ALL

    SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test('supporting_sequence') AS SEQUENCENO, 'history-of-present-illness', NULL, MAINSYMPTOM AS SUPPORTINGVALUE, NULL, NULL, NULL, NULL, NULL, NULL,NULL
    FROM WSL_GENINFO WHERE MAINSYMPTOM IS NOT NULL

    UNION ALL

    SELECT WSG.PROVCLAIMNO AS PROVCLAIMNO, func_seq_test('supporting_sequence') AS SEQUENCENO, 'treatment-plan', NULL,
    (SELECT LISTAGG(WSD.SERVICECODE || ' - ' || WSD.SERVICEDESC , ', ' ) WITHIN GROUP (ORDER BY WSD.SERVICECODE)
    FROM WSL_SERVICE_DETAILS WSD JOIN WSL_INVOICES WI ON WSD.INVOICENO = WI.INVOICENO
    JOIN WSL_GENINFO WG ON WI.PROVCLAIMNO = WG.PROVCLAIMNO where WSD.SERVICECODE IS NOT NULL AND WSD.SERVICEDESC IS NOT NULL AND WG.PROVCLAIMNO = WSG.PROVCLAIMNO)
    AS SUPPORTINGVALUE, NULL, NULL, NULL, NULL, NULL, NULL,NULL FROM WSL_GENINFO WSG

    UNION ALL

    -- TIMINGPERIODFROM - min (serviceDate from service_details)
    SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, func_seq_test('supporting_sequence') AS SEQUENCENO, 'vital-sign-weight', NULL, TO_CHAR(WEIGH) AS SUPPORTINGVALUE, NULL, NULL, NULL, 'kg' as CODE,
    NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL,NULL
    	FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO WHERE WG.WEIGH IS NOT NULL

	UNION ALL
	-- TIMINGPERIODFROM - min (serviceDate from service_details)
        SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, func_seq_test('supporting_sequence') AS SEQUENCENO, 'vital-sign-height', '999.9', NULL, NULL, NULL, NULL, NULL,
         NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL,NULL
            	FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO
    UNION ALL
    -- TIMINGPERIODFROM - min (serviceDate from service_details)
       SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, func_seq_test('supporting_sequence') AS SEQUENCENO, 'oxygen-saturation', '999', NULL, NULL, NULL, NULL, NULL,
        	NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL,NULL
            FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO

    UNION ALL
    -- should be removed after deployment of MDS changes.
    SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test('supporting_sequence') AS SEQUENCENO, 'hospitalized', NULL, NULL, NULL, NULL, NULL, NULL, ADMISSIONDATE AS TIMINGPERIODFROM, 
		DISCHARGEDATE AS TIMINGPERIODTO,NULL
	FROM WSL_GENINFO WHERE ADMISSIONDATE IS NOT NULL AND DISCHARGEDATE IS NOT NULL

    UNION ALL
    -- significantsign - physical examnation
    SELECT PROVCLAIMNO AS PROVCLAIMNO, func_seq_test('supporting_sequence') AS SEQUENCENO, 'physical-examination', NULL, TO_CHAR(SIGNIFICANTSIGN), NULL, NULL, NULL, NULL, NULL, NULL,NULL
        	FROM WSL_GENINFO WHERE SIGNIFICANTSIGN IS NOT NULL

    UNION ALL
    SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, func_seq_test('supporting_sequence') AS SEQUENCENO, 'pulse', NULL, TO_CHAR(PULSE) AS SUPPORTINGVALUE, NULL, NULL, NULL, '/min' AS CODE ,
     NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL,NULL
            	FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO WHERE WG.PULSE IS NOT NULL

	UNION ALL
	SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, func_seq_test('supporting_sequence') AS SEQUENCENO, 'respiratory-rate', NULL, TO_CHAR(RESPIRATORYRATE) AS SUPPORTINGVALUE, NULL, NULL, NULL, '/min' AS CODE,
	NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL,NULL
         FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO WHERE WG.RESPIRATORYRATE IS NOT NULL

	UNION ALL
    -- TIMINGPERIODFROM - min (serviceDate from service_details)
	SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, func_seq_test('supporting_sequence') AS SEQUENCENO, 'vital-sign-systolic', NULL, TO_CHAR(BLOODPRESSURE) AS SUPPORTINGVALUE, NULL, NULL, NULL, 'mm[Hg]' AS CODE,
	NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL,NULL
    	FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO WHERE WG.BLOODPRESSURE IS NOT NULL

	UNION ALL
    -- TIMINGPERIODFROM - min (serviceDate from service_details)
	SELECT WG.PROVCLAIMNO AS PROVCLAIMNO, func_seq_test('supporting_sequence') AS SEQUENCENO, 'vital-sign-diastolic', NULL, TO_CHAR(BLOODPRESSURE) AS SUPPORTINGVALUE, NULL, NULL, NULL, 'mm[Hg]' AS CODE,
	 NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL,NULL
	FROM WSL_GENINFO WG JOIN NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = WG.PROVCLAIMNO WHERE WG.BLOODPRESSURE IS NOT NULL

    UNION ALL

	SELECT labResult.PROVCLAIMNO AS PROVCLAIMNO, func_seq_test('supporting_sequence') AS SEQUENCENO, 'lab-test', NULL, 
		('LABCODE: ' || labComponent.LABCOMPCODE||' ,LABDESC: ' || labComponent.LABCOMPDESC  || ' ,LABRESULT: ' || labComponent.LABRESULT || ' ,LABRESULTUNIT: ' 
		|| labComponent.LABRESULTUNIT || ' ,LABRESULTCOMMENT: ' || labComponent.LABRESULTCOMMENT) AS SUPPORTINGVALUE, NULL,
		NULL, NULL, labResult.LABTESTCODE AS CODE, NPS.SERVICEDATE AS TIMINGPERIODFROM, NULL,NULL
	FROM WSL_LAB_RESULT labResult LEFT JOIN WSL_LAB_COMPONENT labComponent ON labResult.LABTESTCODE=labComponent.LABTESTCODE and labResult.SERIAL=labComponent.SERIAL
	join NPHIES_PROVCLAIMNO_SERVICEDATE NPS ON NPS.PROVCLAIMNO = labResult.PROVCLAIMNO;
    
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

-- ENCOUNTERID - PROVCLAIMNO
-- ENCOUNTERSTARTDATE - MIN(SERVICEDATE)
-- ENCOUNTERSTATUS - 'unknown'
-- ENCOUNTERCLASS - 'AMB'.
-- SERVICEEVENTTYPE - if VISITTYPE = 'new' or 'referral' then 'ICSE' else if VISITTYPE = 'SCSE' else 'ICSE'.
CREATE OR REPLACE VIEW NPHIES_CLAIMENCOUNTERS(PROVCLAIMNO, ENCOUNTERID, ENCOUNTERSTARTDATE,
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


CREATE OR REPLACE VIEW NPHIESENCOUNTERHOSPITALIZATION (PROVCLAIMNO, ENCOUNTERHOSPITALIZATIONID, HOSPITALADMISSIONSPECIALITY,
     HOSPITALDISCHARGESPECIALITY, HOSPITALINTENDEDLENGTHOFSTAY, HOSPITALIZATIONORIGIN, HOSPITALADMISSIONSOURCE,
     HOSPITALREADMISSION, HOSPITALDISCHARGEDISPOSITION ,ENCOUNTERID ) AS
    SELECT NULL AS PROVCLAIMNO,
    NULL AS ENCOUNTERHOSPITALIZATIONID,
    NULL AS HOSPITALADMISSIONSPECIALITY,
    NULL AS HOSPITALDISCHARGESPECIALITY,
	NULL AS HOSPITALINTENDEDLENGTHOFSTAY,
    NULL AS HOSPITALIZATIONORIGIN,
	NULL AS HOSPITALADMISSIONSOURCE,
    NULL AS HOSPITALREADMISSION,
    NULL AS HOSPITALDISCHARGEDISPOSITION,
    NULL AS ENCOUNTERID
	FROM WSL_GENINFO
	WHERE PROVCLAIMNO = '-9999999999999';


CREATE OR REPLACE VIEW NPHIES_ENCOUNTEREMERGENCY ( PROVCLAIMNO, ENCOUNTEREMERGENCYID, EMERGENCYARRIVALCODE, EMERGENCYSERVICESTART,
    EMERGENCYDEPARTMENTDISPOSITION, TRIAGECATEGORY, TRIAGEDATE , ENCOUNTERID) AS
    SELECT NULL AS PROVCLAIMNO,
    NULL AS ENCOUNTEREMERGENCYID,
    NULL AS EMERGENCYARRIVALCODE,
    NULL AS EMERGENCYSERVICESTART,
    NULL AS EMERGENCYDEPARTMENTDISPOSITION,
    NULL AS TRIAGECATEGORY,
    NULL AS TRIAGEDATE,
    NULL AS ENCOUNTERID
    FROM WSL_GENINFO WHERE PROVCLAIMNO ='-9999999999999';
