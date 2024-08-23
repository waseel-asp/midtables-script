

CREATE TABLE NPHIES_BENEFICIARY (
	BENEFICIARYID varchar(20) NOT NULL,
	PATIENTFILENO varchar(30) NOT NULL,
	FIRSTNAME varchar(50) NULL,
	MIDDLENAME varchar(50) NULL,
	LASTNAME varchar(50) NULL,
	FULLNAME varchar(200) NULL,
	DOB Datetime NOT NULL,
	GENDER varchar(10) NOT NULL,
	NATIONALITY varchar(30) NULL,
	DOCUMENTTYPE varchar(30) NOT NULL,
	DOCUMENTID varchar(50) NOT NULL,
	CONTACTNUMBER varchar(50) NULL,
	EHEALTHID varchar(50) NULL,
	RESIDENCYTYPE varchar(50) NULL,
	MARITALSTATUS varchar(10) NOT NULL,
	BLOODGROUP varchar(10) NULL,
	PREFERREDLANGUAGE varchar(20) NULL,
	EMAIL varchar(50) NULL,
	ADDRESSLINE varchar(250) NULL,
	ADDRESSSTREETNAME varchar(250) NULL,
	ADDRESSCITY varchar(250) NULL,
	ADDRESSDISTRICT varchar(250) NULL,
	ADDRESSSTATE varchar(250) NULL,
	ADDRESSPOSTALCODE varchar(100) NULL,
	ADDRESSCOUNTRY varchar(250) NULL,
	OCCUPATION varchar(20) NOT NULL,
    RELIGION varchar(5) NULL,
	Constraint PK_BENEFICIARY Primary Key (BENEFICIARYID)
);

CREATE TABLE NPHIES_COVERAGE (
	COVERAGEID varchar(20) NOT NULL,
	MEMBERID varchar(50) NOT NULL,
	EXPIRYDATE Datetime NULL,
	PAYERNPHIESID varchar(20) NOT NULL,
	TPANPHIESID varchar(20) NULL,
	RELATIONWITHSUBSCRIBER varchar(20) NOT NULL,
	POLICYHOLDER varchar(250) NOT NULL,
	POLICYNUMBER varchar(30) NULL,
	COVERAGETYPE varchar(20) NOT NULL,
	BENEFICIARYID varchar(20) NOT NULL,
	Constraint PK_COVERAGE Primary Key (COVERAGEID)
);

Create table NPHIES_COVERAGE_CLASS (
	COVERAGECLASSID varchar(20) NOT NULL,
	TYPE varchar(50) NOT NULL,
	VALUE varchar(250) NOT NULL,
	NAME varchar(250),
	COVERAGEID varchar(20) NOT NULL,
 Constraint PK_COVERAGE_CLASS primary key (COVERAGECLASSID)
);

Alter table NPHIES_COVERAGE_CLASS add Constraint FK_BENEFICIARY_COVERAGE_CLASS foreign key (COVERAGEID) references NPHIES_COVERAGE (COVERAGEID);


CREATE TABLE NPHIES_CLAIMINFO (
	PROVCLAIMNO varchar(40) NOT NULL,
	EPISODEID varchar(40) NOT NULL,
	ISNEWBORN varchar(10) NULL,
    ISREFERRAL varchar(10) NULL,
    REFERRINGPROVIDERNAME varchar(200) NULL,
	CLAIMTYPE varchar(20) NOT NULL,
	CLAIMSUBTYPE varchar(20) NOT NULL,
	PROVIDERNPHIESID varchar(20) NOT NULL,
	CLAIMCREATEDDATE Datetime NOT NULL,
	ACCOUNTINGPERIOD Datetime NOT NULL,
	BILLABLEPERIODSTART Datetime NULL,
	BILLABLEPERIODEND Datetime NULL,
	ELIGIBILITYRESPONSEID varchar(30) NULL,
	ELIGIBILITYIDENTIFIERURL varchar(250) NULL,
	ELIGIBILITYOFFLINEID varchar(30) NULL,
	ELIGIBILITYOFFLINEDATE Datetime NULL,
	PREAUTHOFFLINEDATE Datetime NULL,
	PREAUTHRESPONSEID varchar(30) NULL,
	PREAUTHIDENTIFIERURL varchar(250) NULL,
	PAYEETYPE varchar(10) NULL,
	PAYEEID varchar(20) NULL,
	COVERAGEID varchar(20) NOT NULL,
	BENEFICIARYID varchar(20) NOT NULL,
	SUBSCRIBERID varchar(20) NULL,
	TOTAL Decimal(14,2) NOT NULL,
	PRESCRIPTION Varchar(250) NULL,
	Constraint PK_CLAIMINFO Primary Key (PROVCLAIMNO)
);

Alter table NPHIES_CLAIMINFO add Constraint FK_BENEFICIARY_CLAIMINFO foreign key(BENEFICIARYID) references NPHIES_BENEFICIARY (BENEFICIARYID);
Alter table NPHIES_CLAIMINFO add Constraint FK_BENEFI_SUBSCRIB_CLAIMINFO foreign key(SUBSCRIBERID) references NPHIES_BENEFICIARY (BENEFICIARYID);
Alter table NPHIES_CLAIMINFO add Constraint FK_COVERAGE_CLAIMINFO foreign key(COVERAGEID) references NPHIES_COVERAGE (COVERAGEID);

CREATE TABLE NPHIES_CLAIMPREAUTHDETAILS
(
	PROVCLAIMNO varchar(40) NOT NULL,
	PREAUTHREFNO varchar(20) NOT NULL,
	Constraint PK_CLAIMPREAUTHDETAILS Primary Key (PROVCLAIMNO,PREAUTHREFNO)
);

Alter table NPHIES_CLAIMPREAUTHDETAILS add Constraint FK_CLAIMPREAUTH foreign key(PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);

CREATE TABLE NPHIES_CLAIMDIAGNOSIS
(
	PROVCLAIMNO varchar(40) NOT NULL,
	SEQUENCENO Integer NOT NULL,
	DIAGNOSISCODE varchar(30) NOT NULL,
	DIAGNOSISDESC varchar(256) NULL,
	DIAGNOSISTYPE varchar(30) NULL,
	ONADMISSION varchar(10) NULL,
	CONDITIONONSET varchar(10) NULL,
	Constraint PK_CLAIMDIAGNOSIS Primary Key (PROVCLAIMNO,SEQUENCENO)
);

Alter table NPHIES_CLAIMDIAGNOSIS add Constraint FK_CLAIMDIAGNOSIS foreign key(PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);

CREATE TABLE NPHIES_CLAIMCARETEAM
(
	PROVCLAIMNO varchar(40) NOT NULL,
	SEQUENCENO Integer NOT NULL,
	PHYSICIANID varchar(30) NOT NULL,
	PHYSICIANNAME varchar(60) NULL,
	PRACTITIONERROLE varchar(20) NULL,
	CARETEAMROLE varchar(20) NOT NULL,
	CARETEAMQUALIFICATION varchar(30) NOT NULL,
	Constraint PK_CLAIMCARETEAM Primary Key (PROVCLAIMNO,SEQUENCENO)
);

Alter table NPHIES_CLAIMCARETEAM add Constraint FK_CLAIMCARETEAM foreign key(PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);

CREATE TABLE NPHIES_CLAIMITEM
(
	PROVCLAIMNO varchar(40) NOT NULL,
	INVOICENO varchar(30) NOT NULL,
	SEQUENCENO Integer NOT NULL,
	SERVICETYPE varchar(30) NOT NULL,
	SERVICECODE varchar(30) NOT NULL,
	SERVICEDESC varchar(256) NOT NULL,
	NONSTANDARDCODE varchar(30) NULL,
	NONSTANDARDDESC varchar(256) NULL,
	UDI varchar(30) NULL,
	ISPACKAGE varchar(5) NOT NULL,
	QUANTITY Decimal(10,2) NOT NULL,
	QUANTITYCODE varchar(10) NULL,
	UNITPRICE Decimal(14,2) NOT NULL,
	DISCOUNT Decimal(14,2) NULL,
	FACTOR Decimal(14,6) NOT NULL,
	PATIENTSHARE Decimal(14,2) NOT NULL,
	PAYERSHARE Decimal(14,2) NOT NULL,
	TAX Decimal(14,2) NOT NULL,
	NET Decimal(14,2) NOT NULL,
	STARTDATE Datetime NULL,
	ENDDATE Datetime NOT NULL,
	BODYSITECODE varchar(10) NULL,
	SUBSITECODE varchar(10) NULL,
	DRUGSELECTIONREASON varchar(30) NULL,
	PRESCRIBEDDRUGCODE varchar(50) NULL,
	PHARMACISTSELECTIONREASON varchar(50) NULL,
	PHARMACISTSUBSTITUTE varchar(50) NULL,
	REASONPHARMACISTSUBSTITUTE varchar(50) NULL,
	ISMATERNITY varchar(10) DEFAULT NULL,
	Constraint PK_CLAIMITEM Primary Key (PROVCLAIMNO,SEQUENCENO)
);

Alter table NPHIES_CLAIMITEM add Constraint FK_CLAIMITEM foreign key(PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);

CREATE TABLE NPHIES_CLAIMSUPPORTINGINFO
(
	PROVCLAIMNO varchar(40) NOT NULL,
	SEQUENCENO Integer NOT NULL,
	CATEGORY varchar(20) NOT NULL,
	REASON varchar(20) NULL,
	SUPPORTINGVALUE Text NULL,
	SUPPORTINGATTACHMENT BLOB NULL,
	ATTACHMENTFILENAME varchar(30) NULL,
	ATTACHMENTTYPE varchar(20) NULL,
	CODE varchar(30) NULL,
	UNIT varchar(30) NULL,
	TIMINGPERIODFROM Datetime NULL,
	TIMINGPERIODTO Datetime NULL,
	Constraint PK_CLAIMSUPPORTINGINFO Primary Key (PROVCLAIMNO,SEQUENCENO)
);

Alter table NPHIES_CLAIMSUPPORTINGINFO add Constraint FK_CLAIMSUPPORTINGINFO foreign key(PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);

CREATE TABLE NPHIES_CLAIMACCIDENTDETAIL
(
	PROVCLAIMNO varchar(40) NOT NULL,
	ACCIDENTTYPE varchar(20) NOT NULL,
	ACCIDENTDATE Datetime NOT NULL,
	ADDRESSSTREETNAME varchar(250) NULL,
	ADDRESSCITY varchar(250) NULL,
	ADDRESSSTATE varchar(250) NULL,
	ADDRESSCOUNTRY varchar(250) NULL,
	Constraint PK_CLAIMACCIDENTDETAIL Primary Key (PROVCLAIMNO)
);

Alter table NPHIES_CLAIMACCIDENTDETAIL add Constraint FK_CLAIMACCIDENTDETAIL foreign key(PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);

CREATE TABLE NPHIES_CLAIMVISIONPRESCRIPTION
(
	PROVCLAIMNO varchar(40) NOT NULL,
	VISIONPRESCRIPTIONID varchar(20) NOT NULL,
	DATEWRITTEN Datetime NOT NULL,
	CARETEAMSEQUENCE Integer NOT NULL,
	PRODUCT varchar(10) NOT NULL,
	EYE varchar(10) NOT NULL,
	SPHERE Decimal(14,2) NULL,
	CYLINDER Decimal(14,2) NULL,
	AXIS Integer NULL,
	PRISMAMOUNT Decimal(14,2) NULL,
	PRISMBASE varchar(10) NULL,
	MULTIFOCALPOWER Decimal(14,2) NULL,
	LENSPOWER Decimal(14,2) NULL,
	LENSBACKCURVE Decimal(14,2) NULL,
	LENSDIAMETER Decimal(14,2) NULL,
	LENSDURATION Integer NULL,
	LENSCOLOR varchar(10) NULL,
	LENSBRAND varchar(50) NULL,
	LENSNOTE varchar(256) NULL,
	LENSDURATIONUNIT varchar(10) NULL,
	Constraint PK_CLAIMVISIONPRESCRIPTION Primary Key (PROVCLAIMNO,VISIONPRESCRIPTIONID)
);

Alter table NPHIES_CLAIMVISIONPRESCRIPTION add Constraint FK_CLAIMVISIONPRESCRIPTION foreign key(PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);
Alter table NPHIES_CLAIMVISIONPRESCRIPTION add Constraint FK_CARETEAMVISION foreign key(PROVCLAIMNO,CARETEAMSEQUENCE) references NPHIES_CLAIMCARETEAM (PROVCLAIMNO,SEQUENCENO);

CREATE TABLE NPHIES_ITEMDIAGNOSIS
(
	PROVCLAIMNO varchar(40) NOT NULL,
	DIAGNOSISSEQUENCENO Integer NOT NULL,
	ITEMSEQUENCENO Integer NOT NULL,
	Constraint PK_ITEMDIAGNOSIS Primary Key (PROVCLAIMNO,DIAGNOSISSEQUENCENO,ITEMSEQUENCENO)
);

Alter table NPHIES_ITEMDIAGNOSIS add Constraint FK_ITEMDIAGNOSIS foreign key(PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);
Alter table NPHIES_ITEMDIAGNOSIS add Constraint FK_DIAGNOSISSEQ foreign key(PROVCLAIMNO,DIAGNOSISSEQUENCENO) references NPHIES_CLAIMDIAGNOSIS (PROVCLAIMNO,SEQUENCENO);
Alter table NPHIES_ITEMDIAGNOSIS add Constraint FK_ITEMDIASEQ foreign key(PROVCLAIMNO,ITEMSEQUENCENO) references NPHIES_CLAIMITEM (PROVCLAIMNO,SEQUENCENO);

CREATE TABLE NPHIES_ITEMCARETEAM
(
	PROVCLAIMNO varchar(40) NOT NULL,
	CARETEAMSEQUENCENO Integer NOT NULL,
	ITEMSEQUENCENO Integer NOT NULL,
	Constraint PK_ITEMCARETEAM Primary Key (PROVCLAIMNO,CARETEAMSEQUENCENO,ITEMSEQUENCENO)
);

Alter table NPHIES_ITEMCARETEAM add Constraint FK_ITEMCARETEAM foreign key(PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);
Alter table NPHIES_ITEMCARETEAM add Constraint FK_CARETEAMSEQ foreign key(PROVCLAIMNO,CARETEAMSEQUENCENO) references NPHIES_CLAIMCARETEAM (PROVCLAIMNO,SEQUENCENO);
Alter table NPHIES_ITEMCARETEAM add Constraint FK_ITEMCARESEQ foreign key(PROVCLAIMNO,ITEMSEQUENCENO) references NPHIES_CLAIMITEM (PROVCLAIMNO,SEQUENCENO);

CREATE TABLE NPHIES_ITEMSUPPORTINGINFO
(
	PROVCLAIMNO varchar(40) NOT NULL,
	SUPPORTINGINFOSEQUENCENO Integer NOT NULL,
	ITEMSEQUENCENO Integer NOT NULL,
	Constraint PK_ITEMSUPPORTINGINFO Primary Key (PROVCLAIMNO,SUPPORTINGINFOSEQUENCENO,ITEMSEQUENCENO)
);

Alter table NPHIES_ITEMSUPPORTINGINFO add Constraint FK_ITEMSUPPORTINGINFO foreign key(PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);
Alter table NPHIES_ITEMSUPPORTINGINFO add Constraint FK_SUPPORTINGINFOSEQ foreign key(PROVCLAIMNO,SUPPORTINGINFOSEQUENCENO) references NPHIES_CLAIMSUPPORTINGINFO (PROVCLAIMNO,SEQUENCENO);
Alter table NPHIES_ITEMSUPPORTINGINFO add Constraint FK_ITEMSUPPORTINGSEQ foreign key(PROVCLAIMNO, ITEMSEQUENCENO) references NPHIES_CLAIMITEM (PROVCLAIMNO,SEQUENCENO);

CREATE TABLE NPHIES_CLAIMITEMDETAILS
(
	ITEMSEQUENCENO Integer NOT NULL,
	PROVCLAIMNO varchar(40) NOT NULL,
	SEQUENCENO Integer NOT NULL,
	SERVICETYPE varchar(30) NOT NULL,
	SERVICECODE varchar(30) NOT NULL,
	SERVICEDESC varchar(256) NOT NULL,
	NONSTANDARDCODE varchar(30) NULL,
	NONSTANDARDDESC varchar(256) NULL,
	UDI varchar(30) NULL,
	QUANTITY Decimal(10,0) NOT NULL,
	QUANTITYCODE varchar(10) NULL,
	UNITPRICE Decimal(14,2) NULL,
	TAX Decimal(14,2) NULL,
	NET Decimal(14,2) NULL,
	PRESCRIBEDDRUGCODE Varchar(50) NULL,
	PHARMACISTSELECTIONREASON Varchar(50) NULL,
	PHARMACISTSUBSTITUTE Varchar(50) NULL,
	REASONPHARMACISTSUBSTITUTE Varchar(50) NULL,
	Constraint PK_CLAIMITEMDETAILS Primary Key (PROVCLAIMNO,SEQUENCENO)
);

Alter table NPHIES_CLAIMITEMDETAILS add Constraint FK_ITEMDETAILSSEQ foreign key(PROVCLAIMNO,ITEMSEQUENCENO) references NPHIES_CLAIMITEM (PROVCLAIMNO,SEQUENCENO);


Create table NPHIES_CLAIMENCOUNTERS (
	PROVCLAIMNO varchar(40) NOT NULL,
	ENCOUNTERID varchar(20) NOT NULL,
	ENCOUNTERSTARTDATE Datetime NOT NULL,
	ENCOUNTERENDDATE Datetime NOT NULL,
	ENCOUNTERCLASS varchar(20) NOT NULL,
	ENCOUNTERSERVICETYPE varchar(20) NULL,
	PRIORITY varchar(20) NULL,
	SERVICEPROVIDER varchar(20) NULL,
	ENCOUNTERSTATUS varchar(20) NOT NULL,
	CAUSEOFDEATH varchar(10) NULL,
    SERVICEEVENTTYPE varchar(10) NULL,
 Constraint PK_CLAIMENCOUNTERS primary key (PROVCLAIMNO,ENCOUNTERID)
);

Alter table NPHIES_CLAIMENCOUNTERS add Constraint FK_CLAIMENCOUNTERS foreign key (PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);
Alter table NPHIES_CLAIMENCOUNTERS add Constraint UNIQUE_ENCOUNTERS_ENCOUNTERID UNIQUE (ENCOUNTERID);

Create table NPHIESENCOUNTERHOSPITALIZATION (
	ENCOUNTERHOSPITALIZATIONID varchar(20) NOT NULL,
	HOSPITALADMISSIONSPECIALITY varchar(20) NOT NULL,
    HOSPITALDISCHARGESPECIALITY varchar(20) NULL,
    HOSPITALINTENDEDLENGTHOFSTAY varchar(20) NOT NULL,
    HOSPITALIZATIONORIGIN varchar(20) NULL,
    HOSPITALADMISSIONSOURCE varchar(20) NOT NULL,
    HOSPITALREADMISSION varchar(20) NULL,
    HOSPITALDISCHARGEDISPOSITION varchar(20) NULL,
	ENCOUNTERID varchar(20) NOT NULL,
 Constraint PK_ENCOUNTERHOSPITALIZATION primary key (ENCOUNTERHOSPITALIZATIONID)
);

Alter table NPHIESENCOUNTERHOSPITALIZATION add Constraint FK_ENCOUNTERHOSPITALIZATION foreign key (ENCOUNTERID) references NPHIES_CLAIMENCOUNTERS (ENCOUNTERID);


Create table NPHIES_ENCOUNTEREMERGENCY (
	ENCOUNTEREMERGENCYID varchar(20) NOT NULL,
	EMERGENCYARRIVALCODE varchar(20) NOT NULL,
	EMERGENCYSERVICESTART Datetime NOT NULL,
	EMERGENCYDEPARTMENTDISPOSITION varchar(20) NULL,
	TRIAGECATEGORY varchar(20) NOT NULL,
	TRIAGEDATE Datetime NOT NULL,
	ENCOUNTERID varchar(20) NOT NULL,
 Constraint PK_ENCOUNTEREMERGENCY primary key (ENCOUNTEREMERGENCYID)
);

Alter table NPHIES_ENCOUNTEREMERGENCY add Constraint FK_ENCOUNTERMERGENCY foreign key (ENCOUNTERID) references NPHIES_CLAIMENCOUNTERS (ENCOUNTERID);
