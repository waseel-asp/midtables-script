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
		TIMINGPERIODFROM, TIMINGPERIODTO,UNIT) AS 
	SELECT PROVCLAIMNO AS PROVCLAIMNO , Support_Type, ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS SEQUENCENO,NULL,SUPPORTINGVALUE, FILECONTENT, FILENAME,
	NULL AS NotNeeded_4,CODE,TIMINGPERIODFROM, TIMINGPERIODTO , NULL AS UNIT
	FROM
	(SELECT PROVCLAIMNO AS PROVCLAIMNO, ''temperature'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),TEMPERATURE) AS SUPPORTINGVALUE, NULL AS FILECONTENT
	, NULL FILENAME, NULL AS NotNeeded_4, ''Cel'' As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO , NULL AS UNIT
	FROM WSL_GENINFO WHERE TEMPERATURE IS NOT NULL
	UNION ALL 
	SELECT PROVCLAIMNO AS PROVCLAIMNO, ''chief-complaint'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, MAINSYMPTOM AS SUPPORTINGVALUE, NULL AS FILECONTENT, NULL FILENAME
	, NULL AS NotNeeded_4, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO , NULL AS UNIT
	FROM WSL_GENINFO WHERE MAINSYMPTOM IS NOT NULL
    UNION ALL
    SELECT PROVCLAIMNO AS PROVCLAIMNO, ''vital-sign-weight'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),WEIGH) AS SUPPORTINGVALUE, NULL AS FILECONTENT
	, NULL FILENAME, NULL AS NotNeeded_4, ''kg'' As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO , NULL AS UNIT
	FROM WSL_GENINFO WHERE WEIGH IS NOT NULL
    UNION ALL
    SELECT PROVCLAIMNO AS PROVCLAIMNO, ''hospitalized'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4, NULL AS CODE
	, NULL, ADMISSIONDATE AS TIMINGPERIODFROM, DISCHARGEDATE AS TIMINGPERIODTO , NULL AS UNIT
	FROM WSL_GENINFO WHERE ADMISSIONDATE IS NOT NULL AND DISCHARGEDATE IS NOT NULL
    UNION ALL
    SELECT PROVCLAIMNO AS PROVCLAIMNO, ''pulse'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),PULSE) AS SUPPORTINGVALUE, NULL AS FILECONTENT
	, NULL FILENAME, NULL AS NotNeeded_4, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO, NULL AS UNIT
	FROM WSL_GENINFO WHERE PULSE IS NOT NULL
	UNION ALL
	SELECT PROVCLAIMNO AS PROVCLAIMNO, ''respiratory-rate'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),RESPIRATORYRATE) AS SUPPORTINGVALUE
	, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO, NULL AS UNIT
	FROM WSL_GENINFO WHERE RESPIRATORYRATE IS NOT NULL
	UNION ALL
	SELECT PROVCLAIMNO AS PROVCLAIMNO, ''vital-sign-systolic'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),BLOODPRESSURE) AS SUPPORTINGVALUE
	, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4L, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO, NULL AS UNIT
	FROM WSL_GENINFO WHERE BLOODPRESSURE IS NOT NULL
	UNION ALL
	SELECT PROVCLAIMNO AS PROVCLAIMNO, ''vital-sign-diastolic'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),BLOODPRESSURE) AS SUPPORTINGVALUE
	, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO, NULL AS UNIT
	FROM WSL_GENINFO WHERE BLOODPRESSURE IS NOT NULL
	UNION ALL
	SELECT PROVCLAIMNO AS PROVCLAIMNO, ''info'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),RADIOREPORT) AS SUPPORTINGVALUE
	, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4L, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO, NULL AS UNIT
	FROM WSL_GENINFO WHERE RADIOREPORT IS NOT NULL AND CONVERT(VARCHAR,RADIOREPORT) !=''''
	UNION ALL
	SELECT labResult.PROVCLAIMNO AS PROVCLAIMNO, ''lab-test'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, 
		(''LABCODE: '' + ISNULL(labComponent.LABCOMPCODE,'''') +'' ,LABDESC: '' + ISNULL(labComponent.LABCOMPDESC,'''')  + '' ,LABRESULT: '' + ISNULL(labComponent.LABRESULT,'''') + '' ,LABRESULTUNIT: '' 
		+ ISNULL(labComponent.LABRESULTUNIT,'''') + '' ,LABRESULTCOMMENT: '' + ISNULL(labComponent.LABRESULTCOMMENT,'''')) AS SUPPORTINGVALUE, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4
		, labResult.LABTESTCODE AS CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO , NULL AS UNIT
	FROM WSL_LAB_RESULT labResult LEFT JOIN WSL_LAB_COMPONENT labComponent ON labResult.LABTESTCODE=labComponent.LABTESTCODE and labResult.SERIAL=labComponent.SERIAL and labResult.PROVCLAIMNO=labComponent.PROVCLAIMNO 
	UNION ALL 
	SELECT PROVCLAIMNO AS PROVCLAIMNO, ''last-menstrual-period'', NULL AS SEQUENCENO,  NULL, NULL, NULL, NULL, NULL, NULL, LASTMENSTRUATIONPERIOD AS TIMINGPERIODFROM, NULL, NULL AS UNIT
	FROM WSL_GENINFO WHERE LASTMENSTRUATIONPERIOD IS NOT NULL 	
	UNION ALL
	SELECT PROVCLAIMNO AS PROVCLAIMNO, ''attachment'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1,NULL AS SUPPORTINGVALUE
	, FILECONTENT , FILENAME , NULL AS NotNeeded_4, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO, NULL AS UNIT
	FROM wsl_claim_attachment WHERE FILENAME IS NOT NULL
	) AS SUPPORTING_INFO')
END
ELSE
	EXECUTE('CREATE   VIEW NPHIES_CLAIMSUPPORTINGINFO(PROVCLAIMNO,  CATEGORY,SEQUENCENO, REASON,
		SUPPORTINGVALUE, SUPPORTINGATTACHMENT, ATTACHMENTFILENAME, ATTACHMENTTYPE, CODE,
		TIMINGPERIODFROM, TIMINGPERIODTO,UNIT) AS 
	SELECT PROVCLAIMNO AS PROVCLAIMNO , Support_Type, ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS SEQUENCENO,NULL,SUPPORTINGVALUE, FILECONTENT, FILENAME,
	NULL AS NotNeeded_4,CODE,TIMINGPERIODFROM, TIMINGPERIODTO , NULL AS UNIT
	FROM
	(SELECT PROVCLAIMNO AS PROVCLAIMNO, ''temperature'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),TEMPERATURE) AS SUPPORTINGVALUE, NULL AS FILECONTENT
	, NULL FILENAME, NULL AS NotNeeded_4, ''Cel'' As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO, NULL AS UNIT
	FROM WSL_GENINFO WHERE TEMPERATURE IS NOT NULL
	UNION ALL 
	SELECT PROVCLAIMNO AS PROVCLAIMNO, ''chief-complaint'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, MAINSYMPTOM AS SUPPORTINGVALUE, NULL AS FILECONTENT, NULL FILENAME
	, NULL AS NotNeeded_4, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO, NULL AS UNIT
	FROM WSL_GENINFO WHERE MAINSYMPTOM IS NOT NULL
    UNION ALL
    SELECT PROVCLAIMNO AS PROVCLAIMNO, ''vital-sign-weight'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),WEIGH) AS SUPPORTINGVALUE, NULL AS FILECONTENT
	, NULL FILENAME, NULL AS NotNeeded_4, ''kg'' As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO , NULL AS UNIT
	FROM WSL_GENINFO WHERE WEIGH IS NOT NULL
    UNION ALL
    SELECT PROVCLAIMNO AS PROVCLAIMNO, ''hospitalized'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4, NULL AS CODE
	, NULL, ADMISSIONDATE AS TIMINGPERIODFROM, DISCHARGEDATE AS TIMINGPERIODTO, NULL AS UNIT
	FROM WSL_GENINFO WHERE ADMISSIONDATE IS NOT NULL AND DISCHARGEDATE IS NOT NULL
    UNION ALL
    SELECT PROVCLAIMNO AS PROVCLAIMNO, ''pulse'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),PULSE) AS SUPPORTINGVALUE, NULL AS FILECONTENT
	, NULL FILENAME, NULL AS NotNeeded_4, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO, NULL AS UNIT
	FROM WSL_GENINFO WHERE PULSE IS NOT NULL
	UNION ALL
	SELECT PROVCLAIMNO AS PROVCLAIMNO, ''respiratory-rate'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),RESPIRATORYRATE) AS SUPPORTINGVALUE
	, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO, NULL AS UNIT
	FROM WSL_GENINFO WHERE RESPIRATORYRATE IS NOT NULL
	UNION ALL
	SELECT PROVCLAIMNO AS PROVCLAIMNO, ''vital-sign-systolic'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),BLOODPRESSURE) AS SUPPORTINGVALUE
	, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4L, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO, NULL AS UNIT
	FROM WSL_GENINFO WHERE BLOODPRESSURE IS NOT NULL
	UNION ALL
	SELECT PROVCLAIMNO AS PROVCLAIMNO, ''vital-sign-diastolic'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),BLOODPRESSURE) AS SUPPORTINGVALUE
	, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO, NULL AS UNIT
	FROM WSL_GENINFO WHERE BLOODPRESSURE IS NOT NULL 
	UNION ALL 
	SELECT PROVCLAIMNO AS PROVCLAIMNO, ''last-menstrual-period'', NULL AS SEQUENCENO,  NULL, NULL, NULL, NULL, NULL, NULL, LASTMENSTRUATIONPERIOD AS TIMINGPERIODFROM, NULL
	FROM WSL_GENINFO WHERE LASTMENSTRUATIONPERIOD IS NOT NULL
	UNION ALL
	SELECT PROVCLAIMNO AS PROVCLAIMNO, ''info'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, CONVERT(NVARCHAR(max),RADIOREPORT) AS SUPPORTINGVALUE
	, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4L, NULL As CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO, NULL AS UNIT
	FROM WSL_GENINFO WHERE RADIOREPORT IS NOT NULL  AND CONVERT(VARCHAR,RADIOREPORT) !=''''
	UNION ALL
	SELECT labResult.PROVCLAIMNO AS PROVCLAIMNO, ''lab-test'' As Support_Type, NULL AS SEQUENCENO,NULL As NotNeeded_1, 
		(''LABCODE: '' + ISNULL(labComponent.LABCOMPCODE,'''') +'' ,LABDESC: '' + ISNULL(labComponent.LABCOMPDESC,'''')  + '' ,LABRESULT: '' + ISNULL(labComponent.LABRESULT,'''') + '' ,LABRESULTUNIT: '' 
		+ ISNULL(labComponent.LABRESULTUNIT,'''') + '' ,LABRESULTCOMMENT: '' + ISNULL(labComponent.LABRESULTCOMMENT,'''')) AS SUPPORTINGVALUE, NULL AS FILECONTENT, NULL FILENAME, NULL AS NotNeeded_4
		, labResult.LABTESTCODE AS CODE, NULL AS TIMINGPERIODFROM, NULL AS TIMINGPERIODTO, NULL AS UNIT
	FROM WSL_LAB_RESULT labResult LEFT JOIN WSL_LAB_COMPONENT labComponent ON labResult.LABTESTCODE=labComponent.LABTESTCODE and labResult.SERIAL=labComponent.SERIAL and labResult.PROVCLAIMNO=labComponent.PROVCLAIMNO
	) AS SUPPORTING_INFO')
	GO
GO  