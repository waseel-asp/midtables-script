/*
Created		11/18/2021
Modified	11/18/2021
Project		Waseel
Model		
Company		
Author		Sahil
Version		0.1
Database	SQL Server
*/

-- Create Tables section

Create table [nphies_beneficiary]
(
	[BENEFICIARYID] Varchar(20) NOT NULL,
	[PATIENTFILENO] Varchar(30) NOT NULL,
	[FIRSTNAME] Varchar(50) NULL,
	[MIDDLENAME] Varchar(50) NULL,
	[LASTNAME] Varchar(50) NULL,
	[FULLNAME] Varchar(200) NULL,
	[DOB] Datetime NOT NULL,
	[GENDER] Varchar(10) NOT NULL,
	[NATIONALITY] Varchar(30) NULL,
	[DOCUMENTTYPE] Varchar(30) NOT NULL,
	[DOCUMENTID] Varchar(50) NOT NULL,
	[CONTACTNUMBER] Varchar(50) NULL,
	[EHEALTHID] Varchar(50) NULL,
	[RESIDENCYTYPE] Varchar(50) NULL,
	[MARITALSTATUS] Varchar(10) NULL,
	[BLOODGROUP] Varchar(10) NULL,
	[PREFERREDLANGUAGE] Varchar(20) NULL,
	[EMAIL] Varchar(50) NULL,
	[ADDRESSLINE] Varchar(250) NULL,
	[ADDRESSSTREETNAME] Varchar(250) NULL,
	[ADDRESSCITY] Varchar(250) NULL,
	[ADDRESSDISTRICT] Varchar(250) NULL,
	[ADDRESSSTATE] Varchar(250) NULL,
	[ADDRESSPOSTALCODE] Varchar(100) NULL,
	[ADDRESSCOUNTRY] Varchar(250) NULL,
	Constraint [PK_BENEFICIARY] Primary Key ([BENEFICIARYID])
) 
go

Create table [nphies_coverage]
(
	[COVERAGEID] Varchar(20) NOT NULL,
	[MEMBERID] Varchar(50) NOT NULL,
	[EXPIRYDATE] Datetime NULL,
	[PAYERNPHIESID] Varchar(20) NOT NULL,
	[TPANPHIESID] Varchar(20) NULL,
	[RELATIONWITHSUBSCRIBER] Varchar(20) NOT NULL,
	[POLICYHOLDER] Varchar(250) NULL,
	[POLICYNUMBER] Varchar(30) NULL,
	[COVERAGETYPE] Varchar(20) NOT NULL,
	[BENEFICIARYID] Varchar(20) NOT NULL,
	Constraint [PK_COVERAGE] Primary Key ([COVERAGEID])
) 
go

Alter table [nphies_coverage] add Constraint [FK_BENEFICIARY_COVERAGE] foreign key([BENEFICIARYID]) references [nphies_beneficiary] ([BENEFICIARYID])
go

ALTER table [nphies_claiminfo]
(
	[PROVCLAIMNO] Varchar(40) NOT NULL,
	[EPISODEID] Varchar(40) NOT NULL,
	[ISNEWBORN] Varchar(10) NULL,
    [ISREFERRAL] Varchar(10) NULL,
    [REFERRINGPROVIDERNAME] Varchar(200) NULL,
	[CLAIMTYPE] Varchar(20) NOT NULL,
	[CLAIMSUBTYPE] Varchar(20) NOT NULL,
	[PROVIDERNPHIESID] Varchar(20) NOT NULL,
	[CLAIMCREATEDDATE] Datetime NOT NULL,
	[ACCOUNTINGPERIOD] Datetime NOT NULL,
	[BILLABLEPERIODSTART] Datetime NULL,
	[BILLABLEPERIODEND] Datetime NULL,
	[ELIGIBILITYRESPONSEID] Varchar(30) NULL,
	[ELIGIBILITYIDENTIFIERURL] Varchar(250) NULL,
	[ELIGIBILITYOFFLINEID] Varchar(30) NULL,
	[ELIGIBILITYOFFLINEDATE] Datetime NULL,
	[PREAUTHOFFLINEDATE] Datetime NULL,
	[PREAUTHRESPONSEID] Varchar(30) NULL,
	[PREAUTHIDENTIFIERURL] Varchar(250) NULL,
	[PAYEETYPE] Varchar(10) NULL,
	[PAYEEID] Varchar(20) NULL,
	[COVERAGEID] Varchar(20) NOT NULL,
	[BENEFICIARYID] Varchar(20) NOT NULL,
	[SUBSCRIBERID] Varchar(20) NULL,
	[TOTAL] Decimal(14,2) NOT NULL,
	[PRESCRIPTION] Varchar(250) NULL,
	Constraint [PK_CLAIMINFO] Primary Key ([PROVCLAIMNO])
) 
go

Alter table [nphies_claiminfo] add Constraint [FK_BENEFICIARY_CLAIMINFO] foreign key([BENEFICIARYID]) references [nphies_beneficiary] ([BENEFICIARYID])
go
Alter table [nphies_claiminfo] add Constraint [FK_BENEFI_SUBSCRIB_CLAIMINFO] foreign key([SUBSCRIBERID]) references [nphies_beneficiary] ([BENEFICIARYID])
go
Alter table [nphies_claiminfo] add Constraint [FK_COVERAGE_CLAIMINFO] foreign key([COVERAGEID]) references [nphies_coverage] ([COVERAGEID])
go

Create table [nphies_claimpreauthdetails]
(
	[PROVCLAIMNO] Varchar(40) NOT NULL,
	[PREAUTHREFNO] Varchar(20) NOT NULL,
	Constraint [PK_CLAIMPREAUTHDETAILS] Primary Key ([PROVCLAIMNO],[PREAUTHREFNO])
)
go

Alter table [nphies_claimpreauthdetails] add Constraint [FK_CLAIMPREAUTH] foreign key([PROVCLAIMNO]) references [nphies_claiminfo] ([PROVCLAIMNO])
go

Create table [nphies_claimdiagnosis]
(
	[PROVCLAIMNO] Varchar(40) NOT NULL,
	[SEQUENCENO] Integer NOT NULL,
	[DIAGNOSISCODE] Varchar(30) NOT NULL,
	[DIAGNOSISDESC] Varchar(256) NULL,
	[DIAGNOSISTYPE] Varchar(30) NULL,
	[ONADMISSION] Varchar(10) NULL,
	Constraint [PK_CLAIMDIAGNOSIS] Primary Key ([PROVCLAIMNO],[SEQUENCENO])
)
go

Alter table [nphies_claimdiagnosis] add Constraint [FK_CLAIMDIAGNOSIS] foreign key([PROVCLAIMNO]) references [nphies_claiminfo] ([PROVCLAIMNO])
go

Create table [nphies_claimcareteam]
(
	[PROVCLAIMNO] Varchar(40) NOT NULL,
	[SEQUENCENO] Integer NOT NULL,
	[PHYSICIANID] Varchar(30) NOT NULL,
	[PHYSICIANNAME] Varchar(60) NULL,
	[PRACTITIONERROLE] Varchar(20) NULL,
	[CARETEAMROLE] Varchar(20) NOT NULL,
	[CARETEAMQUALIFICATION] Varchar(30) NOT NULL,
	Constraint [PK_CLAIMCARETEAM] Primary Key ([PROVCLAIMNO],[SEQUENCENO])
)
go

Alter table [nphies_claimcareteam] add Constraint [FK_CLAIMCARETEAM] foreign key([PROVCLAIMNO]) references [nphies_claiminfo] ([PROVCLAIMNO])
go

Create table [nphies_claimitem]
(
	[PROVCLAIMNO] Varchar(40) NOT NULL,
	[INVOICENO] Varchar(30) NOT NULL,
	[SEQUENCENO] Integer NOT NULL,
	[SERVICETYPE] Varchar(30) NOT NULL,
	[SERVICECODE] Varchar(30) NOT NULL,
	[SERVICEDESC] Varchar(256) NOT NULL,
	[NONSTANDARDCODE] Varchar(30) NULL,
	[NONSTANDARDDESC] Varchar(256) NULL,
	[UDI] Varchar(30) NULL,
	[ISPACKAGE] Varchar(5) NOT NULL,
	[QUANTITY] Decimal(10,2) NOT NULL,
	[QUANTITYCODE] VARCHAR(10) NULL,
	[UNITPRICE] Decimal(14,2) NOT NULL,
	[DISCOUNT] Decimal(14,2) NULL,
	[FACTOR] Decimal(14,6) NOT NULL,
	[PATIENTSHARE] Decimal(14,2) NOT NULL,
	[PAYERSHARE] Decimal(14,2) NOT NULL,
	[TAX] Decimal(14,2) NOT NULL,
	[NET] Decimal(14,2) NOT NULL,
	[STARTDATE] Datetime NULL,
	[ENDDATE] Datetime NOT NULL,
	[BODYSITECODE] Varchar(10) NULL,
	[SUBSITECODE] Varchar(10) NULL,
	[DRUGSELECTIONREASON] Varchar(30) NULL,
	[PRESCRIBEDDRUGCODE] Varchar(50) NULL,
	[PHARMACISTSELECTIONREASON] Varchar(50) NULL,
	[PHARMACISTSUBSTITUTE] Varchar(50) NULL,
	[REASONPHARMACISTSUBSTITUTE] Varchar(50) NULL,
	Constraint [PK_CLAIMITEM] Primary Key ([PROVCLAIMNO],[SEQUENCENO])
)
go

Alter table [nphies_claimitem] add Constraint [FK_CLAIMITEM] foreign key([PROVCLAIMNO]) references [nphies_claiminfo] ([PROVCLAIMNO])
go

Create table [nphies_claimsupportinginfo]
(
	[PROVCLAIMNO] Varchar(40) NOT NULL,
	[SEQUENCENO] Integer NOT NULL,
	[CATEGORY] Varchar(20) NOT NULL,
	[REASON] Varchar(20) NULL,
	[SUPPORTINGVALUE] Text NULL,
	[SUPPORTINGATTACHMENT] varbinary(max) NULL,
	[ATTACHMENTFILENAME] Varchar(30) NULL,
	[ATTACHMENTTYPE] Varchar(20) NULL,
	[CODE] Varchar(30) NULL,
	[TIMINGPERIODFROM] Datetime NULL,
	[TIMINGPERIODTO] Datetime NULL,
	Constraint [PK_CLAIMSUPPORTINGINFO] Primary Key ([PROVCLAIMNO],[SEQUENCENO])
)
go

Alter table [nphies_claimsupportinginfo] add Constraint [FK_CLAIMSUPPORTINGINFO] foreign key([PROVCLAIMNO]) references [nphies_claiminfo] ([PROVCLAIMNO])
go

Create table [nphies_claimaccidentdetail]
(
	[PROVCLAIMNO] Varchar(40) NOT NULL,
	[ACCIDENTTYPE] Varchar(20) NOT NULL,
	[ACCIDENTDATE] Datetime NOT NULL,
	[ADDRESSSTREETNAME] Varchar(250) NULL,
	[ADDRESSCITY] Varchar(250) NULL,
	[ADDRESSSTATE] Varchar(250) NULL,
	[ADDRESSCOUNTRY] Varchar(250) NULL,
	Constraint [PK_CLAIMACCIDENTDETAIL] Primary Key ([PROVCLAIMNO])
)
go

Alter table [nphies_claimaccidentdetail] add Constraint [FK_CLAIMACCIDENTDETAIL] foreign key([PROVCLAIMNO]) references [nphies_claiminfo] ([PROVCLAIMNO])
go

Create table [nphies_claimvisionprescription]
(
	[PROVCLAIMNO] Varchar(40) NOT NULL,
	[VISIONPRESCRIPTIONID] Varchar(20) NOT NULL,
	[DATEWRITTEN] Datetime NOT NULL,
	[CARETEAMSEQUENCE] Integer NOT NULL,
	[PRODUCT] Varchar(10) NOT NULL,
	[EYE] Varchar(10) NOT NULL,
	[SPHERE] Decimal(14,2) NULL,
	[CYLINDER] Decimal(14,2) NULL,
	[AXIS] Integer NULL,
	[PRISMAMOUNT] Decimal(14,2) NULL,
	[PRISMBASE] Varchar(10) NULL,
	[MULTIFOCALPOWER] Decimal(14,2) NULL,
	[LENSPOWER] Decimal(14,2) NULL,
	[LENSBACKCURVE] Decimal(14,2) NULL,
	[LENSDIAMETER] Decimal(14,2) NULL,
	[LENSDURATION] Integer NULL,
	[LENSCOLOR] Varchar(10) NULL,
	[LENSBRAND] Varchar(50) NULL,
	[LENSNOTE] Varchar(256) NULL,
	[LENSDURATIONUNIT] Varchar(10) NULL,
	Constraint [PK_CLAIMVISIONPRESCRIPTION] Primary Key ([PROVCLAIMNO],[VISIONPRESCRIPTIONID])
)
go

Alter table [nphies_claimvisionprescription] add Constraint [FK_CLAIMVISIONPRESCRIPTION] foreign key([PROVCLAIMNO]) references [nphies_claiminfo] ([PROVCLAIMNO])
go
Alter table [nphies_claimvisionprescription] add Constraint [FK_CARETEAMVISION] foreign key([PROVCLAIMNO],[CARETEAMSEQUENCE]) references [nphies_claimcareteam] ([PROVCLAIMNO],[SEQUENCENO])
go

Create table [nphies_itemdiagnosis]
(
	[PROVCLAIMNO] Varchar(40) NOT NULL,
	[DIAGNOSISSEQUENCENO] Integer NOT NULL,
	[ITEMSEQUENCENO] Integer NOT NULL,
	Constraint [PK_ITEMDIAGNOSIS] Primary Key ([PROVCLAIMNO],[DIAGNOSISSEQUENCENO],[ITEMSEQUENCENO])
)
go

Alter table [nphies_itemdiagnosis] add Constraint [FK_ITEMDIAGNOSIS] foreign key([PROVCLAIMNO]) references [nphies_claiminfo] ([PROVCLAIMNO])
go
Alter table [nphies_itemdiagnosis] add Constraint [FK_DIAGNOSISSEQ] foreign key([PROVCLAIMNO],[DIAGNOSISSEQUENCENO]) references [nphies_claimdiagnosis] ([PROVCLAIMNO],[SEQUENCENO])
go
Alter table [nphies_itemdiagnosis] add Constraint [FK_ITEMDIASEQ] foreign key([PROVCLAIMNO],[ITEMSEQUENCENO]) references [nphies_claimitem] ([PROVCLAIMNO],[SEQUENCENO])
go

Create table [nphies_itemcareteam]
(
	[PROVCLAIMNO] Varchar(40) NOT NULL,
	[CARETEAMSEQUENCENO] Integer NOT NULL,
	[ITEMSEQUENCENO] Integer NOT NULL,
	Constraint [PK_ITEMCARETEAM] Primary Key ([PROVCLAIMNO],[CARETEAMSEQUENCENO],[ITEMSEQUENCENO])
)
go

Alter table [nphies_itemcareteam] add Constraint [FK_ITEMCARETEAM] foreign key([PROVCLAIMNO]) references [nphies_claiminfo] ([PROVCLAIMNO])
go
Alter table [nphies_itemcareteam] add Constraint [FK_CARETEAMSEQ] foreign key([PROVCLAIMNO],[CARETEAMSEQUENCENO]) references [nphies_claimcareteam] ([PROVCLAIMNO],[SEQUENCENO])
go
Alter table [nphies_itemcareteam] add Constraint [FK_ITEMCARESEQ] foreign key([PROVCLAIMNO],[ITEMSEQUENCENO]) references [nphies_claimitem] ([PROVCLAIMNO],[SEQUENCENO])
go

Create table [nphies_itemsupportinginfo]
(
	[PROVCLAIMNO] Varchar(40) NOT NULL,
	[SUPPORTINGINFOSEQUENCENO] Integer NOT NULL,
	[ITEMSEQUENCENO] Integer NOT NULL,
	Constraint [PK_ITEMSUPPORTINGINFO] Primary Key ([PROVCLAIMNO],[SUPPORTINGINFOSEQUENCENO],[ITEMSEQUENCENO])
)
go

Alter table [nphies_itemsupportinginfo] add Constraint [FK_ITEMSUPPORTINGINFO] foreign key([PROVCLAIMNO]) references [nphies_claiminfo] ([PROVCLAIMNO])
go
Alter table [nphies_itemsupportinginfo] add Constraint [FK_SUPPORTINGINFOSEQ] foreign key([PROVCLAIMNO],[SUPPORTINGINFOSEQUENCENO]) references [nphies_claimsupportinginfo] ([PROVCLAIMNO],[SEQUENCENO])
go
Alter table [nphies_itemsupportinginfo] add Constraint [FK_ITEMSUPPORTINGSEQ] foreign key([PROVCLAIMNO], [ITEMSEQUENCENO]) references [nphies_claimitem] ([PROVCLAIMNO],[SEQUENCENO])
go

Create table [nphies_claimitemdetails]
(
	[ITEMSEQUENCENO] Integer NOT NULL,
	[PROVCLAIMNO] Varchar(40) NOT NULL,
	[SEQUENCENO] Integer NOT NULL,
	[SERVICETYPE] Varchar(30) NOT NULL,
	[SERVICECODE] Varchar(30) NOT NULL,
	[SERVICEDESC] Varchar(256) NOT NULL,
	[NONSTANDARDCODE] Varchar(30) NULL,
	[NONSTANDARDDESC] Varchar(256) NULL,
	[UDI] Varchar(30) NULL,
	[QUANTITY] Decimal(10,0) NOT NULL,
	[QUANTITYCODE] VARCHAR(10) NULL,
	[UNITPRICE] Decimal(14,2) NULL,
	[TAX] Decimal(14,2) NULL,
	[NET] Decimal(14,2) NULL,
	[PRESCRIBEDDRUGCODE] Varchar(50) NULL,
	[PHARMACISTSELECTIONREASON] Varchar(50) NULL,
	[PHARMACISTSUBSTITUTE] Varchar(50) NULL,
	[REASONPHARMACISTSUBSTITUTE] Varchar(50) NULL,
	Constraint [PK_CLAIMITEMDETAILS] Primary Key ([PROVCLAIMNO],[SEQUENCENO])
)
go

Alter table [nphies_claimitemdetails] add Constraint [FK_ITEMDETAILSSEQ] foreign key([PROVCLAIMNO],[ITEMSEQUENCENO]) references [nphies_claimitem] ([PROVCLAIMNO],[SEQUENCENO])
go

Create table [nphies_claimencounters]
(
	[PROVCLAIMNO] Varchar(40) NOT NULL,
	[ENCOUNTERID] Varchar(20) NOT NULL,
	[ENCOUNTERSTARTDATE] Datetime NOT NULL,
	[ENCOUNTERENDDATE] Datetime NOT NULL,
	[ENCOUNTERCLASS] Varchar(20) NULL,
	[ENCOUNTERSERVICETYPE] Varchar(20) NULL,
	[PRIORITY] Varchar(20) NULL,
	[HOSPITALIZATIONORIGIN] Varchar(20) NULL,
	[HOSPITALADMISSIONSOURCE] Varchar(20) NULL,
	[HOSPITALREADMISSION] Varchar(20) NULL,
	[HOSPITALDISCHARGEDISPOSITION] Varchar(20) NULL,
	[SERVICEPROVIDER] Varchar(20) NULL,
	[ENCOUNTERSTATUS] Varchar(20) NOT NULL,
	Constraint [PK_CLAIMENCOUNTERS] Primary Key ([PROVCLAIMNO],[ENCOUNTERID])
)
go

Alter table [nphies_claimencounters] add Constraint [FK_CLAIMENCOUNTERS] foreign key([PROVCLAIMNO]) references [nphies_claiminfo] ([PROVCLAIMNO])
go